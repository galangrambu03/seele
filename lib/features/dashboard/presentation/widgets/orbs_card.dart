import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import 'discord_orb_icon.dart';
import 'tactile_button.dart';

class OrbsCard extends StatelessWidget {
  final int balance;
  final int earnedToday;
  final VoidCallback? onRedeem;

  const OrbsCard({
    super.key,
    this.balance = 1250,
    this.earnedToday = 150,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 210),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColor.lavenderDark.withValues(alpha: 0.4),
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
          // Ambient lavender/cyan gradient in background
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.lavender.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Header tag & mini status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lavender.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: AppColor.lavender.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DiscordOrbIcon(size: 14),
                          SizedBox(width: 5),
                          Text(
                            'DISCORD ORBS',
                            style: TextStyle(
                              color: AppColor.lavender,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: AppColor.cyan,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+$earnedToday today',
                            style: const TextStyle(
                              color: AppColor.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Center row: Orb graphic + Large balance display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const DiscordOrbIcon(
                      size: 64,
                      glowing: true,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balance.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Available to spend on perks',
                            style: TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Bottom row: Tactile Action buttons ("Redeem Perks" & "History")
                Row(
                  children: [
                    Expanded(
                      child: TactileButton(
                        label: 'Redeem Perks',
                        color: TactileColor.lavender,
                        height: 38,
                        fontSize: 12,
                        icon: const Icon(
                          Icons.card_giftcard_rounded,
                          size: 16,
                          color: AppColor.background,
                        ),
                        onPressed: onRedeem,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: AppColor.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColor.cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.history_rounded,
                          color: AppColor.textSecondary,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
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
