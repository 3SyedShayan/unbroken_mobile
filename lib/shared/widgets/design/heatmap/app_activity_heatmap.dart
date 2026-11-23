import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';

part '_calendar_month_grid.dart';
part '_heatmap_cell.dart';
part '_week_columns_grid.dart';

enum HeatmapLayout { calendarMonth, weekColumns }

/// GitHub-style multi-shade activity heatmap supporting 1M calendar grids and
/// multi-month week-column matrices with 5 intensity levels (0..4).
class AppActivityHeatmap extends StatelessWidget {
  final Color baseColor;
  final DateTime today;
  final bool weekStartsMonday;
  final HeatmapLayout layout;
  final int weeks;
  final int days;
  final bool fitWidth;
  final bool showLegend;
  final bool showDayNumbers;
  final double maxCellSize;
  final String? footerLeadingText;
  final DateTime? selectedDay;
  final int Function(DateTime date) levelForDate;
  final ValueChanged<DateTime>? onDayTap;

  const AppActivityHeatmap({
    super.key,
    required this.baseColor,
    required this.today,
    this.weekStartsMonday = false,
    this.layout = HeatmapLayout.weekColumns,
    this.weeks = 13,
    this.days = 30,
    this.fitWidth = true,
    this.showLegend = true,
    this.showDayNumbers = false,
    this.maxCellSize = 34,
    this.footerLeadingText,
    this.selectedDay,
    required this.levelForDate,
    this.onDayTap,
  });

  /// Maps intensity [level] (0..4) to a color between [emptyCell] and [base].
  static Color colorForLevel(Color base, Color emptyCell, int level) {
    if (level <= 0) return emptyCell;
    if (level == 1) return base.withValues(alpha: 0.22);
    if (level == 2) return base.withValues(alpha: 0.45);
    if (level == 3) return base.withValues(alpha: 0.72);
    return base;
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = selectedDay == null
        ? null
        : DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (layout == HeatmapLayout.calendarMonth)
          _CalendarMonthGrid(
            baseColor: baseColor,
            today: normalizedToday,
            days: days,
            weekStartsMonday: weekStartsMonday,
            showDayNumbers: showDayNumbers,
            maxCellSize: maxCellSize,
            selectedDay: normalizedSelected,
            levelForDate: levelForDate,
            onDayTap: onDayTap,
          )
        else
          _WeekColumnsGrid(
            baseColor: baseColor,
            today: normalizedToday,
            weeks: weeks,
            weekStartsMonday: weekStartsMonday,
            fitWidth: fitWidth,
            maxCellSize: maxCellSize,
            selectedDay: normalizedSelected,
            levelForDate: levelForDate,
            onDayTap: onDayTap,
          ),
        if (showLegend || footerLeadingText != null) ...[
          Space.y.t12,
          _HeatmapFooter(
            baseColor: baseColor,
            showLegend: showLegend,
            leadingText: footerLeadingText,
          ),
        ],
      ],
    );
  }
}
