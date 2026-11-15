import 'package:flutter_test/flutter_test.dart';
import 'package:discord_quest_seele/features/quests/data/mappers/quest_mapper.dart';
import 'package:discord_quest_seele/features/quests/data/parsers/quest_parser.dart';
import 'package:discord_quest_seele/features/quests/domain/entities/quest_entity.dart';

void main() {
  group('QuestMapper', () {
    test('achievement tidak dianggap sebagai durasi detik', () {
      const parsed = ParsedQuest(
        id: 'achievement-1',
        name: 'Complete Achievement',
        description: 'Complete an in-game achievement.',
        reward: '100 Discord Orbs',
        expiresAt: null,
        taskType: 'ACHIEVEMENT_IN_ACTIVITY',
        secondsNeeded: 5,
        secondsDone: 2,
        enrolled: true,
        completed: false,
        completable: true,
        rawTaskKeys: ['ACHIEVEMENT_IN_ACTIVITY'],
        appId: '123',
        eventName: 'progress',
        achievementTarget: 5,
      );

      final quest = QuestMapper.toEntity(parsed);

      expect(quest.targetSeconds, isNull);
      expect(quest.completedSeconds, 0);
      expect(quest.taskMetadata['achievementTarget'], 5);
      expect(quest.progress, closeTo(0.4, 0.001));
      expect(quest.status, QuestStatus.inProgress);
      expect(quest.category, QuestCategory.activity);
    });

    test('video tetap menggunakan target durasi detik', () {
      const parsed = ParsedQuest(
        id: 'video-1',
        name: 'Watch Video',
        description: 'Watch for 15 minutes.',
        reward: '150 Discord Orbs',
        expiresAt: null,
        taskType: 'WATCH_VIDEO',
        secondsNeeded: 900,
        secondsDone: 300,
        enrolled: true,
        completed: false,
        completable: true,
        rawTaskKeys: ['WATCH_VIDEO'],
        appId: null,
        eventName: 'progress',
        achievementTarget: 1,
      );

      final quest = QuestMapper.toEntity(parsed);

      expect(quest.targetSeconds, 900);
      expect(quest.completedSeconds, 300);
      expect(quest.progress, closeTo(1 / 3, 0.001));
      expect(quest.category, QuestCategory.video);
    });
  });
}
