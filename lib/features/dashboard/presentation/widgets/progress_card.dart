import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import 'seele_mascot.dart';

class ProgressCard extends StatelessWidget {
  final int completedQuests;
  final int totalQuests;
  final int streakDays;

  const ProgressCard({
    super.key,
    this.completedQuests = 3,
    this.totalQuests = 5,
    this.streakDays = 5,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQuests > 0 ? completedQuests / totalQuests : 0.0;
    final remaining = totalQuests - completedQuests;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 210),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColor.cardBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF111C2D),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background ambient soft glow
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.lime.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Progress details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lime.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                              border: Border.all(
                                color: AppColor.lime.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.track_changes_rounded,
                                  color: AppColor.lime,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'DAILY PROGRESS',
                                  style: TextStyle(
                                    color: AppColor.lime,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Large Counter
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '0$completedQuests',
                              style: const TextStyle(
                                color: AppColor.lime,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '/ 0$totalQuests',
                              style: const TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Text(
                              'QUESTS',
                              style: TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Playful Segmented / Notched Progress Bar
                      LayoutBuilder(
                        builder: (context, barConstraints) {
                          final barWidth = barConstraints.maxWidth > 320
                              ? 320.0
                              : barConstraints.maxWidth;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  // Base track
                                  Container(
                                    width: barWidth,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColor.surfaceLight,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.pill),
                                      border: Border.all(
                                        color: AppColor.cardBorder,
                                        width: 1,
                                      ),
                                    ),
                                  ),

                                  // Filled progress track with 3D tactile top
                                  Container(
                                    width: barWidth * progress,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColor.lime,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.pill),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColor.limeDark,
                                          offset: Offset(0, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Milestone dots along the track
                                  SizedBox(
                                    width: barWidth,
                                    height: 12,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        totalQuests,
                                        (index) {
                                          final isPassed =
                                              index < completedQuests;
                                          return Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isPassed
                                                  ? AppColor.background
                                                  : AppColor.cardBorder,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Streak & Completion Status (Pure Statistics, No Reward/Bonus Claims)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.surfaceLight,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.pill),
                                      border: Border.all(
                                        color: AppColor.amber
                                            .withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: AppColor.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$streakDays Days',
                                          style: const TextStyle(
                                            color: AppColor.amber,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      '$completedQuests of $totalQuests completed today',
                                      style: const TextStyle(
                                        color: AppColor.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Right: Cute Seele Mascot illustrative accent
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SeeleMascot(
                      size: 78,
                      expression: MascotExpression.cheering,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'SEELE',
                      style: TextStyle(
                        color: AppColor.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
