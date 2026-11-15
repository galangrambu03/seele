import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../quests/domain/entities/quest_entity.dart';
import 'discord_orb_icon.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const QuestCard({
    super.key,
    required this.quest,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Sekarang menggunakan AppColor global yang sudah jadi Merah
    final borderColor = quest.category.accentColor; 
    final shadowColor = quest.category.darkAccentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg - 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: borderColor.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(quest.category.iconData, color: borderColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                quest.category.displayName.toUpperCase(),
                                style: TextStyle(
                                  color: borderColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          quest.status.displayName.toUpperCase(),
                          style: TextStyle(
                            color: quest.isCompleted
                                ? AppColor.success
                                : (quest.isInProgress ? borderColor : AppColor.textMuted),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      quest.title,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      quest.description.isNotEmpty
                          ? quest.description
                          : 'Complete the required objective.',
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (quest.progress > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quest Progress',
                            style: TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${(quest.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: borderColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          minHeight: 8,
                          backgroundColor: AppColor.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const DiscordOrbIcon(size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '+${quest.rewardOrbs}',
                              style: const TextStyle(
                                color: AppColor.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        if (onAction != null && !quest.isCompleted)
                          GestureDetector(
                            onTap: onAction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    offset: const Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    quest.isInProgress ? Icons.play_arrow_rounded : Icons.bolt_rounded,
                                    color: AppColor.background,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    quest.isInProgress ? 'RESUME' : 'START',
                                    style: TextStyle(
                                      color: AppColor.background,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (quest.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColor.success),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColor.success, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'CLEARED',
                                  style: TextStyle(
                                    color: AppColor.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}