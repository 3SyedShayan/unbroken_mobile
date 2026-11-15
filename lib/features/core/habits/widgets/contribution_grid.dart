import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class ContributionGrid extends StatelessWidget {
  final Color color;
  final DateTime today;
  final bool weekStartsMonday;
  final int weeks;
  final bool Function(DateTime date) isDone;
  final void Function(DateTime date)? onToggleDay;

  const ContributionGrid({
    super.key,
    required this.color,
    required this.today,
    this.weekStartsMonday = false,
    this.weeks = 18,
    required this.isDone,
    this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final columns = _buildColumns();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthHeaderRow(columns: columns),
          Space.y.t04,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final col in columns) ...[
                Column(
                  children: [
                    for (final day in col.days) ...[
                      _GridCell(
                        day: day,
                        today: today,
                        color: color,
                        isDone: day != null && isDone(day),
                        onTap: () {
                          if (day != null && !day.isAfter(today)) {
                            _showConfirmDialog(context, day);
                          }
                        },
                      ),
                      const SizedBox(height: 3),
                    ],
                  ],
                ),
                const SizedBox(width: 3),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, DateTime day) {
    final done = isDone(day);
    final formatted = DateFormat('EEEE, MMM d').format(day);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          done ? 'Remove check-in?' : 'Log check-in?',
          style: AppText.h3b.cl(AppColors.text),
        ),
        content: Text(
          formatted,
          style: AppText.b1.cl(AppColors.subText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.b1.cl(AppColors.subText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onToggleDay?.call(day);
            },
            child: Text(
              done ? 'Remove' : 'Confirm',
              style: AppText.b1b.cl(done ? AppColors.error : AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  List<_GridColumnData> _buildColumns() {
    final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
    final weekdayOfToday = today.weekday;
    final rowOfToday = (weekdayOfToday - firstWeekday + 7) % 7;
    final currentWeekStart = today.subtract(Duration(days: rowOfToday));

    final result = <_GridColumnData>[];
    var lastMonth = -1;

    for (var c = 0; c < weeks; c++) {
      final weeksBack = (weeks - 1) - c;
      final weekStart = currentWeekStart.subtract(Duration(days: weeksBack * 7));
      final days = <DateTime?>[];

      for (var r = 0; r < 7; r++) {
        final d = weekStart.add(Duration(days: r));
        final normalizedD = DateTime(d.year, d.month, d.day);
        final normalizedToday = DateTime(today.year, today.month, today.day);

        if (normalizedD.isAfter(normalizedToday)) {
          days.add(null);
        } else {
          days.add(normalizedD);
        }
      }

      final month = weekStart.month;
      String? monthLabel;
      if (month != lastMonth) {
        lastMonth = month;
        monthLabel = DateFormat('MMM').format(weekStart);
      }

      result.add(_GridColumnData(
        days: days,
        monthLabel: monthLabel,
      ));
    }

    return result;
  }
}

class _GridColumnData {
  final List<DateTime?> days;
  final String? monthLabel;

  _GridColumnData({required this.days, this.monthLabel});
}

class _MonthHeaderRow extends StatelessWidget {
  final List<_GridColumnData> columns;

  const _MonthHeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        for (final col in columns)
          SizedBox(
            width: 15,
            child: col.monthLabel != null
                ? Text(
                    col.monthLabel!,
                    style: AppText.l1.cl(AppColors.hint).copyWith(fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final DateTime? day;
  final DateTime today;
  final Color color;
  final bool isDone;
  final VoidCallback onTap;

  const _GridCell({
    required this.day,
    required this.today,
    required this.color,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2.5),
        ),
      );
    }

    final isToday = day!.year == today.year &&
        day!.month == today.month &&
        day!.day == today.day;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isDone ? color : AppColors.emptyCell,
          borderRadius: BorderRadius.circular(2.5),
          border: isToday && !isDone
              ? Border.all(color: color.withValues(alpha: 0.6), width: 1.2)
              : null,
        ),
      ),
    );
  }
}
