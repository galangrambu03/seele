import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discord_quest_seele/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:discord_quest_seele/features/dashboard/presentation/widgets/seele_mascot.dart';
import 'package:discord_quest_seele/features/dashboard/presentation/widgets/discord_orb_icon.dart';
import 'package:discord_quest_seele/features/quests/presentation/pages/quests_page.dart';
import 'package:discord_quest_seele/features/quests/presentation/widgets/quest_detail_modal.dart';
import 'package:discord_quest_seele/core/theme/app_theme.dart';

void main() {
  testWidgets('Dashboard renders correctly with playful SEELE components',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const DashboardPage(),
      ),
    );

    // Verify key text nodes from existing tests
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Available quests'), findsOneWidget);

    // Verify daily progress and orbs balance
    expect(find.text('DAILY PROGRESS'), findsOneWidget);
    expect(find.text('DISCORD ORBS'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);

    // Verify custom vector mascot and orb icons are rendered
    expect(find.byType(SeeleMascot), findsAtLeastNWidgets(1));
    expect(find.byType(DiscordOrbIcon), findsAtLeastNWidgets(1));
  });

  testWidgets('Dashboard renders mobile layout with bottom navigation',
      (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const DashboardPage(),
      ),
    );

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Available quests'), findsOneWidget);
  });

  testWidgets('Dedicated Quests Page renders overview, filters, and mock banner',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const QuestsPage(),
      ),
    );

    // 1. Overview Header & Mock Data Banner
    expect(find.text('Quests Hub'), findsOneWidget);
    expect(find.textContaining('Mock Data'), findsOneWidget);

    // 2. Overview Stats Cards
    expect(find.text('TOTAL QUESTS'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsAtLeastNWidgets(1));
    expect(find.text('IN PROGRESS'), findsAtLeastNWidgets(1));
    expect(find.text('COMPLETED'), findsAtLeastNWidgets(1));

    // 3. Search and Categories
    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('All Status'), findsOneWidget);

    // 4. Test Search filter
    await tester.enterText(find.byType(TextField), 'Devstream');
    await tester.pumpAndSettle();

    expect(find.text('Watch Devstream Episode #4'), findsOneWidget);
    expect(find.text('Conquer the Cyber Labyrinth'), findsNothing);

    // 5. Open Quest Detail Modal
    await tester.tap(find.text('Watch Devstream Episode #4'));
    await tester.pumpAndSettle();

    expect(find.byType(QuestDetailModal), findsOneWidget);
    expect(find.text('QUEST REQUIREMENTS'), findsOneWidget);
    expect(find.text('+150 Orbs'), findsAtLeastNWidgets(1));
  });

  testWidgets('Navigation from Dashboard sidebar opens Quests Page',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const DashboardPage(),
      ),
    );

    expect(find.text('Welcome back!'), findsOneWidget);

    // Tap 'Quests' on sidebar
    await tester.tap(find.text('Quests'));
    await tester.pumpAndSettle();

    // Now on Quests Hub
    expect(find.text('Quests Hub'), findsOneWidget);
    expect(find.text('TOTAL QUESTS'), findsOneWidget);
  });
}
