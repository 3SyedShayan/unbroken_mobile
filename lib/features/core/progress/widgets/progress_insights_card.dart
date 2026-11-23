import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';

class ProgressInsightsCard extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const ProgressInsightsCard({super.key, required this.snapshot});

  bool get hasAnyInsight =>
      snapshot.strongestWeekday != null ||
      snapshot.topHabit != null ||
      snapshot.goalsCompletedInRange > 0;

  @override
  Widget build(BuildContext context) {
    App.init(context);
    if (!hasAnyInsight) return const SizedBox.shrink();

    final weekday = snapshot.strongestWeekday;
    final top = snapshot.topHabit;
    final goalsCount = snapshot.goalsCompletedInRange;

    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOMENTUM INSIGHTS',
            style: AppText.l1b.cl(AppTheme.c.subText).copyWith(letterSpacing: 1.2),
          ),
          Space.y.t08,
          if (weekday != null)
            _InsightLine(
              icon: Icons.auto_awesome_rounded,
              color: AppTheme.c.accent,
              text:
                  'Strongest on ${weekday.weekdayName} (${weekday.averagePercent}%)',
            ),
          if (top != null) ...[
            if (weekday != null) Space.y.t04,
            _InsightLine(
              icon: Icons.local_fire_department_rounded,
              color: top.habit.color,
              text:
                  'Most consistent: ${top.habit.emoji.isEmpty ? '🔥' : top.habit.emoji} ${top.habit.name} (${top.consistencyPercent}%)',
            ),
          ],
          if (goalsCount > 0) ...[
            if (weekday != null || top != null) Space.y.t04,
            _InsightLine(
              icon: Icons.track_changes_rounded,
              color: AppTheme.c.success,
              text:
                  '$goalsCount ${goalsCount == 1 ? 'goal' : 'goals'} completed in ${snapshot.range.shortLabel}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InsightLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        Space.x.t08,
        Expanded(
          child: Text(
            text,
            style: AppText.b2.cl(AppTheme.c.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
