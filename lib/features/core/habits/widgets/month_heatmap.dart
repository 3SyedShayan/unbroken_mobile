import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class MonthHeatmap extends StatelessWidget {
  final Color color;
  final DateTime today;
  final bool weekStartsMonday;
  final bool Function(DateTime date) isDone;
  final void Function(DateTime date)? onToggleDay;

  const MonthHeatmap({
    super.key,
    required this.color,
    required this.today,
    this.weekStartsMonday = false,
    required this.isDone,
    this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final cells = _buildMonthCells();
    final headers = _buildWeekdayHeaders();

    return Column(
      children: [
        Row(
          children: [
            for (final h in headers)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: AppText.l1.cl(AppColors.hint),
                  ),
                ),
              ),
          ],
        ),
        Space.y.t08,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1.1,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final day = cells[index];
            if (day == null) {
              return const SizedBox.shrink();
            }

            final done = isDone(day);
            final normalizedD = DateTime(day.year, day.month, day.day);
            final normalizedToday = DateTime(today.year, today.month, today.day);
            final isFuture = normalizedD.isAfter(normalizedToday);
            final isToday = normalizedD.isAtSameMomentAs(normalizedToday);

            return GestureDetector(
              onTap: () {
                if (!isFuture) {
                  _showConfirmDialog(context, day, done);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: done
                      ? color
                      : (isFuture
                          ? AppColors.emptyCell.withValues(alpha: 0.4)
                          : AppColors.emptyCell),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !done
                      ? Border.all(color: color.withValues(alpha: 0.7), width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: FontFamily.hanken,
                      fontSize: 12,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      color: done
                          ? Colors.white
                          : (isFuture
                              ? AppColors.hint.withValues(alpha: 0.5)
                              : AppColors.text),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context, DateTime day, bool done) {
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

  List<String> _buildWeekdayHeaders() {
    if (weekStartsMonday) {
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
    return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  }

  List<DateTime?> _buildMonthCells() {
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final nextMonthFirst = DateTime(today.year, today.month + 1, 1);
    final daysInMonth = nextMonthFirst.subtract(const Duration(days: 1)).day;

    final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
    final leading = (firstDayOfMonth.weekday - firstWeekday + 7) % 7;

    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(today.year, today.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}

