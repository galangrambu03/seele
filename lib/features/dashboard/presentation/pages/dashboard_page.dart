import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../quests/presentation/pages/quests_page.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/orbs_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/quest_section.dart';
import '../../../account/presentation/pages/account_page.dart';

class DashboardPage extends StatefulWidget {
  final int initialNavIndex;

  const DashboardPage({
    super.key,
    this.initialNavIndex = 0,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          backgroundColor: AppColor.background,
          bottomNavigationBar: isDesktop
              ? null
              : DashboardBottomNav(
                  currentIndex: _currentNavIndex,
                  onTap: (index) => setState(() => _currentNavIndex = index),
                ),
          body: Row(
            children: [
              // Desktop Sidebar
              if (isDesktop)
                DashboardSidebar(
                  selectedIndex: _currentNavIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _currentNavIndex = index),
                ),

              // Main Content Area (Switches based on selected nav tab)
              Expanded(
                child: _currentNavIndex == 1
                    ? QuestsPage(
                        embedded: true,
                        onNavigate: (index) => setState(() => _currentNavIndex = index),
                      )
                    : _currentNavIndex == 5
                        ? const AccountPage()
                        : SafeArea(
                            child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isDesktop ? AppSpacing.xl : AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1100,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. User Profile & Welcome Header
                                  const DashboardHeader(
                                    username: 'StarGazer',
                                    userLevel: 8,
                                    streakDays: 5,
                                  ),

                                  const SizedBox(height: AppSpacing.xl),

                                  // 2. Daily Progress & Discord Orbs Balance
                                  if (isDesktop)
                                    const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: ProgressCard(
                                            completedQuests: 3,
                                            totalQuests: 5,
                                            streakDays: 5,
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          flex: 2,
                                          child: OrbsCard(
                                            balance: 1250,
                                            earnedToday: 150,
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    const ProgressCard(
                                      completedQuests: 3,
                                      totalQuests: 5,
                                      streakDays: 5,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    const OrbsCard(
                                      balance: 1250,
                                      earnedToday: 150,
                                    ),
                                  ],

                                  const SizedBox(height: AppSpacing.xxl),

                                  // 3. Quest Section with Filters & Responsive Grid
                                  QuestSection(
                                    onViewAll: () =>
                                        setState(() => _currentNavIndex = 1),
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
  }
}
