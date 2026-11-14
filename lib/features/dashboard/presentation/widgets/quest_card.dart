import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../domain/entities/quest_entity.dart';
import 'discord_orb_icon.dart';
import 'tactile_button.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  const QuestCard({super.key, required this.quest, this.onAction, this.onTap});

  TactileColor get _buttonTactileColor {
    switch (quest.category) {
      case QuestCategory.video:
        return TactileColor.lime;
      case QuestCategory.game:
        return TactileColor.cyan;
      case QuestCategory.stream:
        return TactileColor.lavender;
      case QuestCategory.activity:
        return TactileColor.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;
    final isInProgress = quest.status == QuestStatus.inProgress;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCompleted
              ? AppColor.success.withValues(alpha: 0.3)
              : AppColor.cardBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF111C2D),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? onAction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Accent Ribbon with Category & Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  color: AppColor.background.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      // Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: quest.category.accentColor.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: quest.category.accentColor.withValues(
                              alpha: 0.4,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              quest.category.iconData,
                              size: 13,
                              color: quest.category.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              quest.category.displayName.toUpperCase(),
                              style: TextStyle(
                                color: quest.category.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Status Pill
                      _StatusBadge(status: quest.status),
                    ],
                  ),
                ),

                // Card Body
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        quest.title,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        quest.description,
                        style: const TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Progress Bar for In Progress quests
                      if (isInProgress) ...[
                        const SizedBox(height: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Quest Progress',
                                  style: TextStyle(
                                    color: AppColor.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${(quest.progress * 100).toInt()}%',
                                  style: TextStyle(
                                    color: quest.category.accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              child: LinearProgressIndicator(
                                value: quest.progress,
                                minHeight: 6,
                                backgroundColor: AppColor.surfaceLight,
                                color: quest.category.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // Meta Row: Reward Orbs & Duration
                      Row(
                        children: [
                          // Reward Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lavender.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: AppColor.lavender.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const DiscordOrbIcon(size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  '+${quest.rewardOrbs} Orbs',
                                  style: const TextStyle(
                                    color: AppColor.lavender,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          // Duration Badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: AppColor.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                quest.duration,
                                style: const TextStyle(
                                  color: AppColor.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Tactile Action Button
                      if (isCompleted)
                        Container(
                          width: double.infinity,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColor.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColor.success.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColor.success,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Completed & Claimed',
                                style: TextStyle(
                                  color: AppColor.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        TactileButton(
                          label: isInProgress ? 'Resume Quest' : 'Start Quest',
                          color: _buttonTactileColor,
                          fullWidth: true,
                          height: 38,
                          fontSize: 12,
                          icon: Icon(
                            isInProgress
                                ? Icons.play_arrow_rounded
                                : Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColor.background,
                          ),
                          onPressed: onAction,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final QuestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    IconData icon;

    switch (status) {
      case QuestStatus.available:
        textColor = AppColor.lime;
        bgColor = AppColor.lime.withValues(alpha: 0.15);
        icon = Icons.radio_button_unchecked_rounded;
        break;
      case QuestStatus.inProgress:
        textColor = AppColor.cyan;
        bgColor = AppColor.cyan.withValues(alpha: 0.15);
        icon = Icons.hourglass_top_rounded;
        break;
      case QuestStatus.completed:
        textColor = AppColor.success;
        bgColor = AppColor.success.withValues(alpha: 0.15);
        icon = Icons.check_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
