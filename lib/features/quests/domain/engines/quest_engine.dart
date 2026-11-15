import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/repositories/parsed_quest_repository.dart';
import '../entities/quest_entity.dart';

/// Status satu eksekusi quest (port dari QuestState.status di Velocity X).
enum QuestRunStatus { queued, running, paused, done, error, skipped }

/// State satu quest yang sedang/sudah dieksekusi.
class QuestRun {
  QuestRun({
    required this.questId,
    required this.name,
    required this.taskType,
    required this.secondsNeeded,
    required this.secondsDone,
    required this.enrolledAt,
  }) : status = QuestRunStatus.queued;

  final String questId;
  final String name;
  final String? taskType;
  final int secondsNeeded;
  double secondsDone;
  final DateTime enrolledAt;

  QuestRunStatus status;
  bool completed = false;
  DateTime lastUpdate = DateTime.now();

  double get remaining {
    final r = secondsNeeded - secondsDone;
    return r < 0 ? 0.0 : r.toDouble();
  }

  double get pct {
    if (secondsNeeded == 0) return 100.0;
    return (secondsDone / secondsNeeded * 100).clamp(0.0, 100.0);
  }

  void advance(double value) {
    secondsDone = value;
    status = QuestRunStatus.running;
    if (secondsDone >= secondsNeeded) {
      completed = true;
      status = QuestRunStatus.done;
    }
    lastUpdate = DateTime.now();
  }

  static QuestRun fromEntity(QuestEntity e) {
    final run = QuestRun(
      questId: e.id,
      name: e.name,
      taskType: e.taskType,
      secondsNeeded: e.secondsNeeded,
      secondsDone: e.secondsDone,
      enrolledAt: DateTime.now(),
    );
    if (e.isCompleted) {
      run.status = QuestRunStatus.done;
      run.completed = true;
    } else if (e.isEnrolled) {
      run.status = QuestRunStatus.running;
    }
    return run;
  }
}

class QuestEngine extends ChangeNotifier {
  final ParsedQuestRepository repository;

  QuestEngine({required this.repository});

  bool _isRunning = false;
  bool _isPaused = false;

  final Map<String, QuestRun> _runs = {};
  final Set<String> _completedIds = {};

  Function(String message, String level)? onLog;
  Function(List<QuestEntity> quests)? onProgressUpdate;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  List<QuestRun> get runs => _runs.values.toList(growable: false);
  QuestRun? getRun(String id) => _runs[id];

  void pause([String? id]) {
    if (id != null) {
      final run = _runs[id];
      if (run != null) {
        run.status = QuestRunStatus.paused;
        notifyListeners();
        onLog?.call('Quest ${run.name} dijeda.', 'warn');
      }
      return;
    }
    _isPaused = true;
    for (final run in _runs.values) {
      if (run.status == QuestRunStatus.running) {
        run.status = QuestRunStatus.paused;
      }
    }
    notifyListeners();
    onLog?.call('Quest Engine dijeda (Paused).', 'warn');
  }

  void resume([String? id]) {
    if (id != null) {
      final run = _runs[id];
      if (run != null && run.status == QuestRunStatus.paused) {
        run.status = QuestRunStatus.running;
        notifyListeners();
        onLog?.call('Quest ${run.name} dilanjutkan.', 'ok');
      }
      return;
    }
    _isPaused = false;
    for (final run in _runs.values) {
      if (run.status == QuestRunStatus.paused) {
        run.status = QuestRunStatus.running;
      }
    }
    notifyListeners();
    onLog?.call('Quest Engine dilanjutkan (Resumed).', 'ok');
  }

  void stop([String? id]) {
    if (id != null) {
      final run = _runs[id];
      if (run != null) {
        run.status = QuestRunStatus.skipped;
        notifyListeners();
        onLog?.call('Quest ${run.name} dihentikan.', 'error');
      }
      return;
    }
    _isRunning = false;
    _isPaused = false;
    for (final run in _runs.values) {
      if (run.status == QuestRunStatus.running ||
          run.status == QuestRunStatus.paused) {
        run.status = QuestRunStatus.skipped;
      }
    }
    notifyListeners();
    onLog?.call('Quest Engine dihentikan.', 'error');
  }

  Future<void> start(String questId) async {
    try {
      final entities = await repository.fetchQuests();
      final entity = entities.firstWhere(
        (e) => e.id == questId,
        orElse: () => throw StateError('Quest $questId tidak ditemukan'),
      );

      final run = QuestRun.fromEntity(entity);
      _runs[questId] = run;
      _isRunning = true;
      notifyListeners();

      onLog?.call('Memulai quest: ${entity.name}', 'ok');

      final task = entity.taskType ?? '';
      if (task.contains('WATCH_VIDEO')) {
        await _runVideoGroup([entity]);
      } else if (task.isNotEmpty && !task.contains('ACHIEVEMENT')) {
        await _runHeartbeatGroup([entity]);
      } else {
        onLog?.call(
          'Quest ${entity.name} tidak bisa dijalankan otomatis (task: $task).',
          'warn',
        );
        run.status = QuestRunStatus.skipped;
        notifyListeners();
      }
    } catch (e) {
      onLog?.call('Error start quest $questId: $e', 'error');
      _runs[questId]?.status = QuestRunStatus.error;
      notifyListeners();
    }
  }

