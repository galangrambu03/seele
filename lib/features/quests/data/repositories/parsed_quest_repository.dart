import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../../core/session/account_session.dart';
import '../../domain/entities/quest_entity.dart';
import '../../domain/repositories/quest_repository.dart';
import '../discord/discord_quest_parser.dart';
import '../discord/build_number_fetcher.dart';

/// Repository quest "live" yang memanggil Discord API langsung.
/// Juga mengimplementasikan [QuestRepository] agar bisa dipakai UI yang ada.
///
/// Delay human-like dan jitter rate-limit di port dari Velocity X:
/// - `_delay()`: jeda 0.3-0.9s sebelum tiap request, 5% peluang +1.0-2.5s.
/// - `_waitForRateLimit()`: baca `retry_after` lalu tambah jitter 1.0-3.0s.
class ParsedQuestRepository extends QuestRepository {
  final http.Client client;
  final AccountSession accountSession;
  final Random _rng = Random();

    List<Quest> _quests = const [];
  String _dataSourceLabel = 'Discord Live';
  int _buildNumber = BuildNumberFetcher.fallback;

  /// Panggil sekali di awal (mis. dari DashboardPage) untuk memperbarui
  /// build number tanpa memblokir request pertama.
  Future<void> refreshBuildNumber() async {
    _buildNumber = await BuildNumberFetcher.fetchLatest(client: client);
  }

  ParsedQuestRepository({
    http.Client? client,
    required this.accountSession,
  }) : client = client ?? http.Client();

  /// Mode offline: memuat data dari fixture JSON lokal (dipakai DashboardPage).
  factory ParsedQuestRepository.fromRawData(dynamic rawData) {
    final repo = ParsedQuestRepository(accountSession: AccountSession());
    repo.seedFromRawData(rawData);
    repo._dataSourceLabel = 'Fixture (local)';
    return repo;
  }

