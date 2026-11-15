import '../../domain/entities/quest_entity.dart';
import '../parsers/quest_parser.dart';

class QuestMapper {
  static Quest toEntity(ParsedQuest parsed) {
    final taskType = parsed.taskType;
    final category = _category(taskType);
    // Achievement target counts events, not elapsed seconds.
    final isAchievement = taskType == 'ACHIEVEMENT_IN_ACTIVITY';
    final target = !isAchievement && parsed.secondsNeeded > 0
        ? parsed.secondsNeeded
        : null;

    final completedSeconds = parsed.secondsDone.round().clamp(0, target ?? 0);
    final achievementProgress = isAchievement && parsed.achievementTarget > 0
        ? (parsed.secondsDone / parsed.achievementTarget).clamp(0.0, 1.0)
        : 0.0;

    final isTaskCompleted = isAchievement
        ? achievementProgress >= 1.0
        : target != null && completedSeconds >= target;

    final status =
        parsed.completed || isTaskCompleted
        ? QuestStatus.completed
        : parsed.enrolled || completedSeconds > 0 || achievementProgress > 0
        ? QuestStatus.inProgress
        : QuestStatus.available;

    return Quest(
      id: parsed.id,
      title: parsed.name,
      description: parsed.description,
      category: category,
      status: status,
      rewardOrbs: _extractOrbAmount(parsed.reward),
      duration: _formatDuration(target),
      progress: isAchievement
          ? achievementProgress
          : target == null || target == 0
          ? 0
          : (completedSeconds / target).clamp(0.0, 1.0),
      requirements: const [],
      taskType: _taskType(taskType),
      targetSeconds: target,
      completedSeconds: completedSeconds,
      taskMetadata: {
        'discordTaskType': taskType,
        'reward': parsed.reward,
        'expiresAt': parsed.expiresAt,
        'enrolled': parsed.enrolled,
        'completable': parsed.completable,
        'rawTaskKeys': parsed.rawTaskKeys,
        'appId': parsed.appId,
        'eventName': parsed.eventName,
        'achievementTarget': parsed.achievementTarget,
      },
    );
  }

  static List<Quest> toEntities(List<ParsedQuest> quests) {
    return quests.where((quest) => quest.id.isNotEmpty).map(toEntity).toList();
  }

  static QuestCategory _category(String? type) {
    if (type == 'WATCH_VIDEO' ||
        type == 'WATCH_VIDEO_ON_MOBILE' ||
        type == 'WATCH_VIDEO_ON_DESKTOP') {
      return QuestCategory.video;
    }

    if (type == 'STREAM_ON_DESKTOP') {
      return QuestCategory.stream;
    }

    if (type == 'ACHIEVEMENT_IN_ACTIVITY' || type == 'PLAY_ACTIVITY') {
      return QuestCategory.activity;
    }

    return QuestCategory.game;
  }

  static QuestTaskType? _taskType(String? type) {
    if (type == null) return null;

    if (type.startsWith('WATCH_VIDEO')) {
      return QuestTaskType.video;
    }

    if (type == 'STREAM_ON_DESKTOP') {
      return QuestTaskType.stream;
    }

    if (type == 'ACHIEVEMENT_IN_ACTIVITY' || type == 'PLAY_ACTIVITY') {
      return QuestTaskType.activity;
    }

    return QuestTaskType.game;
  }

  static int _extractOrbAmount(String reward) {
    final match = RegExp(
      r'(\d[\d,]*)\s*(?:discord\s*)?orbs?',
      caseSensitive: false,
    ).firstMatch(reward);

    if (match == null) return 0;
    return int.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '—';

    if (seconds % 60 == 0) {
      return '${seconds ~/ 60} min';
    }

    return '${seconds ~/ 60}m ${seconds % 60}s';
  }
}
