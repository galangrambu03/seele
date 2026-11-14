import '../../domain/entities/quest_entity.dart';
import '../../domain/repositories/quest_repository.dart';

class MockQuestRepository extends QuestRepository {
  final List<Quest> _quests;

  MockQuestRepository({List<Quest>? customQuests})
    : _quests = List<Quest>.of(customQuests ?? _defaultMockQuests);

  void updateProgress(String questId, int completedSeconds) {
    final index = _quests.indexWhere((quest) => quest.id == questId);
    if (index == -1) return;

    final current = _quests[index];
    final target = current.targetSeconds;

    if (target == null || target <= 0) return;

    final updatedSeconds = completedSeconds.clamp(0, target);
    final updatedProgress = updatedSeconds / target;
    final updatedStatus = updatedProgress >= 1.0
        ? QuestStatus.completed
        : QuestStatus.inProgress;

    _quests[index] = Quest(
      id: current.id,
      title: current.title,
      description: current.description,
      category: current.category,
      status: updatedStatus,
      rewardOrbs: current.rewardOrbs,
      duration: current.duration,
      progress: updatedProgress,
      requirements: current.requirements,
      taskType: current.taskType,
      targetSeconds: target,
      completedSeconds: updatedSeconds,
      taskMetadata: current.taskMetadata,
    );

    notifyListeners();
  }

  @override
  bool get isMockDataSource => true;

  @override
  String get dataSourceLabel =>
      'Simulated Mock Data • Discord Gateway API Pending';

  @override
  List<Quest> getAllQuests() {
    return List.unmodifiable(_quests);
  }

  @override
  Quest? getQuestById(String id) {
    try {
      return _quests.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
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

  static const List<Quest> _defaultMockQuests = [
    Quest(
      id: 'q1',
      title: 'Watch Devstream Episode #4',
      description:
          'Tune in to the special community developer showcase for 15 minutes.',
      category: QuestCategory.video,
      status: QuestStatus.available,
      rewardOrbs: 150,
      duration: '15 min',
      progress: 0.0,
      requirements: [
        'Watch the official SEELE community livestream on Discord Stage',
        'Stay connected for at least 15 uninterrupted minutes',
        'Have Discord stream audio unmuted at minimum 10% volume',
      ],
    ),
    Quest(
      id: 'q2',
      title: 'Conquer the Cyber Labyrinth',
      description: 'Launch SEELE Arcade and reach Stage 3 in single-player or co-op mode.',
      category: QuestCategory.game,
      status: QuestStatus.inProgress,
      rewardOrbs: 300,
      duration: '25 min',
      progress: 0.65,
      requirements: [
        'Launch SEELE Arcade from the Discord Activity Launcher',
        'Survive Stage 1 and defeat the Cyber Mini-Boss',
        'Reach Stage 3 checkpoint with your squad',
      ],
    ),
    Quest(
      id: 'q3',
      title: 'Stream to a Voice Channel',
      description: 'Broadcast your screen to at least 2 friends in Discord for 20 minutes.',
      category: QuestCategory.stream,
      status: QuestStatus.inProgress,
      rewardOrbs: 250,
      duration: '20 min',
      progress: 0.40,
      requirements: [
        'Join any active Discord voice channel with 2 or more members',
        'Start screen share or application broadcast at 720p or higher',
        'Maintain active broadcast session for at least 20 minutes',
      ],
    ),
    Quest(
      id: 'q4',
      title: 'Join Community Soundstage',
      description: 'Participate in the live chill-hop listening party and drop 3 reactions.',
      category: QuestCategory.activity,
      status: QuestStatus.completed,
      rewardOrbs: 100,
      duration: '10 min',
      progress: 1.0,
      requirements: [
        'Join the verified Community Soundstage channel',
        'Listen to music for 10 minutes',
        'React with 3 emojis on the live soundboard',
      ],
    ),
    Quest(
      id: 'q5',
      title: 'Trial of the Speedrunner',
      description: 'Complete the weekly boss battle challenge under 4 minutes.',
      category: QuestCategory.game,
      status: QuestStatus.available,
      rewardOrbs: 400,
      duration: '30 min',
      progress: 0.0,
      requirements: [
        'Enter Weekly Speedrun Boss Challenge in SEELE Arcade',
        'Defeat the boss before the 4:00 timer expires',
        'Submit score to Discord Guild Leaderboard',
      ],
    ),
    Quest(
      id: 'q6',
      title: 'Watch Championship Highlights',
      description:
          'Catch the top plays from the Discord Community Invitational.',
      category: QuestCategory.video,
      status: QuestStatus.completed,
      rewardOrbs: 120,
      duration: '12 min',
      progress: 1.0,
      requirements: [
        'Open the Championship VOD in Discord Video Player',
        'Watch key highlights for at least 12 minutes',
      ],
    ),
  ];
}
