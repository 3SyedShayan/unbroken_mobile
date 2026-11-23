import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/router/routes.dart';
import 'package:unbroken_mobile/shared/widgets/design/heatmap/app_activity_heatmap.dart';

class HabitProgressCard extends StatelessWidget {
  final HabitRangeSummary summary;
  final ProgressRange range;
  final DateTime today;
  final bool weekStartsMonday;

  const HabitProgressCard({
    super.key,
    required this.summary,
    required this.range,
    required this.today,
    required this.weekStartsMonday,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final habit = summary.habit;
    final emoji = habit.emoji.isEmpty ? '🔥' : habit.emoji;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.habitDetail,
          arguments: habit,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: Space.a.t16,
        decoration: BoxDecoration(
          color: AppTheme.c.specBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.c.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                Space.x.t08,
                Expanded(
                  child: Text(
                    habit.name,
                    style: AppText.h3b.cl(AppTheme.c.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Space.x.t08,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${summary.consistencyPercent}%',
                    style: AppText.l1b.cl(habit.color),
                  ),
                ),
                Space.x.t08,
                Text(
                  '🔥 ${summary.currentStreak}d',
                  style: AppText.b2b.cl(habit.color),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.c.subText,
                ),
              ],
            ),
            Space.y.t12,
            AppActivityHeatmap(
              baseColor: habit.color,
              today: today,
              weekStartsMonday: weekStartsMonday,
              layout: range.isCalendarMonthLayout
                  ? HeatmapLayout.calendarMonth
                  : HeatmapLayout.weekColumns,
              weeks: range.weeks,
              days: range.days,
              fitWidth: range != ProgressRange.sixMonths,
              maxCellSize: 20,
              showLegend: false,
              showDayNumbers: false,
              levelForDate: (date) =>
                  summary.streakDepthLevels[DaySettings.dayKey(date)] ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
