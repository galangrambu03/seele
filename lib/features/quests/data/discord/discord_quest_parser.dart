// Port dari helper quest di script Velocity X (Python).
// Semua nama method sengaja dibuat mirip supaya mudah dilacak.

const List<String> kSupportedTasks = [
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

const Set<String> kHeartbeatTasks = {
  'PLAY_ON_DESKTOP',
  'STREAM_ON_DESKTOP',
  'PLAY_ACTIVITY',
  'PLAY_ON_MOBILE',
  'PLAY_ON_PLAYSTATION',
  'PLAY_ON_XBOX',
};

const Set<String> kAchievementTasks = {'ACHIEVEMENT_IN_ACTIVITY'};

const Set<String> kVideoTasks = {
  'WATCH_VIDEO',
  'WATCH_VIDEO_ON_MOBILE',
  'WATCH_VIDEO_ON_DESKTOP',
};

const Set<String> _appKeys = {
  'application',
  'app',
  'game',
  'publisher',
  'developer',
  'guild',
};

const Set<String> _rewardNameKeys = {
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

const Set<String> _rewardContainers = {
  'reward',
  'rewards',
  'rewardItems',
  'reward_items',
  'prize',
  'prizes',
  'items',
  'entitlements',
};

dynamic _get(Map? d, List<String> keys) {
  if (d == null) return null;
  for (final k in keys) {
    if (d.containsKey(k)) return d[k];
  }
  return null;
}

Map<String, dynamic>? getTaskConfig(Map<String, dynamic> quest) {
  final cfg = quest['config'];
  if (cfg is! Map) return null;
  final raw = _get(cfg, [
    'taskConfig',
    'task_config',
    'taskConfigV2',
    'task_config_v2',
  ]);
  return raw is Map ? Map<String, dynamic>.from(raw) : null;
}

String getQuestName(Map<String, dynamic> quest) {
  final cfg = quest['config'];
  if (cfg is Map) {
    final msgs = cfg['messages'];
    if (msgs is Map) {
      for (final key in [
        'questName',
        'quest_name',
        'gameTitle',
        'game_title',
        'title',
      ]) {
        final v = msgs[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    final appName = (cfg['application'] is Map)
        ? (cfg['application'] as Map)['name']
        : null;
    if (appName is String && appName.trim().isNotEmpty) return appName.trim();
  }
  return 'Quest#${quest['id'] ?? '?'}';
}

String? _orbLabel(Map item) {
  num? amount;
  for (final k in ['amount', 'quantity', 'count', 'value']) {
    final v = item[k];
    if (v is num && v > 0) {
      amount = v;
      break;
    }
  }
  if (amount == null) return null;
  final rtype = '${item['type'] ?? item['currency'] ?? ''}'.toUpperCase();
  final isOrb = ['ORB', 'DISCORD_PRODUCT', 'CREDIT', 'COIN', 'TOKEN']
      .any((x) => rtype.contains(x));
  if (isOrb || amount >= 100) {
    return '${amount.toInt()} Discord Orbs';
  }
  return null;
}

String? _walkForReward(dynamic obj, {int depth = 0, bool skipApp = true}) {
  if (depth > 6) return null;
  if (obj is Map) {
    final orb = _orbLabel(obj);
    if (orb != null) return orb;
    for (final entry in obj.entries) {
      if (_rewardNameKeys.contains(entry.key) &&
          entry.value is String &&
          (entry.value as String).trim().isNotEmpty) {
        return (entry.value as String).trim();
      }
    }
    for (final k in _rewardContainers) {
      if (obj.containsKey(k)) {
        final hit = _walkForReward(obj[k], depth: depth + 1);
        if (hit != null) return hit;
      }
    }
    for (final entry in obj.entries) {
      if (_rewardContainers.contains(entry.key)) continue;
      if (skipApp && _appKeys.contains(entry.key)) continue;
      final hit = _walkForReward(entry.value, depth: depth + 1);
      if (hit != null) return hit;
    }
  } else if (obj is List) {
    for (final item in obj.take(5)) {
      final hit = _walkForReward(item, depth: depth + 1);
      if (hit != null) return hit;
    }
  }
  return null;
}

String getQuestReward(Map<String, dynamic> quest) {
  final cfgRaw = quest['config'];
  final cfg =
      cfgRaw is Map ? Map<String, dynamic>.from(cfgRaw) : <String, dynamic>{};

  final rcRaw = cfg['rewards_config'];
  final rc =
      rcRaw is Map ? Map<String, dynamic>.from(rcRaw) : <String, dynamic>{};

  final rewardsRaw = rc['rewards'];
  if (rewardsRaw is List && rewardsRaw.isNotEmpty) {
    final first = rewardsRaw.first;
    if (first is Map) {
      final msgs = first['messages'];
      if (msgs is Map) {
        final name = msgs['name'] ?? msgs['name_with_article'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
      final qty = first['orb_quantity'] ?? first['premium_orb_quantity'];
      if (qty is num && qty > 0) return '${qty.toInt()} Orbs';
    }
  }

  for (final key in [
    'rewardItems',
    'reward_items',
    'rewards',
    'prize',
    'prizes'
  ]) {
    final items = cfg[key];
    if (items is! List || items.isEmpty) continue;
    final item = items.first;
    if (item is String && item.trim().isNotEmpty) return item.trim();
    if (item is Map) {
      final msgs = item['messages'];
      if (msgs is Map) {
        final name = msgs['name'] ?? msgs['name_with_article'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
      final orb = _orbLabel(item);
      if (orb != null) return orb;
      for (final f in [
        'label',
        'item_name',
        'itemName',
        'displayName',
        'display_name'
      ]) {
        final v = item[f];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
  }

  final msgs = cfg['messages'];
  if (msgs is Map) {
    for (final key in [
      'rewardDescription',
      'reward_description',
      'rewardTitle',
      'reward_title',
      'rewardName',
      'reward_name',
    ]) {
      final v = msgs[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
  }

  final hit = _walkForReward(rc) ?? _walkForReward(cfg);
  if (hit != null && hit.length < 80) return hit;
  return '—';
}

String? getExpiresAt(Map<String, dynamic> quest) {
  final cfg = quest['config'];
  if (cfg is! Map) return null;
  final v = _get(cfg, ['expiresAt', 'expires_at']);
  return v is String ? v : null;
}

Map<String, dynamic> getUserStatus(Map<String, dynamic> quest) {
  final us = _get(quest, ['userStatus', 'user_status']);
  return us is Map ? Map<String, dynamic>.from(us) : <String, dynamic>{};
}

bool isEnrolled(Map<String, dynamic> quest) {
  final us = getUserStatus(quest);
  return _get(us, ['enrolledAt', 'enrolled_at']) != null;
}

bool isCompleted(Map<String, dynamic> quest) {
  final us = getUserStatus(quest);
  return _get(us, ['completedAt', 'completed_at']) != null;
}

String? getTaskType(Map<String, dynamic> quest) {
  final tc = getTaskConfig(quest);
  if (tc == null) return null;
  final tasks = tc['tasks'];
  if (tasks is! Map) return null;
  for (final t in kSupportedTasks) {
    if (tasks[t] != null) return t;
  }
  return null;
}

List<String> getRawTaskKeys(Map<String, dynamic> quest) {
  final tc = getTaskConfig(quest);
  if (tc == null) return const [];
  final tasks = tc['tasks'];
  if (tasks is! Map) return const [];
  return tasks.keys.map((e) => e.toString()).toList();
}

bool isCompletable(Map<String, dynamic> quest) {
  final expires = getExpiresAt(quest);
  if (expires != null) {
    try {
      final dt = DateTime.parse(expires.replaceFirst('Z', '+00:00'));
      if (!dt.isAfter(DateTime.now().toUtc())) return false;
    } catch (_) {
      // biarkan lolos
    }
  }
  final tc = getTaskConfig(quest);
  if (tc == null) return false;
  final tasks = tc['tasks'];
  if (tasks is! Map) return false;
  return kSupportedTasks.any((t) => tasks[t] != null);
}

int getSecondsNeeded(Map<String, dynamic> quest) {
  final tc = getTaskConfig(quest);
  final tt = getTaskType(quest);
  if (tc == null || tt == null) return 0;
  final tasks = tc['tasks'];
  if (tasks is! Map) return 0;
  final task = tasks[tt];
  if (task is! Map) return 0;
  final target = task['target'];
  return target is num ? target.toInt() : 0;
}

double getSecondsDone(Map<String, dynamic> quest) {
  final tt = getTaskType(quest);
  if (tt == null) return 0;
  final us = getUserStatus(quest);
  final progress = us['progress'];
  if (progress is! Map) return 0;
  final entry = progress[tt];
  if (entry is! Map) return 0;
  final v = entry['value'];
  return v is num ? v.toDouble() : 0;
}

String? getEnrolledAt(Map<String, dynamic> quest) {
  final us = getUserStatus(quest);
  final v = _get(us, ['enrolledAt', 'enrolled_at']);
  return v is String ? v : null;
}