  void seedFromRawData(dynamic rawData) {
    try {
      List<dynamic> list = const [];
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        final q = rawData['quests'];
        if (q is List) list = q;
      }
      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map(_entityFromRaw)
          .toList();
      syncUiQuestsFromEntities(parsed);
    } catch (_) {
      // Diamkan; UI akan menampilkan kosong.
    }
  }

  // QuestRepository
  @override
  List<Quest> getAllQuests() => List.unmodifiable(_quests);

  @override
  Quest? getQuestById(String id) {
    for (final q in _quests) {
      if (q.id == id) return q;
    }
    return null;
  }

  @override
  int getTotalQuestsCount() => _quests.length;

  @override
  int getAvailableQuestsCount() =>
      _quests.where((q) => q.status == QuestStatus.available).length;

  @override
  int getInProgressQuestsCount() =>
      _quests.where((q) => q.status == QuestStatus.inProgress).length;

  @override
  int getCompletedQuestsCount() =>
      _quests.where((q) => q.status == QuestStatus.completed).length;

  @override
  bool get isMockDataSource => false;

  @override
  String get dataSourceLabel => _dataSourceLabel;

  void _setQuests(List<Quest> next, {String? label}) {
    _quests = List.unmodifiable(next);
    if (label != null) _dataSourceLabel = label;
    notifyListeners();
  }

  // Human-like delay, port dari DiscordAPI._delay() di Velocity X.
  Future<void> _delay() async {
    var base = 0.3 + _rng.nextDouble() * 0.6; // 0.3 - 0.9
    if (_rng.nextDouble() < 0.05) {
      base += 1.0 + _rng.nextDouble() * 1.5;
    }
    await Future<void>.delayed(
      Duration(milliseconds: (base * 1000).round()),
    );
  }

  // Port dari _wait_for_rate_limit() di Velocity X.
  Future<void> _waitForRateLimit(http.Response response) async {
    double retryAfter = 10;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['retry_after'] is num) {
        retryAfter = (decoded['retry_after'] as num).toDouble();
      }
    } catch (_) {
      // biarkan default
    }
    final wait = retryAfter + (1.0 + _rng.nextDouble() * 2.0);
    await Future<void>.delayed(
      Duration(milliseconds: (wait * 1000).round()),
    );
  }

  String _getSuperProperties() {
    final Map<String, dynamic> props = {
      'os': 'Windows',
      'browser': 'Discord Client',
      'release_channel': 'stable',
      'client_version': '1.0.9175',
      'os_version': '10.0.26100',
      'os_arch': 'x64',
      'app_arch': 'x64',
      'system_locale': 'en-US',
      'browser_user_agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) discord/1.0.9175 Chrome/128.0.6613.186 '
          'Electron/32.2.7 Safari/537.36',
      'browser_version': '32.2.7',
      'client_build_number': _buildNumber,
      'native_build_number': 59498,
      'screen_width': 1920,
      'screen_height': 1080,
    };
    return base64Encode(utf8.encode(jsonEncode(props)));
  }

  Map<String, String> _getHeaders() {
    final token = accountSession.currentToken ?? '';
    return {
      'Authorization': token,
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) discord/1.0.9175 Chrome/128.0.6613.186 '
          'Electron/32.2.7 Safari/537.36',
      'X-Super-Properties': _getSuperProperties(),
      'X-Discord-Locale': 'en-US',
      'X-Discord-Timezone': 'America/New_York',
      'Origin': 'https://discord.com',
      'Referer': 'https://discord.com/channels/@me',
    };
  }

  // Discord API
  /// Mengambil daftar quest live dari GET /quests/@me (mengembalikan QuestEntity).
  Future<List<QuestEntity>> fetchQuests() async {
    try {
      await _delay();
      final response = await client.get(
        Uri.parse('https://discord.com/api/v9/quests/@me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> questsRaw = [];
        if (data is Map<String, dynamic>) {
          questsRaw = data['quests'] ?? [];
        } else if (data is List) {
          questsRaw = data;
        }

        return questsRaw
            .whereType<Map<String, dynamic>>()
            .map(_entityFromRaw)
            .toList();
      } else if (response.statusCode == 429) {
        await _waitForRateLimit(response);
        return await fetchQuests();
      } else {
        throw Exception(
          'Discord API Error (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Gagal mengambil data quest live: $e');
    }
  }
    /// Hanya menarik quest dari Discord dan memperbarui UI.
  /// Tidak melakukan enroll dan tidak menjalankan video/heartbeat.
  Future<void> fetchAndSyncOnly() async {
    final entities = await fetchQuests();
    syncUiQuestsFromEntities(entities);
  }

    /// Mengosongkan daftar quest saat pengguna logout/disconnect.
  void clearQuests() {
    _setQuests([]);
    _dataSourceLabel = 'Discord Live';
  }

  QuestEntity _entityFromRaw(Map<String, dynamic> raw) {
    final rawId = raw['id']?.toString() ?? '';
    return QuestEntity(
      id: rawId,
      name: getQuestName(raw),
      reward: getQuestReward(raw),
      taskType: getTaskType(raw),
      secondsNeeded: getSecondsNeeded(raw),
      secondsDone: getSecondsDone(raw),
      isEnrolled: isEnrolled(raw),
      isCompleted: isCompleted(raw),
      isCompletable: isCompletable(raw),
      enrolledAt: getEnrolledAt(raw),
      expiresAt: getExpiresAt(raw),
      rawMetadata: raw,
    );
  }

  /// Melakukan enrollment POST /quests/{qid}/enroll.
  Future<bool> enrollQuest(
    String questId,
    Map<String, dynamic>? rawMetadata,
  ) async {
    try {
      await _delay();
      final response = await client.post(
        Uri.parse('https://discord.com/api/v9/quests/$questId/enroll'),
        headers: _getHeaders(),
        body: jsonEncode({
          'location': 11,
          'is_targeted': false,
          'metadata_raw': null,
          'metadata_sealed': null,
          'traffic_metadata_raw': rawMetadata?['traffic_metadata_raw'],
          'traffic_metadata_sealed': rawMetadata?['traffic_metadata_sealed'],
        }),
      );
      if (response.statusCode == 429) {
        await _waitForRateLimit(response);
        return false;
      }
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// POST /quests/{qid}/video-progress.
  Future<Map<String, dynamic>?> sendVideoProgress(
    String questId,
    double timestamp,
  ) async {
    try {
      await _delay();
      final response = await client.post(
        Uri.parse(
          'https://discord.com/api/v9/quests/$questId/video-progress',
        ),
        headers: _getHeaders(),
        body: jsonEncode({'timestamp': timestamp}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      } else if (response.statusCode == 429) {
        await _waitForRateLimit(response);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// POST /quests/{qid}/heartbeat.
  Future<Map<String, dynamic>?> sendHeartbeat(
    String questId,
    String streamKey,
    bool terminal,
  ) async {
    try {
      await _delay();
      final response = await client.post(
        Uri.parse('https://discord.com/api/v9/quests/$questId/heartbeat'),
        headers: _getHeaders(),
        body: jsonEncode({'stream_key': streamKey, 'terminal': terminal}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      } else if (response.statusCode == 429) {
        await _waitForRateLimit(response);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi daftar `Quest` (dipakai UI) dari hasil fetch terakhir.
    /// Sinkronisasi daftar `Quest` (dipakai UI) dari hasil fetch terakhir.
  /// Menyaring quest yang sudah selesai agar UI hanya menampilkan
  /// pekerjaan yang belum kelar, dan mengurutkan yang bisa dikerjakan di atas.
    /// Sinkronisasi daftar `Quest` (dipakai UI) dari hasil fetch terakhir.
  /// Menyaring quest yang sudah selesai, kedaluwarsa, dan tidak bisa dikerjakan.
  void syncUiQuestsFromEntities(List<QuestEntity> entities) {
    // 1. Filter ketat: buang yang selesai, kedaluwarsa, dan tidak bisa dikerjakan
    final activeEntities = entities.where((e) {
      if (e.isCompleted) return false; // Sudah selesai
      
      // Cek kedaluwarsa (mirip isCompletable di parser)
      if (e.expiresAt != null) {
        try {
          final dt = DateTime.parse(e.expiresAt!.replaceFirst('Z', '+00:00'));
          if (!dt.isAfter(DateTime.now().toUtc())) return false;
        } catch (_) {}
      }
      
      // Hanya tampilkan yang bisa dikerjakan atau sedang berjalan
      return e.isCompletable || e.isEnrolled;
    }).toList();

    // 2. Urutkan: yang sedang berjalan (enrolled) di paling atas
    activeEntities.sort((a, b) {
      if (a.isEnrolled != b.isEnrolled) {
        return a.isEnrolled ? -1 : 1;
      }
      if (a.isCompletable != b.isCompletable) {
        return a.isCompletable ? -1 : 1;
      }
      return 0;
    });

    // 3. Mapping ke Quest untuk UI
    final mapped = activeEntities.map((e) {
      final category = _categoryFromTask(e.taskType);
      final QuestStatus status;
      if (e.isCompleted) {
        status = QuestStatus.completed;
      } else if (e.isEnrolled) {
        status = QuestStatus.inProgress;
      } else {
        status = QuestStatus.available;
      }
      
      final progress = e.secondsNeeded > 0
          ? (e.secondsDone / e.secondsNeeded).clamp(0.0, 1.0)
          : 0.0;

      // Dummy description jika kosong agar UI tidak aneh
      final desc = (e.rawMetadata['config']?['messages']?['questDescription'] as String?) ?? 
                   'Complete the objective to earn rewards.';

      return Quest(
        id: e.id,
        title: e.name,
        description: desc,
        category: category,
        status: status,
        rewardOrbs: _parseOrbs(e.reward),
        duration: '${e.secondsNeeded}s',
        progress: progress,
        taskMetadata: e.rawMetadata,
        completedSeconds: e.secondsDone.toInt(),
        targetSeconds: e.secondsNeeded,
      );
    }).toList();

    _setQuests(mapped);
  }
    /// Dipanggil oleh Engine setiap kali progres berubah agar UI ikut bergerak.
  void updateQuestProgress(String questId, double secondsDone) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return; // Quest tidak ada di UI

    final oldQuest = _quests[index];
    final newProgress = oldQuest.targetSeconds != null && oldQuest.targetSeconds! > 0
        ? (secondsDone / oldQuest.targetSeconds!).clamp(0.0, 1.0)
        : 0.0;

    // Karena Quest immutable, kita buat objek baru
    final updatedQuest = Quest(
      id: oldQuest.id,
      title: oldQuest.title,
      description: oldQuest.description,
      category: oldQuest.category,
      status: secondsDone >= (oldQuest.targetSeconds ?? 1) 
          ? QuestStatus.completed 
          : QuestStatus.inProgress,
      rewardOrbs: oldQuest.rewardOrbs,
      duration: oldQuest.duration,
      progress: newProgress,
      taskMetadata: oldQuest.taskMetadata,
      completedSeconds: secondsDone.toInt(),
      targetSeconds: oldQuest.targetSeconds,
    );

    final newList = List<Quest>.from(_quests);
    newList[index] = updatedQuest;
    _setQuests(newList);
  }

  QuestCategory _categoryFromTask(String? taskType) {
    if (taskType == null) return QuestCategory.activity;
    if (taskType.contains('WATCH_VIDEO')) return QuestCategory.video;
    if (taskType.contains('STREAM')) return QuestCategory.stream;
    if (taskType.contains('PLAY')) return QuestCategory.game;
    return QuestCategory.activity;
  }

  int _parseOrbs(String reward) {
    final match = RegExp(r'(\d+)').firstMatch(reward);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }
}