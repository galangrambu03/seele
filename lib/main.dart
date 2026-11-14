import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'core/session/account_session.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  runApp(const DiscordQuestApp());
}

class DiscordQuestApp extends StatefulWidget {
  const DiscordQuestApp({super.key});

  @override
  State<DiscordQuestApp> createState() => _DiscordQuestAppState();
}

class _DiscordQuestAppState extends State<DiscordQuestApp> {
  late final AccountSession _accountSession;

  @override
  void initState() {
    super.initState();

    _accountSession = AccountSession();
    _accountSession.restoreSession();
  }

  @override
  void dispose() {
    _accountSession.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEELE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: DashboardPage(accountSession: _accountSession),
    );
  }
}
