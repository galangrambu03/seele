import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import 'discord_orb_icon.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DashboardBottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        border: const Border(
          top: BorderSide(color: AppColor.cardBorder, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            selected: currentIndex == 0,
            onTap: () => onTap?.call(0),
          ),
          _BottomNavItem(
            icon: Icons.flag_rounded,
            label: 'Quests',
            selected: currentIndex == 1,
            onTap: () => onTap?.call(1),
          ),
          _BottomNavItem(
            customIcon: const DiscordOrbIcon(size: 22),
            label: 'Orbs',
            selected: currentIndex == 2,
            onTap: () => onTap?.call(2),
          ),
          _BottomNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: currentIndex == 3,
            onTap: () => onTap?.call(3),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _BottomNavItem({
    this.icon,
    this.customIcon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.lime.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customIcon != null)
                customIcon!
              else if (icon != null)
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColor.lime : AppColor.textSecondary,
                ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColor.lime : AppColor.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
