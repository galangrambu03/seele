import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../domain/entities/quest_entity.dart';

enum QuestSortOption {
  category,
  status,
  rewardHighToLow,
  nameAscending;

  String get displayName {
    switch (this) {
      case QuestSortOption.category:
        return 'Category';
      case QuestSortOption.status:
        return 'Status';
      case QuestSortOption.rewardHighToLow:
        return 'Reward (High to Low)';
      case QuestSortOption.nameAscending:
        return 'Name (A-Z)';
    }
  }
}

class QuestFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final QuestCategory? selectedCategory;
  final ValueChanged<QuestCategory?> onCategorySelected;
  final QuestStatus? selectedStatus;
  final ValueChanged<QuestStatus?> onStatusSelected;
  final QuestSortOption selectedSort;
  final ValueChanged<QuestSortOption> onSortChanged;

  const QuestFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar & Sort Dropdown Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;

            final searchField = Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColor.cardBorder,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search quests by title or keyword...',
                  hintStyle: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColor.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColor.textSecondary,
                          ),
                          onPressed: onClearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                ),
              ),
            );

            final sortButton = Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColor.cardBorder,
                  width: 1.5,
                ),
              ),
              child: PopupMenuButton<QuestSortOption>(
                initialValue: selectedSort,
                onSelected: onSortChanged,
                color: AppColor.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(
                    color: AppColor.cardBorder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sort_rounded,
                      color: AppColor.lime,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sort: ${selectedSort.displayName}',
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColor.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                itemBuilder: (context) {
                  return QuestSortOption.values.map((option) {
                    final isChecked = option == selectedSort;
                    return PopupMenuItem<QuestSortOption>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            isChecked
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: isChecked
                                ? AppColor.lime
                                : AppColor.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option.displayName,
                            style: TextStyle(
                              color: isChecked
                                  ? AppColor.lime
                                  : AppColor.textPrimary,
                              fontWeight: isChecked
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            );

            if (isSmall) {
              return Column(
                children: [
                  searchField,
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: sortButton),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: AppSpacing.md),
                sortButton,
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // 2. Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All Categories',
                isSelected: selectedCategory == null,
                icon: Icons.auto_awesome_mosaic_rounded,
                selectedColor: AppColor.lime,
                onTap: () => onCategorySelected(null),
              ),
              const SizedBox(width: AppSpacing.sm),
              ...QuestCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _FilterChip(
                    label: cat.displayName,
                    isSelected: selectedCategory == cat,
                    icon: cat.iconData,
                    selectedColor: cat.accentColor,
                    onTap: () => onCategorySelected(
                      selectedCategory == cat ? null : cat,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 3. Status Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusPill(
                label: 'All Status',
                isSelected: selectedStatus == null,
                onTap: () => onStatusSelected(null),
              ),
              const SizedBox(width: AppSpacing.xs),
              ...QuestStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: _StatusPill(
                    label: status.displayName,
                    isSelected: selectedStatus == status,
                    badgeColor: status.badgeColor,
                    onTap: () => onStatusSelected(
                      selectedStatus == status ? null : status,
                    ),
                  ),
                );
              }),
            ],
          ),
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

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _StatusPill({
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
