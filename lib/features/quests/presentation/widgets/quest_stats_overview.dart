import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';

class QuestStatsOverview extends StatelessWidget {
  final int totalCount;
  final int availableCount;
  final int inProgressCount;
  final int completedCount;
  final ValueChanged<String?>? onStatCardTap;

  const QuestStatsOverview({
    super.key,
    required this.totalCount,
    required this.availableCount,
    required this.inProgressCount,
    required this.completedCount,
    this.onStatCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 680;
        final isVeryNarrow = constraints.maxWidth < 420;

        if (isVeryNarrow) {
          return Column(
            children: [
              _StatCard(
                label: 'TOTAL QUESTS',
                count: totalCount,
                accentColor: AppColor.textPrimary,
                icon: Icons.auto_awesome_mosaic_rounded,
                onTap: () => onStatCardTap?.call(null),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatCard(
                label: 'AVAILABLE',
                count: availableCount,
                accentColor: AppColor.lime,
                icon: Icons.radio_button_unchecked_rounded,
                onTap: () => onStatCardTap?.call('available'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatCard(
                label: 'IN PROGRESS',
                count: inProgressCount,
                accentColor: AppColor.cyan,
                icon: Icons.hourglass_top_rounded,
                onTap: () => onStatCardTap?.call('inProgress'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatCard(
                label: 'COMPLETED',
                count: completedCount,
                accentColor: AppColor.success,
                icon: Icons.check_circle_rounded,
                onTap: () => onStatCardTap?.call('completed'),
              ),
            ],
          );
        }

        if (isNarrow) {
          // 2x2 Grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'TOTAL QUESTS',
                      count: totalCount,
                      accentColor: AppColor.textPrimary,
                      icon: Icons.auto_awesome_mosaic_rounded,
                      onTap: () => onStatCardTap?.call(null),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'AVAILABLE',
                      count: availableCount,
                      accentColor: AppColor.lime,
                      icon: Icons.radio_button_unchecked_rounded,
                      onTap: () => onStatCardTap?.call('available'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'IN PROGRESS',
                      count: inProgressCount,
                      accentColor: AppColor.cyan,
                      icon: Icons.hourglass_top_rounded,
                      onTap: () => onStatCardTap?.call('inProgress'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'COMPLETED',
                      count: completedCount,
                      accentColor: AppColor.success,
                      icon: Icons.check_circle_rounded,
                      onTap: () => onStatCardTap?.call('completed'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // 4 in a row for Desktop & wide tablets
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL QUESTS',
                count: totalCount,
                accentColor: AppColor.textPrimary,
                icon: Icons.auto_awesome_mosaic_rounded,
                onTap: () => onStatCardTap?.call(null),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'AVAILABLE',
                count: availableCount,
                accentColor: AppColor.lime,
                icon: Icons.radio_button_unchecked_rounded,
                onTap: () => onStatCardTap?.call('available'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'IN PROGRESS',
                count: inProgressCount,
                accentColor: AppColor.cyan,
                icon: Icons.hourglass_top_rounded,
                onTap: () => onStatCardTap?.call('inProgress'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'COMPLETED',
                count: completedCount,
                accentColor: AppColor.success,
                icon: Icons.check_circle_rounded,
                onTap: () => onStatCardTap?.call('completed'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColor.cardBorder,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF111C2D),
                offset: Offset(0, 3.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count < 10 ? '0$count' : '$count',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
