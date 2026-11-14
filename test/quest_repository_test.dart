import 'package:flutter_test/flutter_test.dart';
import 'package:discord_quest_seele/features/quests/data/repositories/mock_quest_repository.dart';
import 'package:discord_quest_seele/features/quests/domain/entities/quest_entity.dart';

void main() {
  test('updateProgress updates progress, status, and notifies listeners', () {
    final repository = MockQuestRepository(
      customQuests: [
        Quest(
          id: 'test-quest',
          title: 'Test Quest',
          description: 'Testing progress',
          category: QuestCategory.video,
          status: QuestStatus.available,
          rewardOrbs: 100,
          duration: '100 sec',
          progress: 0,
          targetSeconds: 100,
        ),
      ],
    );

    var notifications = 0;
    repository.addListener(() => notifications++);

    repository.updateProgress('test-quest', 50);

    var quest = repository.getQuestById('test-quest')!;

    expect(quest.progress, closeTo(0.5, 0.001));
    expect(quest.completedSeconds, 50);
    expect(quest.status, QuestStatus.inProgress);
    expect(notifications, 1);

    repository.updateProgress('test-quest', 100);

    quest = repository.getQuestById('test-quest')!;

    expect(quest.progress, 1.0);
    expect(quest.status, QuestStatus.completed);
    expect(notifications, 2);

    repository.dispose();
  });
}
