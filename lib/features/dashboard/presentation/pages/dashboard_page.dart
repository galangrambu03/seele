import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';
import '../../../quests/presentation/pages/quests_page.dart';
import '../../../quests/data/repositories/mock_quest_repository.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/quest_section.dart';

class DashboardPage extends StatefulWidget {
  final int initialNavIndex;
  final AccountSession accountSession;

  const DashboardPage({
    super.key,
    this.initialNavIndex = 0,
    required this.accountSession,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _questRepository = MockQuestRepository();
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.accountSession,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;

            final username =
                widget.accountSession.accountInfo?.effectiveDisplayName ??
                'Guest';

            return Scaffold(
              backgroundColor: AppColor.background,
              bottomNavigationBar: isDesktop
                  ? null
                  : DashboardBottomNav(
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),
              body: Row(
                children: [
                  if (isDesktop)
                    DashboardSidebar(
                      accountSession: widget.accountSession,
                      selectedIndex: _currentNavIndex,
                      onDestinationSelected: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),

                  Expanded(
                    child: _currentNavIndex == 1
                        ? QuestsPage(
                            repository: _questRepository,
                            embedded: true,
                            onNavigate: (index) {
                              setState(() => _currentNavIndex = index);
                            },
                          )
                        : _currentNavIndex == 5
                        ? AccountPage(accountSession: widget.accountSession)
                        : SafeArea(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop
                                    ? AppSpacing.xl
                                    : AppSpacing.md,
                                vertical: AppSpacing.lg,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dashboard',
                                        style: const TextStyle(
                                          color: AppColor.textPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.xs),

                                      Text(
                                        'Welcome back, $username!',
                                        style: const TextStyle(
                                          color: AppColor.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),

                                      QuestSection(
                                        repository: _questRepository,
                                        onViewAll: () {
                                          setState(() {
                                            _currentNavIndex = 1;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
