import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../dashboard/presentation/widgets/discord_orb_icon.dart';
import '../../../dashboard/presentation/widgets/seele_mascot.dart';
import '../../../dashboard/presentation/widgets/tactile_button.dart';
import '../../domain/entities/quest_entity.dart';

class QuestDetailModal extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onStartOrResume;

  const QuestDetailModal({
    super.key,
    required this.quest,
    this.onStartOrResume,
  });

  static Future<void> show(BuildContext context, Quest quest) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    if (isDesktop) {
      return showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: QuestDetailModal(quest: quest),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return QuestDetailModal(quest: quest);
      },
    );
  }

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
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColor.cardBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0C1624),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag indicator / close row
              Row(
                children: [
                  // Category Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: quest.category.accentColor.withValues(alpha: 0.18),
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
                          size: 14,
                          color: quest.category.accentColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          quest.category.displayName.toUpperCase(),
                          style: TextStyle(
                            color: quest.category.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Status Pill
                  _StatusChip(status: quest.status),

                  const Spacer(),

                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColor.surfaceLight,
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColor.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                quest.title,
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                quest.description,
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Requirements Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColor.background,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColor.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 18,
                          color: AppColor.cyan,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'QUEST REQUIREMENTS',
                          style: TextStyle(
                            color: AppColor.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (quest.requirements.isEmpty)
                      const Text(
                        'Complete the primary objective described above.',
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      ...quest.requirements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final req = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColor.surfaceLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColor.lime,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  req,
                                  style: const TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Progress & Reward Row
              Row(
                children: [
                  // Reward Orbs Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lavender.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColor.lavender.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const DiscordOrbIcon(size: 28, glowing: true),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REWARD',
                                style: TextStyle(
                                  color: AppColor.lavender,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                '+${quest.rewardOrbs} Orbs',
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Duration Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColor.cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 24,
                            color: AppColor.amber,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EST. DURATION',
                                style: TextStyle(
                                  color: AppColor.textMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                quest.duration,
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // In Progress Bar
              if (quest.isInProgress) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColor.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColor.cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Progress',
                            style: TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${(quest.progress * 100).toInt()}% Completed',
                            style: TextStyle(
                              color: quest.category.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          minHeight: 8,
                          backgroundColor: AppColor.surfaceLight,
                          color: quest.category.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Data Integrity Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColor.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColor.amber,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Data Simulasi • Belum terhubung ke Discord Gateway API asli',
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Action Button & Mascot
              Row(
                children: [
                  const SeeleMascot(
                    size: 48,
                    expression: MascotExpression.happy,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: quest.isCompleted
                        ? Container(
                            height: 44,
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
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Quest Cleared & Claimed',
                                  style: TextStyle(
                                    color: AppColor.success,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TactileButton(
                            label: quest.isInProgress
                                ? 'Resume Quest'
                                : 'Start Quest Now',
                            color: _buttonTactileColor,
                            fullWidth: true,
                            height: 44,
                            icon: Icon(
                              quest.isInProgress
                                  ? Icons.play_arrow_rounded
                                  : Icons.bolt_rounded,
                              size: 18,
                              color: AppColor.background,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onStartOrResume != null) {
                                onStartOrResume?.call();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Simulasi: Misi "${quest.title}" memerlukan koneksi Discord Gateway API.',
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final QuestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch (status) {
      case QuestStatus.available:
        textColor = AppColor.lime;
        bgColor = AppColor.lime.withValues(alpha: 0.15);
        break;
      case QuestStatus.inProgress:
        textColor = AppColor.cyan;
        bgColor = AppColor.cyan.withValues(alpha: 0.15);
        break;
      case QuestStatus.completed:
        textColor = AppColor.success;
        bgColor = AppColor.success.withValues(alpha: 0.15);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
