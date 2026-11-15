import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:discord_quest_seele/core/session/account_session.dart';
import 'package:discord_quest_seele/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:discord_quest_seele/features/quests/presentation/pages/quests_page.dart';
import 'package:discord_quest_seele/features/quests/presentation/widgets/quest_detail_modal.dart';
import 'package:discord_quest_seele/core/theme/app_theme.dart';

void main() {
  Future<void> waitForDashboard(WidgetTester tester) async {
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));

      if (find.text('Dashboard').evaluate().isNotEmpty) {
        return;
      }

      final errorFinder = find.textContaining('Gagal memuat quest:');
      if (errorFinder.evaluate().isNotEmpty) {
        final errorText = tester.widget<Text>(errorFinder.first).data;
        fail('Dashboard gagal memuat quest: $errorText');
      }
    }

    final visibleTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .toList();

    final exception = tester.takeException();
    final scaffoldCount = find.byType(Scaffold).evaluate().length;
    final spinnerCount = find
        .byType(CircularProgressIndicator)
        .evaluate()
        .length;

    fail(
      'Dashboard tidak muncul setelah 5 detik. '
      'Scaffold: $scaffoldCount, '
      'Spinner: $spinnerCount, '
      'Exception: $exception, '
      'Teks UI: $visibleTexts',
    );
  }

  testWidgets('Dashboard renders simplified SEELE layout', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final session = AccountSession();
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DashboardPage(accountSession: session),
      ),
    );
    await waitForDashboard(tester);

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Welcome back, Guest!'), findsOneWidget);
    expect(find.text('Available quests'), findsOneWidget);

    // Dummy statistics should no longer appear.
    expect(find.text('DAILY PROGRESS'), findsNothing);
    expect(find.text('DISCORD ORBS'), findsNothing);
    expect(find.text('1,250'), findsNothing);
    expect(find.text('Level 8 • 850 XP'), findsNothing);
  });

  testWidgets('Dashboard renders mobile layout with bottom navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final session = AccountSession();
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DashboardPage(accountSession: session),
      ),
    );
    await waitForDashboard(tester);

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Welcome back, Guest!'), findsOneWidget);

    // Bottom navigation should be available on mobile.
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets(
    'Dedicated Quests Page renders overview, filters, and mock banner',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.darkTheme, home: const QuestsPage()),
      );

      expect(find.text('Quests Hub'), findsOneWidget);
      expect(find.textContaining('Mock Data'), findsOneWidget);

      expect(find.text('TOTAL QUESTS'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsAtLeastNWidgets(1));
      expect(find.text('IN PROGRESS'), findsAtLeastNWidgets(1));
      expect(find.text('COMPLETED'), findsAtLeastNWidgets(1));

      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('All Status'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Devstream');
      await tester.pumpAndSettle();

      expect(find.text('Watch Devstream Episode #4'), findsOneWidget);
      expect(find.text('Conquer the Cyber Labyrinth'), findsNothing);

      await tester.tap(find.text('Watch Devstream Episode #4'));
      await tester.pumpAndSettle();

      expect(find.byType(QuestDetailModal), findsOneWidget);
      expect(find.text('QUEST REQUIREMENTS'), findsOneWidget);
      expect(find.text('+150 Orbs'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets('Navigation from Dashboard sidebar opens Quests Page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final session = AccountSession();
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DashboardPage(accountSession: session),
      ),
    );
    await waitForDashboard(tester);

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Quests'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Quests Hub'), findsOneWidget);
    expect(find.text('TOTAL QUESTS'), findsOneWidget);
  });
}