  Future<void> startAutomation() async {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    notifyListeners();
    onLog?.call('Memulai Quest Automation Engine...', 'ok');

    try {
      while (_isRunning) {
        if (_isPaused) {
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }

        onLog?.call('Mengambil daftar quest terbaru...', 'info');
        final entities = await repository.fetchQuests();
        repository.syncUiQuestsFromEntities(entities);
        onLog?.call('Ditemukan ${entities.length} quest pada akun.', 'info');

        for (final quest in entities) {
          if (!quest.isEnrolled && !quest.isCompleted && quest.isCompletable) {
            onLog?.call('Auto-accept quest: ${quest.name}', 'info');
            final ok = await repository.enrollQuest(quest.id, quest.rawMetadata);
            if (ok) onLog?.call('Berhasil enroll: ${quest.name}', 'ok');
            await Future<void>.delayed(
              Duration(milliseconds: 2000 + Random().nextInt(2000)),
            );
          }
        }

        final refreshed = await repository.fetchQuests();
        repository.syncUiQuestsFromEntities(refreshed);
        onProgressUpdate?.call(refreshed);

        final actionable = refreshed
            .where((q) =>
                q.isEnrolled &&
                !q.isCompleted &&
                q.isCompletable &&
                !_completedIds.contains(q.id))
            .toList();

        if (actionable.isEmpty) {
          onLog?.call(
            'Tidak ada quest yang perlu dikerjakan. Menunggu scan berikutnya...',
            'info',
          );
          await Future<void>.delayed(const Duration(seconds: 60));
          continue;
        }

        final videoQuests = actionable
            .where((q) => (q.taskType ?? '').contains('WATCH_VIDEO'))
            .toList();
        final heartbeatQuests = actionable
            .where((q) =>
                !(q.taskType ?? '').contains('WATCH_VIDEO') &&
                !(q.taskType ?? '').contains('ACHIEVEMENT'))
            .toList();

        onLog?.call(
          'Eksekusi paralel (${videoQuests.length} video, ${heartbeatQuests.length} heartbeat)...',
          'info',
        );

        await Future.wait([
          if (videoQuests.isNotEmpty) _runVideoGroup(videoQuests),
          if (heartbeatQuests.isNotEmpty) _runHeartbeatGroup(heartbeatQuests),
        ]);

        onLog?.call('Siklus selesai. Menunggu scan berikutnya...', 'ok');
        await Future<void>.delayed(const Duration(seconds: 30));
      }
    } catch (e) {
      onLog?.call('Error fatal pada QuestEngine: $e', 'error');
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }

  Future<void> _runVideoGroup(List<QuestEntity> quests) async {
    onLog?.call('Video Group: ${quests.length} quest', 'info');
    for (final q in quests) {
      _runs[q.id] = QuestRun.fromEntity(q);
    }
    notifyListeners();

    while (_isRunning && !_isPaused) {
      var allDone = true;
      for (final quest in quests) {
        final run = _runs[quest.id]!;
        if (run.completed || run.status == QuestRunStatus.paused) continue;
        allDone = false;

        final next = min(
          quest.secondsNeeded.toDouble(),
          run.secondsDone + 7.0 + Random().nextDouble() * 0.5,
        );

        final response = await repository.sendVideoProgress(quest.id, next);
        if (response != null) {
          run.advance(next);
          onLog?.call(
            '[Video] ${quest.name}: ${run.secondsDone.toStringAsFixed(0)} / ${quest.secondsNeeded}s',
            'progress',
          );
          if (run.completed) _completedIds.add(quest.id);
          notifyListeners();
        }

        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }
      if (allDone) break;
    }
  }

  Future<void> _runHeartbeatGroup(List<QuestEntity> quests) async {
    onLog?.call('Heartbeat Group: ${quests.length} quest', 'info');

    await Future.wait(quests.map((quest) async {
      final run = _runs.putIfAbsent(quest.id, () => QuestRun.fromEntity(quest));
      final rng = Random();
      final guildId = 100000000000000000 + rng.nextInt(900000000);
      final channelId = 100000000000000000 + rng.nextInt(900000000);
      final streamKey = 'guild:$guildId:$channelId:${rng.nextInt(900000000)}';

      while (_isRunning &&
          !_isPaused &&
          !run.completed &&
          run.status != QuestRunStatus.paused) {
        try {
          final res =
              await repository.sendHeartbeat(quest.id, streamKey, false);
          if (res != null) {
            run.advance(min(
              quest.secondsNeeded.toDouble(),
              run.secondsDone + 20.0,
            ));
            onLog?.call(
              '[Heartbeat] ${quest.name}: ${run.secondsDone.toStringAsFixed(0)} / ${quest.secondsNeeded}s',
              'progress',
            );
            notifyListeners();
          }
        } catch (e) {
          onLog?.call('Heartbeat warning pada ${quest.name}: $e', 'warn');
        }
        await Future<void>.delayed(const Duration(seconds: 20));
      }

      await repository.sendHeartbeat(quest.id, streamKey, true);
      _completedIds.add(quest.id);
      onLog?.call('Selesai heartbeat quest: ${quest.name}', 'ok');
    }));
  }

  @override
  void dispose() {
    _isRunning = false;
    _isPaused = false;
    _runs.clear();
    _completedIds.clear();
    super.dispose();
  }
}
