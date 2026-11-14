import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';

enum QuestCategory {
  video,
  game,
  stream,
  activity;

  String get displayName {
    switch (this) {
      case QuestCategory.video:
        return 'Video';
      case QuestCategory.game:
        return 'Game';
      case QuestCategory.stream:
        return 'Stream';
      case QuestCategory.activity:
        return 'Activity';
    }
  }

  Color get accentColor {
    switch (this) {
      case QuestCategory.video:
        return AppColor.questVideo;
      case QuestCategory.game:
        return AppColor.questGame;
      case QuestCategory.stream:
        return AppColor.questStream;
      case QuestCategory.activity:
        return AppColor.questActivity;
    }
  }

  Color get darkAccentColor {
    switch (this) {
      case QuestCategory.video:
        return AppColor.limeDark;
      case QuestCategory.game:
        return AppColor.cyanDark;
      case QuestCategory.stream:
        return AppColor.lavenderDark;
      case QuestCategory.activity:
        return AppColor.amberDark;
    }
  }

  IconData get iconData {
    switch (this) {
      case QuestCategory.video:
        return Icons.play_arrow_rounded;
      case QuestCategory.game:
        return Icons.sports_esports_rounded;
      case QuestCategory.stream:
        return Icons.sensors_rounded;
      case QuestCategory.activity:
        return Icons.explore_rounded;
    }
  }
}

enum QuestTaskType { video, game, stream, activity }

enum QuestStatus {
  available,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case QuestStatus.available:
        return 'Available';
      case QuestStatus.inProgress:
        return 'In Progress';
      case QuestStatus.completed:
        return 'Completed';
    }
  }

  Color get badgeColor {
    switch (this) {
      case QuestStatus.available:
        return AppColor.lime;
      case QuestStatus.inProgress:
        return AppColor.cyan;
      case QuestStatus.completed:
        return AppColor.success;
    }
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestCategory category;
  final QuestStatus status;
  final int rewardOrbs;
  final String duration;
  final double progress; // 0.0 to 1.0
  final List<String> requirements;

  // Generic task tracking data
  final QuestTaskType? taskType;
  final int? targetSeconds;
  final int completedSeconds;
  final Map<String, dynamic> taskMetadata;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.rewardOrbs,
    required this.duration,
    this.progress = 0.0,
    this.requirements = const [],
    this.taskType,
    this.targetSeconds,
    this.completedSeconds = 0,
    this.taskMetadata = const {},
  });

  double get taskProgress {
    if (targetSeconds == null || targetSeconds! <= 0) {
      return progress;
    }
    return (completedSeconds / targetSeconds!).clamp(0.0, 1.0);
  }

  int get remainingSeconds {
    if (targetSeconds == null) return 0;
    return (targetSeconds! - completedSeconds).clamp(0, targetSeconds!);
  }

  bool get isAvailable => status == QuestStatus.available;
  bool get isInProgress => status == QuestStatus.inProgress;
  bool get isCompleted => status == QuestStatus.completed;
}
