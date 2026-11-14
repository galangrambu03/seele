import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final AccountSession? accountSession;

  const DashboardSidebar({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.accountSession,
  });

  @override
  Widget build(BuildContext context) {
    final account = accountSession?.accountInfo;
    final username = account?.effectiveDisplayName ?? 'Seele Explorer';
    final avatarUrl = account?.avatarUrl;

    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'S';

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColor.surface,
        border: Border(
          right: BorderSide(color: AppColor.cardBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
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
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Navigation
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
            onTap: () => onDestinationSelected?.call(1),
          ),
          const SizedBox(height: AppSpacing.sm),

          _SidebarNavItem(
            icon: Icons.account_circle_rounded,
            label: 'Account',
            selected: selectedIndex == 5,
            onTap: () => onDestinationSelected?.call(5),
          ),

          const Spacer(),

          // Discord Profile
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColor.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColor.cardBorder, width: 1.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return _buildFallbackAvatar(initial);
                            },
                          )
                        : _buildFallbackAvatar(initial),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        accountSession?.isConnected == true
                            ? 'Discord Account'
                            : 'Not connected',
                        style: const TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (accountSession?.isConnected == true)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColor.lime,
                    size: 17,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColor.cyan,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(color: AppColor.cyanDark, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          accountSession?.isConnected == true ? initial : 'S8',
          style: const TextStyle(
            color: AppColor.background,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
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
            ],
          ),
        ),
      ),
    );
  }
}
