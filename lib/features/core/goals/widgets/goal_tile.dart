import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_period_helper.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_checkmark.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;
  final Color folderColor;
  final DateTime today;
  final bool isInToday;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onPushToToday;
  final VoidCallback onDelete;

  const GoalTile({
    super.key,
    required this.goal,
    required this.folderColor,
    required this.today,
    required this.isInToday,
    required this.onToggle,
    required this.onTap,
    required this.onPushToToday,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final dateBadge = GoalPeriodHelper.targetDateBadge(goal.targetDateKey, today);
    final hasNotes = (goal.notes ?? '').trim().isNotEmpty;

    return Dismissible(
      key: ValueKey('dismiss_${goal.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: Space.r.t16,
        decoration: BoxDecoration(
          color: AppTheme.c.error.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppTheme.c.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppProps.fast,
          padding: Space.sym(14, 11),
          decoration: BoxDecoration(
            color: goal.isCompleted
                ? AppTheme.c.specBackground.withValues(alpha: 0.55)
                : AppTheme.c.specBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: goal.isCompleted
                  ? AppTheme.c.border.withValues(alpha: 0.6)
                  : AppTheme.c.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle();
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppProps.fast,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: goal.isCompleted ? folderColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color:
                          goal.isCompleted ? folderColor : AppTheme.c.subText,
                      width: 1.8,
                    ),
                  ),
                  child: AppAnimatedCheckmark(
                    checked: goal.isCompleted,
                    size: 16,
                    color: AppTheme.c.onPrimary,
                  ),
                ),
              ),
              Space.x.t12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppText.b1
                          .cl(goal.isCompleted
                              ? AppTheme.c.subText
                              : AppTheme.c.text)
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: goal.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppTheme.c.subText,
                          ),
                    ),
                    if (dateBadge != null || hasNotes) ...[
                      Space.y.t04,
                      _GoalMetadataRow(
                        dateBadge: dateBadge,
                        notes: hasNotes ? goal.notes!.trim() : null,
                        isCompleted: goal.isCompleted,
                      ),
                    ],
                  ],
                ),
              ),
              if (!goal.isCompleted) ...[
                Space.x.t08,
                _TodayActionPill(
                  isInToday: isInToday,
                  onTap: onPushToToday,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalMetadataRow extends StatelessWidget {
  final GoalDateBadge? dateBadge;
  final String? notes;
  final bool isCompleted;

  const _GoalMetadataRow({
    required this.dateBadge,
    required this.notes,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    Color? dateColor;
    if (dateBadge != null) {
      if (isCompleted) {
        dateColor = AppTheme.c.subText;
      } else {
        dateColor = switch (dateBadge!.urgency) {
          GoalDateUrgency.overdue => AppTheme.c.error,
          GoalDateUrgency.dueSoon => AppTheme.c.warning,
          GoalDateUrgency.normal => AppTheme.c.subText,
        };
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (dateBadge != null && dateColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: dateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              dateBadge!.label,
              style: AppText.l1b.cl(dateColor).copyWith(fontSize: 10),
            ),
          ),
        if (notes != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notes_rounded, size: 12, color: AppTheme.c.subText),
              const SizedBox(width: 3),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  notes!,
                  style: AppText.l1.cl(AppTheme.c.subText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TodayActionPill extends StatelessWidget {
  final bool isInToday;
  final VoidCallback onTap;

  const _TodayActionPill({required this.isInToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = isInToday ? AppTheme.c.success : AppTheme.c.accent;

    return GestureDetector(
      onTap: isInToday ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isInToday) Icon(Icons.bolt_rounded, size: 14, color: color),
            Text(
              isInToday ? 'In Today ✓' : 'Today',
              style: AppText.l1b.cl(color),
            ),
          ],
        ),
      ),
    );
  }
}
