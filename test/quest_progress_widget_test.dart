import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:discord_quest_seele/features/quests/data/repositories/mock_quest_repository.dart';
import 'package:discord_quest_seele/features/quests/domain/entities/quest_entity.dart';
import 'package:discord_quest_seele/features/quests/presentation/pages/quests_page.dart';
import 'package:discord_quest_seele/core/theme/app_theme.dart';

void main() {
  testWidgets('QuestsPage updates progress when repository changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repository = MockQuestRepository(
      customQuests: [
        Quest(
          id: 'test-quest',
          title: 'Test Progress Quest',
          description: 'Testing reactive progress',
          category: QuestCategory.video,
          status: QuestStatus.inProgress,
          rewardOrbs: 100,
          duration: '100 sec',
          progress: 0,
          targetSeconds: 100,
        ),
      ],
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: QuestsPage(repository: repository),
      ),
    );

    expect(find.text('Test Progress Quest'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    repository.updateProgress('test-quest', 50);
    await tester.pump();

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
  });
}
