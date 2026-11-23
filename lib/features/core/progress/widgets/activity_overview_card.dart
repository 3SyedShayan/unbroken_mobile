import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/shared/widgets/design/heatmap/app_activity_heatmap.dart';

class ActivityOverviewCard extends StatelessWidget {
  final ProgressSnapshot snapshot;
  final ActivityFilter filter;
  final bool weekStartsMonday;
  final DateTime? selectedDay;
  final ValueChanged<ActivityFilter> onFilterChanged;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onClearSelectedDay;

  const ActivityOverviewCard({
    super.key,
    required this.snapshot,
    required this.filter,
    required this.weekStartsMonday,
    required this.selectedDay,
    required this.onFilterChanged,
    required this.onDayTap,
    required this.onClearSelectedDay,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final baseColor =
        filter == ActivityFilter.tasks ? AppTheme.c.success : AppTheme.c.accent;

    final footerLeading = switch (filter) {
      ActivityFilter.all => '${snapshot.activeDaysCount} active days',
      ActivityFilter.habits => '${snapshot.unbrokenDaysCount} unbroken',
      ActivityFilter.tasks =>
        '${snapshot.taskSummary.clearedDaysInRange} days cleared',
    };

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'ACTIVITY',
                  style: AppText.l1b
                      .cl(AppTheme.c.subText)
                      .copyWith(letterSpacing: 1.2),
                ),
              ),
              _FilterChipsRow(
                selected: filter,
                onChanged: onFilterChanged,
              ),
            ],
          ),
          Space.y.t12,
          AnimatedSwitcher(
            duration: AppProps.medium,
            child: AppActivityHeatmap(
              key: ValueKey('${snapshot.range.storageKey}_${filter.name}'),
              baseColor: baseColor,
              today: snapshot.endDay,
              weekStartsMonday: weekStartsMonday,
              layout: snapshot.range.isCalendarMonthLayout
                  ? HeatmapLayout.calendarMonth
                  : HeatmapLayout.weekColumns,
              weeks: snapshot.range.weeks,
              days: snapshot.range.days,
              fitWidth: snapshot.range != ProgressRange.sixMonths,
              showDayNumbers: snapshot.range.isCalendarMonthLayout,
              maxCellSize: 34,
              showLegend: true,
              footerLeadingText: footerLeading,
              selectedDay: selectedDay,
              levelForDate: (date) {
                final key = DaySettings.dayKey(date);
                return snapshot.daysByKey[key]?.levelFor(filter) ?? 0;
              },
              onDayTap: onDayTap,
            ),
          ),
          AnimatedSize(
            duration: AppProps.fast,
            curve: Curves.easeOutCubic,
            child: selectedDay == null
                ? const SizedBox.shrink()
                : _DayPeekBanner(
                    day: selectedDay!,
                    summary: snapshot.daysByKey[DaySettings.dayKey(selectedDay!)],
                    onDismiss: onClearSelectedDay,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final ActivityFilter selected;
  final ValueChanged<ActivityFilter> onChanged;

  const _FilterChipsRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < ActivityFilter.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _FilterPill(
            filter: ActivityFilter.values[i],
            isSelected: ActivityFilter.values[i] == selected,
            onTap: () => onChanged(ActivityFilter.values[i]),
          ),
        ],
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final ActivityFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final activeColor =
        filter == ActivityFilter.tasks ? AppTheme.c.success : AppTheme.c.accent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppProps.fast,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.14)
              : AppTheme.c.subBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filter.label,
          style: AppText.l1b.cl(isSelected ? activeColor : AppTheme.c.subText),
        ),
      ),
    );
  }
}

class _DayPeekBanner extends StatelessWidget {
  final DateTime day;
  final ActivityDaySummary? summary;
  final VoidCallback onDismiss;

  const _DayPeekBanner({
    required this.day,
    required this.summary,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final dateLabel = DateFormat('EEE, MMM d').format(day);
    final countsText = _formatAggregateSummary(summary);

    return Container(
      margin: Space.t.t12,
      padding: Space.sym(12, 8),
      decoration: BoxDecoration(
        color: AppTheme.c.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppText.b2.cl(AppTheme.c.subText),
                children: [
                  TextSpan(
                    text: '$dateLabel · ',
                    style: AppText.b2b.cl(AppTheme.c.text),
                  ),
                  TextSpan(text: countsText),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppTheme.c.subText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAggregateSummary(ActivityDaySummary? s) {
    if (s == null || (s.habitsTotal == 0 && s.tasksTotal == 0)) {
      return 'No activity logged';
    }
    final parts = <String>[];
    if (s.habitsTotal > 0) {
      parts.add('${s.habitsDone}/${s.habitsTotal} habits');
    }
    if (s.tasksTotal > 0) {
      parts.add('${s.tasksDone}/${s.tasksTotal} tasks');
    }
    return parts.isEmpty ? 'No activity logged' : parts.join(' · ');
  }
}
