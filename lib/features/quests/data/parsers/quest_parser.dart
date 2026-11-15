class ParsedQuest {
  final String id;
  final String name;
  final String description;
  final String reward;
  final String? expiresAt;
  final String? taskType;
  final int secondsNeeded;
  final double secondsDone;
  final bool enrolled;
  final bool completed;
  final bool completable;
  final List<String> rawTaskKeys;
  final String? appId;
  final String eventName;
  final int achievementTarget;

  const ParsedQuest({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.expiresAt,
    required this.taskType,
    required this.secondsNeeded,
    required this.secondsDone,
    required this.enrolled,
    required this.completed,
    required this.completable,
    required this.rawTaskKeys,
    required this.appId,
    required this.eventName,
    required this.achievementTarget,
  });

  double get progress {
    if (secondsNeeded <= 0) return 0;
    return (secondsDone / secondsNeeded).clamp(0.0, 1.0);
  }

  double get remainingSeconds =>
      (secondsNeeded - secondsDone).clamp(0, double.infinity);
}

class QuestParser {
  static const supportedTasks = [
    'WATCH_VIDEO',
    'PLAY_ON_DESKTOP',
    'STREAM_ON_DESKTOP',
    'PLAY_ACTIVITY',
    'WATCH_VIDEO_ON_MOBILE',
    'PLAY_ON_MOBILE',
    'WATCH_VIDEO_ON_DESKTOP',
    'ACHIEVEMENT_IN_ACTIVITY',
    'PLAY_ON_PLAYSTATION',
    'PLAY_ON_XBOX',
  ];

  static const videoTasks = {
    'WATCH_VIDEO',
    'WATCH_VIDEO_ON_MOBILE',
    'WATCH_VIDEO_ON_DESKTOP',
  };

  static const heartbeatTasks = {
    'PLAY_ON_DESKTOP',
    'STREAM_ON_DESKTOP',
    'PLAY_ACTIVITY',
    'PLAY_ON_MOBILE',
    'PLAY_ON_PLAYSTATION',
    'PLAY_ON_XBOX',
  };

  static const achievementTasks = {'ACHIEVEMENT_IN_ACTIVITY'};

