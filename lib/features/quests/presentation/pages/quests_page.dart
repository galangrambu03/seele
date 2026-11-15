import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/dashboard_sidebar.dart';
import '../../../dashboard/presentation/widgets/quest_card.dart';
import '../../data/repositories/mock_quest_repository.dart';
import '../../domain/entities/quest_entity.dart';
import '../../domain/engines/quest_engine.dart';
import '../../domain/repositories/quest_repository.dart';
import '../widgets/mock_data_banner.dart';
import '../widgets/quest_detail_modal.dart';
import '../widgets/quest_filter_bar.dart';
import '../widgets/quest_stats_overview.dart';

class QuestsPage extends StatefulWidget {
  final QuestRepository? repository;
  final QuestEngine? engine;
  final ValueChanged<int>? onNavigate;
  final bool embedded; // whether embedded inside main navigation shell

  const QuestsPage({
    super.key,
    this.repository,
    this.engine,
    this.onNavigate,
    this.embedded = false,
  });

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  late final QuestRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  QuestCategory? _selectedCategory;
  QuestStatus? _selectedStatus;
  QuestSortOption _selectedSort = QuestSortOption.category;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockQuestRepository();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Quest> get _processedQuests {
    final all = _repository.getAllQuests();

    // 1. Filter by Search Query
    final filtered = all.where((q) {
      if (_searchQuery.isNotEmpty) {
        final titleMatches = q.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final descMatches = q.description.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        if (!titleMatches && !descMatches) return false;
      }

      // 2. Filter by Category
      if (_selectedCategory != null && q.category != _selectedCategory) {
        return false;
      }

      // 3. Filter by Status
      if (_selectedStatus != null && q.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // 4. Sorting
    switch (_selectedSort) {
      case QuestSortOption.category:
        filtered.sort((a, b) => a.category.index.compareTo(b.category.index));
        break;
      case QuestSortOption.status:
        filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
      case QuestSortOption.rewardHighToLow:
        filtered.sort((a, b) => b.rewardOrbs.compareTo(a.rewardOrbs));
        break;
      case QuestSortOption.nameAscending:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  void _handleStatCardTap(String? statusFilter) {
    setState(() {
      if (statusFilter == 'available') {
        _selectedStatus = QuestStatus.available;
      } else if (statusFilter == 'inProgress') {
        _selectedStatus = QuestStatus.inProgress;
      } else if (statusFilter == 'completed') {
        _selectedStatus = QuestStatus.completed;
      } else {
        _selectedStatus = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;
            final processed = _processedQuests;

            final body = SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppSpacing.xl : AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                      color: AppColor.lime.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.xs,
                                      ),
                                      border: Border.all(
                                        color: AppColor.lime.withValues(
                                          alpha: 0.35,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'QUEST MANAGEMENT',
                                      style: TextStyle(
                                        color: AppColor.lime,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Quests Hub',
                                    style: TextStyle(
                                      color: AppColor.textPrimary,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Track, filter, and discover all available Discord missions.',
                                    style: TextStyle(
                                      color: AppColor.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Mock Data Banner indicator
                        if (_repository.isMockDataSource) ...[
                          MockDataBanner(label: _repository.dataSourceLabel),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // 1. Quest Overview Stats
                        QuestStatsOverview(
                          totalCount: _repository.getTotalQuestsCount(),
                          availableCount: _repository.getAvailableQuestsCount(),
                          inProgressCount: _repository
                              .getInProgressQuestsCount(),
                          completedCount: _repository.getCompletedQuestsCount(),
                          onStatCardTap: _handleStatCardTap,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 2. Quest Management: Search, Category, Status & Sorting
                        QuestFilterBar(
                          searchController: _searchController,
                          onSearchChanged: (val) =>
                              setState(() => _searchQuery = val),
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (cat) =>
                              setState(() => _selectedCategory = cat),
                          selectedStatus: _selectedStatus,
                          onStatusSelected: (status) =>
                              setState(() => _selectedStatus = status),
                          selectedSort: _selectedSort,
                          onSortChanged: (sort) =>
                              setState(() => _selectedSort = sort),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Active Results Count Bar
                        Row(
                          children: [
                            Text(
                              'Showing ${processed.length} of ${_repository.getTotalQuestsCount()} Quests',
                              style: const TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_selectedCategory != null ||
                                _selectedStatus != null ||
                                _searchQuery.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = null;
                                    _selectedStatus = null;
                                    _selectedSort = QuestSortOption.category;
                                  });
                                },
                                child: const Text(
                                  'Reset All',
                                  style: TextStyle(
                                    color: AppColor.lime,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // 3. Quest List
                        if (processed.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 48,
                              horizontal: 24,
                            ),
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
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 44,
                                  color: AppColor.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'No quests found matching your criteria',
                                  style: TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try adjusting your search terms or clearing active filters.',
                                  style: TextStyle(
                                    color: AppColor.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedCategory = null;
                                      _selectedStatus = null;
                                    });
                                  },
                                  child: const Text(
                                    'Clear All Filters',
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
                            builder: (context, gridConstraints) {
                              final isTwoCol = gridConstraints.maxWidth >= 720;
                              const spacing = AppSpacing.md;

                              if (isTwoCol) {
                                final cardWidth =
                                    (gridConstraints.maxWidth - spacing) / 2;
                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: processed.map((quest) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: QuestCard(
                                        quest: quest,
                                        onTap: () => QuestDetailModal.show(
                                          context,
                                          quest,
                                          engine: widget.engine,
                                          runStatus: widget.engine
                                              ?.getRun(quest.id)
                                              ?.status,
                                          onStartOrResume: widget.engine == null
                                              ? null
                                              : () {
                                                  final status = widget.engine!
                                                      .getRun(quest.id)
                                                      ?.status;
                                                  if (status ==
                                                      QuestRunStatus.paused) {
                                                    widget.engine!.resume(
                                                      quest.id,
                                                    );
                                                  } else {
                                                    widget.engine!.start(
                                                      quest.id,
                                                    );
                                                  }
                                                },
                                          onPause: widget.engine == null
                                              ? null
                                              : () => widget.engine!.pause(
                                                  quest.id,
                                                ),
                                          onStop: widget.engine == null
                                              ? null
                                              : () => widget.engine!.stop(
                                                  quest.id,
                                                ),
                                        ),
                                        onAction: () => QuestDetailModal.show(
                                          context,
                                          quest,
                                          engine: widget.engine,
                                          runStatus: widget.engine
                                              ?.getRun(quest.id)
                                              ?.status,
                                          onStartOrResume: widget.engine == null
                                              ? null
                                              : () {
                                                  final status = widget.engine!
                                                      .getRun(quest.id)
                                                      ?.status;
                                                  if (status ==
                                                      QuestRunStatus.paused) {
                                                    widget.engine!.resume(
                                                      quest.id,
                                                    );
                                                  } else {
                                                    widget.engine!.start(
                                                      quest.id,
                                                    );
                                                  }
                                                },
                                          onPause: widget.engine == null
                                              ? null
                                              : () => widget.engine!.pause(
                                                  quest.id,
                                                ),
                                          onStop: widget.engine == null
                                              ? null
                                              : () => widget.engine!.stop(
                                                  quest.id,
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }

                              return Column(
                                children: processed.map((quest) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: spacing,
                                    ),
                                    child: QuestCard(
                                      quest: quest,
                                      onTap: () => QuestDetailModal.show(
                                        context,
                                        quest,
                                        engine: widget.engine,
                                        runStatus: widget.engine
                                            ?.getRun(quest.id)
                                            ?.status,
                                        onStartOrResume: widget.engine == null
                                            ? null
                                            : () {
                                                final status = widget.engine!
                                                    .getRun(quest.id)
                                                    ?.status;
                                                if (status ==
                                                    QuestRunStatus.paused) {
                                                  widget.engine!.resume(
                                                    quest.id,
                                                  );
                                                } else {
                                                  widget.engine!.start(
                                                    quest.id,
                                                  );
                                                }
                                              },
                                        onPause: widget.engine == null
                                            ? null
                                            : () => widget.engine!.pause(
                                                quest.id,
                                              ),
                                        onStop: widget.engine == null
                                            ? null
                                            : () =>
                                                  widget.engine!.stop(quest.id),
                                      ),
                                      onAction: () => QuestDetailModal.show(
                                        context,
                                        quest,
                                        engine: widget.engine,
                                        runStatus: widget.engine
                                            ?.getRun(quest.id)
                                            ?.status,
                                        onStartOrResume: widget.engine == null
                                            ? null
                                            : () {
                                                final status = widget.engine!
                                                    .getRun(quest.id)
                                                    ?.status;
                                                if (status ==
                                                    QuestRunStatus.paused) {
                                                  widget.engine!.resume(
                                                    quest.id,
                                                  );
                                                } else {
                                                  widget.engine!.start(
                                                    quest.id,
                                                  );
                                                }
                                              },
                                        onPause: widget.engine == null
                                            ? null
                                            : () => widget.engine!.pause(
                                                quest.id,
                                              ),
                                        onStop: widget.engine == null
                                            ? null
                                            : () =>
                                                  widget.engine!.stop(quest.id),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            );

            if (widget.embedded) {
              return body;
            }

            return Scaffold(
              backgroundColor: AppColor.background,
              bottomNavigationBar: isDesktop
                  ? null
                  : DashboardBottomNav(
                      currentIndex: 1, // Quests is tab 1
                      onTap: (idx) => widget.onNavigate?.call(idx),
                    ),
              body: Row(
                children: [
                  if (isDesktop)
                    DashboardSidebar(
                      selectedIndex: 1, // Quests is tab 1
                      onDestinationSelected: (idx) =>
                          widget.onNavigate?.call(idx),
                    ),
                  Expanded(child: body),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
