import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/session/account_session.dart';
import '../../domain/entities/quest_entity.dart';
import '../../domain/repositories/quest_repository.dart';
import '../discord/discord_quest_parser.dart';

/// Repository quest "live" yang memanggil Discord API langsung.
/// Juga mengimplementasikan [QuestRepository] agar bisa dipakai UI yang ada.
class ParsedQuestRepository extends QuestRepository {
  final http.Client client;
  final AccountSession accountSession;

  List<Quest> _quests = const [];
  String _dataSourceLabel = 'Discord Live';

  ParsedQuestRepository({
    http.Client? client,
    required this.accountSession,
  }) : client = client ?? http.Client();

  /// Mode offline: memuat data dari fixture JSON lokal (dipakai DashboardPage).
  /// Tidak memerlukan token Discord; hanya untuk menampilkan data awal.
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

  // ── QuestRepository ──────────────────────────────────────────────────
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

  // ── Headers (dipindah ke helper; tetap identik dgn versi sebelumnya) ──
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
      'client_build_number': 504649,
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

  // ── Discord API ──────────────────────────────────────────────────────
  /// Mengambil daftar quest live dari GET /quests/@me (mengembalikan QuestEntity).
  Future<List<QuestEntity>> fetchQuests() async {
    try {
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
        final body = jsonDecode(response.body);
        final retryAfter = (body['retry_after'] ?? 10).toDouble();
        await Future<void>.delayed(Duration(seconds: retryAfter.toInt()));
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
        await Future<void>.delayed(const Duration(seconds: 10));
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
      final response = await client.post(
        Uri.parse('https://discord.com/api/v9/quests/$questId/heartbeat'),
        headers: _getHeaders(),
        body: jsonEncode({'stream_key': streamKey, 'terminal': terminal}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi daftar `Quest` (dipakai UI) dari hasil fetch terakhir.
  /// Mapping sederhana; kategori/status diturunkan dari task type.
  void syncUiQuestsFromEntities(List<QuestEntity> entities) {
    final mapped = entities.map((e) {
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
      return Quest(
        id: e.id,
        title: e.name,
        description: '',
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