  static dynamic _get(Map? data, List<String> keys) {
    if (data == null) return null;

    for (final key in keys) {
      if (data.containsKey(key)) return data[key];
    }

    return null;
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static List _list(dynamic value) {
    return value is List ? value : [];
  }

  static Map<String, dynamic> getTaskConfig(Map quest) {
    final config = _map(quest['config']);

    return _map(
      _get(config, [
        'taskConfig',
        'task_config',
        'taskConfigV2',
        'task_config_v2',
      ]),
    );
  }

  static Map<String, dynamic> getUserStatus(Map quest) {
    return _map(_get(quest, ['userStatus', 'user_status']));
  }

  static Map<String, dynamic> getTasks(Map quest) {
    return _map(getTaskConfig(quest)['tasks']);
  }

  static String getName(Map quest) {
    final config = _map(quest['config']);
    final messages = _map(config['messages']);

    for (final key in [
      'questName',
      'quest_name',
      'gameTitle',
      'game_title',
      'title',
    ]) {
      final value = messages[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final appName = _map(config['application'])['name'];
    if (appName is String && appName.trim().isNotEmpty) {
      return appName.trim();
    }

    return 'Quest#${quest['id'] ?? '?'}';
  }

  static String getDescription(Map quest) {
    final config = _map(quest['config']);
    final messages = _map(config['messages']);

    for (final key in [
      'questDescription',
      'quest_description',
      'description',
      'subtitle',
    ]) {
      final value = messages[key] ?? config[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return 'Complete this Discord quest to earn its reward.';
  }

  static String getReward(Map quest) {
    final config = _map(quest['config']);
    final rewardConfig = _map(config['rewards_config']);
    final rewards = _list(rewardConfig['rewards']);

    if (rewards.isNotEmpty) {
      final item = _map(rewards.first);
      final messages = _map(item['messages']);

      final name = messages['name'] ?? messages['name_with_article'];
      if (name is String && name.trim().isNotEmpty) {
        return name.trim();
      }

      final quantity = item['orb_quantity'] ?? item['premium_orb_quantity'];

      if (quantity is num && quantity > 0) {
        return '${quantity.toInt()} Orbs';
      }
    }

    for (final key in [
      'rewardItems',
      'reward_items',
      'rewards',
      'prize',
      'prizes',
    ]) {
      final items = _list(config[key]);
      if (items.isEmpty) continue;

      final item = items.first;

      if (item is String && item.trim().isNotEmpty) {
        return item.trim();
      }

      final data = _map(item);
      final messages = _map(data['messages']);
      final name = messages['name'] ?? messages['name_with_article'];

      if (name is String && name.trim().isNotEmpty) {
        return name.trim();
      }

      final orb = _orbLabel(data);
      if (orb != null) return orb;

      for (final field in [
        'label',
        'item_name',
        'itemName',
        'displayName',
        'display_name',
      ]) {
        final value = data[field];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    final messages = _map(config['messages']);

    for (final key in [
      'rewardDescription',
      'reward_description',
      'rewardTitle',
      'reward_title',
      'rewardName',
      'reward_name',
    ]) {
      final value = messages[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final recursive = _walkForReward(rewardConfig) ?? _walkForReward(config);

    if (recursive != null && recursive.length < 80) {
      return recursive;
    }

    return '—';
  }

  static String? _orbLabel(Map data) {
    dynamic amount;

    for (final key in ['amount', 'quantity', 'count', 'value']) {
      final value = data[key];
      if (value is num && value > 0) {
        amount = value;
        break;
      }
    }

    if (amount == null) return null;

    final type = '${data['type'] ?? data['currency'] ?? ''}'.toUpperCase();

    final isOrb = [
      'ORB',
      'DISCORD_PRODUCT',
      'CREDIT',
      'COIN',
      'TOKEN',
    ].any(type.contains);

    if (isOrb || amount >= 100) {
      return '${(amount as num).toInt()} Discord Orbs';
    }

    return null;
  }

  static const _rewardNameKeys = {
    'rewardDescription',
    'reward_description',
    'rewardTitle',
    'reward_title',
    'rewardName',
    'reward_name',
    'prizeDescription',
    'prize_title',
    'displayName',
    'display_name',
    'item_name',
    'itemName',
    'label',
  };

  static const _rewardContainers = {
    'reward',
    'rewards',
    'rewardItems',
    'reward_items',
    'prize',
    'prizes',
    'items',
    'entitlements',
  };

  static const _appKeys = {
    'application',
    'app',
    'game',
    'publisher',
    'developer',
    'guild',
  };

  static String? _walkForReward(dynamic value, [int depth = 0]) {
    if (depth > 6) return null;

    if (value is Map) {
      final data = _map(value);

      final orb = _orbLabel(data);
      if (orb != null) return orb;

      for (final entry in data.entries) {
        if (_rewardNameKeys.contains(entry.key) &&
            entry.value is String &&
            (entry.value as String).trim().isNotEmpty) {
          return (entry.value as String).trim();
        }
      }

      for (final key in _rewardContainers) {
        if (data.containsKey(key)) {
          final result = _walkForReward(data[key], depth + 1);
          if (result != null) return result;
        }
      }

      for (final entry in data.entries) {
        if (_rewardContainers.contains(entry.key) ||
            _appKeys.contains(entry.key)) {
          continue;
        }

        final result = _walkForReward(entry.value, depth + 1);
        if (result != null) return result;
      }
    }

    if (value is List) {
      for (final item in value.take(5)) {
        final result = _walkForReward(item, depth + 1);
        if (result != null) return result;
      }
    }

    return null;
  }

  static String? getTaskType(Map quest) {
    final tasks = getTasks(quest);

    for (final type in supportedTasks) {
      if (tasks[type] != null) return type;
    }

    return null;
  }

  static List<String> getRawTaskKeys(Map quest) {
    return getTasks(quest).keys.map((key) => key.toString()).toList();
  }

  static int getSecondsNeeded(Map quest) {
    final type = getTaskType(quest);
    if (type == null) return 0;

    final task = _map(getTasks(quest)[type]);
    final target = task['target'];

    return target is num ? target.toInt() : 0;
  }

  static double getSecondsDone(Map quest) {
    final type = getTaskType(quest);
    if (type == null) return 0;

    final status = getUserStatus(quest);
    final progress = _map(status['progress']);
    final taskProgress = _map(progress[type]);
    final value = taskProgress['value'];

    return value is num ? value.toDouble() : 0;
  }

  static String? getExpiresAt(Map quest) {
    final config = _map(quest['config']);
    final value = _get(config, ['expiresAt', 'expires_at']);
    return value is String ? value : null;
  }

  static bool isEnrolled(Map quest) {
    final status = getUserStatus(quest);
    return _get(status, ['enrolledAt', 'enrolled_at']) != null;
  }

  static bool isCompleted(Map quest) {
    final status = getUserStatus(quest);
    return _get(status, ['completedAt', 'completed_at']) != null;
  }

  static bool isCompletable(Map quest, {DateTime? now}) {
    final expires = getExpiresAt(quest);

    if (expires != null) {
      final expiry = DateTime.tryParse(expires);
      if (expiry != null && !expiry.isAfter((now ?? DateTime.now()).toUtc())) {
        return false;
      }
    }

    final tasks = getTasks(quest);
    return supportedTasks.any((type) => tasks[type] != null);
  }

  static Map<String, dynamic> getActivityInfo(Map quest) {
    final task = _map(getTasks(quest)['ACHIEVEMENT_IN_ACTIVITY']);
    final applications = _list(task['applications']);

    String? appId;

    if (applications.isNotEmpty) {
      final first = _map(applications.first);
      final id = first['id'];
      if (id != null) appId = id.toString();
    }

    if (appId == null) {
      final config = _map(quest['config']);
      final application = _map(config['application']);
      final id = application['id'];
      if (id != null) appId = id.toString();
    }

    final target = task['target'];

    return {
      'app_id': appId,
      'event_name': task['event_name'] ?? 'progress',
      'target': target is num ? target.toInt() : 1,
    };
  }

  static ParsedQuest parse(Map raw) {
    final id = raw['id']?.toString() ?? '';
    final taskType = getTaskType(raw);
    final needed = getSecondsNeeded(raw);
    final done = getSecondsDone(raw);
    final activity = getActivityInfo(raw);

    return ParsedQuest(
      id: id,
      name: getName(raw),
      description: getDescription(raw),
      reward: getReward(raw),
      expiresAt: getExpiresAt(raw),
      taskType: taskType,
      secondsNeeded: needed,
      secondsDone: done,
      enrolled: isEnrolled(raw),
      completed: isCompleted(raw),
      completable: isCompletable(raw),
      rawTaskKeys: getRawTaskKeys(raw),
      appId: activity['app_id'] as String?,
      eventName: activity['event_name'].toString(),
      achievementTarget: activity['target'] as int,
    );
  }

  static List<ParsedQuest> parseList(dynamic data) {
    dynamic quests = data;

    if (data is Map) {
      quests = data['quests'] ?? [];
    }

    if (quests is! List) return [];

    return quests.whereType<Map>().map(parse).toList();
  }
}
