import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../quests/data/repositories/mock_quest_repository.dart';
import '../../../quests/presentation/widgets/quest_detail_modal.dart';
import '../../domain/entities/quest_entity.dart';
import 'quest_card.dart';

class QuestSection extends StatefulWidget {
  final List<Quest>? quests;
  final VoidCallback? onViewAll;

  const QuestSection({
    super.key,
    this.quests,
    this.onViewAll,
  });

  @override
  State<QuestSection> createState() => _QuestSectionState();
}

class _QuestSectionState extends State<QuestSection> {
  QuestCategory? _selectedCategory; // null = all
  QuestStatus? _selectedStatus; // null = all

  late List<Quest> _allQuests;

  @override
  void initState() {
    super.initState();
    _allQuests = widget.quests ?? MockQuestRepository().getAllQuests();
  }

  List<Quest> get _filteredQuests {
    return _allQuests.where((quest) {
      if (_selectedCategory != null && quest.category != _selectedCategory) {
        return false;
      }
      if (_selectedStatus != null && quest.status != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
                      color: AppColor.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: const Text(
                      'MISSION BOARD',
                      style: TextStyle(
                        color: AppColor.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Available quests',
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),
            // Quest Count Indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColor.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColor.cardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                '${filtered.length} Quests',
                style: const TextStyle(
                  color: AppColor.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (widget.onViewAll != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: widget.onViewAll,
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppColor.lime,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Interactive Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All Categories',
                isSelected: _selectedCategory == null,
                icon: Icons.auto_awesome_mosaic_rounded,
                selectedColor: AppColor.lime,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              const SizedBox(width: AppSpacing.sm),
              ...QuestCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _FilterChip(
                    label: cat.displayName,
                    isSelected: _selectedCategory == cat,
                    icon: cat.iconData,
                    selectedColor: cat.accentColor,
                    onTap: () => setState(() {
                      _selectedCategory =
                          _selectedCategory == cat ? null : cat;
                    }),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusFilterPill(
                label: 'All Status',
                isSelected: _selectedStatus == null,
                onTap: () => setState(() => _selectedStatus = null),
              ),
              const SizedBox(width: AppSpacing.xs),
              ...QuestStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: _StatusFilterPill(
                    label: status.displayName,
                    isSelected: _selectedStatus == status,
                    badgeColor: status.badgeColor,
                    onTap: () => setState(() {
                      _selectedStatus =
                          _selectedStatus == status ? null : status;
                    }),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Responsive Quest Grid
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColor.cardBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.filter_alt_off_rounded,
                  size: 40,
                  color: AppColor.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No quests match your selected filters',
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Try resetting filters to discover more challenges.',
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedStatus = null;
                    });
                  },
                  child: const Text(
                    'Reset Filters',
                    style: TextStyle(
                      color: AppColor.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 720;
              const spacing = AppSpacing.md;

              if (isTwoColumn) {
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: filtered.map((quest) {
                    return SizedBox(
                      width: cardWidth,
                      child: QuestCard(
                        quest: quest,
                        onTap: () => QuestDetailModal.show(context, quest),
                        onAction: () => QuestDetailModal.show(context, quest),
                      ),
                    );
                  }).toList(),
                );
              }

              // Single Column for mobile
              return Column(
                children: filtered.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: QuestCard(
                      quest: quest,
                      onTap: () => QuestDetailModal.show(context, quest),
                      onAction: () => QuestDetailModal.show(context, quest),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color selectedColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColor.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? selectedColor : AppColor.cardBorder,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.35),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColor.background : AppColor.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColor.background : AppColor.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _StatusFilterPill({
    required this.label,
    required this.isSelected,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColor.textPrimary : AppColor.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
