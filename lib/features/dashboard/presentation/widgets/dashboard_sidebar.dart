import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import 'discord_orb_icon.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const DashboardSidebar({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColor.surface,
        border: Border(
          right: BorderSide(
            color: AppColor.cardBorder,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.lime,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColor.limeDark,
                        offset: Offset(0, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      color: AppColor.background,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEELE',
                      style: TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.cyan.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: const Text(
                            'QUESTS',
                            style: TextStyle(
                              color: AppColor.cyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // 2. Navigation Items
          _SidebarNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected?.call(0),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SidebarNavItem(
            icon: Icons.flag_rounded,
            label: 'Quests',
            selected: selectedIndex == 1,
            badge: '4',
            badgeColor: AppColor.amber,
            onTap: () => onDestinationSelected?.call(1),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SidebarNavItem(
            customIcon: const DiscordOrbIcon(size: 20),
            label: 'Orbs Vault',
            selected: selectedIndex == 2,
            onTap: () => onDestinationSelected?.call(2),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SidebarNavItem(
            icon: Icons.leaderboard_rounded,
            label: 'Leaderboard',
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected?.call(3),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SidebarNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            selected: selectedIndex == 4,
            onTap: () => onDestinationSelected?.call(4),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SidebarNavItem(
            icon: Icons.account_circle_rounded,
            label: 'Account',
            selected: selectedIndex == 5,
            onTap: () => onDestinationSelected?.call(5),
          ),

          const Spacer(),

          // 3. User Level & Streak Footer Widget
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColor.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColor.cardBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColor.cyan,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColor.cyanDark,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'S8',
                          style: TextStyle(
                            color: AppColor.background,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seele Explorer',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Level 8 • 850 XP',
                            style: TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: const LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 6,
                    backgroundColor: AppColor.surfaceLight,
                    color: AppColor.lime,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool selected;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    this.icon,
    this.customIcon,
    required this.label,
    this.selected = false,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: AppColor.surfaceLight.withValues(alpha: 0.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.lime.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: selected
                ? Border.all(
                    color: AppColor.lime.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (customIcon != null)
                customIcon!
              else if (icon != null)
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColor.lime : AppColor.textSecondary,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColor.lime : AppColor.textSecondary,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColor.lime),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColor.background,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
