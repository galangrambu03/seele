import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';

class DashboardSidebar extends StatelessWidget {
  final AccountSession accountSession;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DashboardSidebar({
    super.key,
    required this.accountSession,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColor.background,
        border: Border(
          right: BorderSide(color: AppColor.cardBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo / Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Ikon Seele (Menggantikan Ikon Petir)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.asset(
                      'assets/images/seele_icon_app.jpg', // Pastikan nama file ini benar
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SEELE',
                        style: TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.cyanDark.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: const Text(
                          'QUESTS',
                          style: TextStyle(
                            color: AppColor.cyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Menu Navigasi ─────────────────────────────────────────────
            _buildNavItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.flag_rounded,
              label: 'Quests',
            ),
            _buildNavItem(
              index: 5,
              icon: Icons.person_rounded,
              label: 'Account',
            ),

            const SizedBox(height: AppSpacing.lg),
            
            // Garis pemisah (Opsional, biar rapi)
            const Divider(color: AppColor.cardBorder, height: 1, indent: 24, endIndent: 24),

            const SizedBox(height: AppSpacing.lg),

            // ── Kartu Profil (Dipindah ke Atas) ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildProfileCard(),
            ),

            const Spacer(), // Mendorong sisa ruang ke bawah
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: isSelected ? AppColor.lime.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColor.lime : AppColor.textMuted,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColor.lime : AppColor.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final info = accountSession.accountInfo;
    final isConnected = accountSession.isConnected;
    
    // Gunakan inisial jika avatarUrl kosong (menghindari error)
    final displayName = info?.effectiveDisplayName ?? 'Guest';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.surfaceLight,
              shape: BoxShape.circle,
              image: (info?.avatarUrl != null && info!.avatarUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(info.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (info?.avatarUrl == null || info!.avatarUrl!.isEmpty)
                ? Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          
          // Nama & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isConnected ? 'Discord Account' : 'Not connected',
                  style: TextStyle(
                    color: isConnected ? AppColor.textSecondary : AppColor.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Centang (Jika terhubung)
          if (isConnected)
            const Icon(Icons.check_circle_rounded, color: AppColor.lime, size: 18),
        ],
      ),
    );
  }
}