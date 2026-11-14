import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';

class DashboardHeader extends StatelessWidget {
  final String username;
  final int userLevel;
  final int streakDays;

  const DashboardHeader({
    super.key,
    this.username = 'StarGazer',
    this.userLevel = 8,
    this.streakDays = 5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Greeting & Welcome text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.lime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: AppColor.lime.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'SEELE QUEST HUB',
                      style: TextStyle(
                        color: AppColor.lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: isCompact ? 24 : 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Complete daily quests to claim your Discord Orbs reward.',
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Right: Streak pill + Notification + Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompact) ...[
                  // Streak Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColor.amber.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColor.amberDark,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColor.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streakDays Days',
                          style: const TextStyle(
                            color: AppColor.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],

                // Notification Icon Button
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.surface,
                        foregroundColor: AppColor.textPrimary,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: const BorderSide(
                            color: AppColor.cardBorder,
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.notifications_outlined,
                        size: 21,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColor.lime,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppSpacing.sm),

                // User Avatar with Level Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColor.surfaceHighlight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColor.lime,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColor.limeDark,
                            offset: Offset(0, 2.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColor.lime,
                          size: 26,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.cyan,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColor.cyanDark,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Text(
                          'LV$userLevel',
                          style: const TextStyle(
                            color: AppColor.background,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
