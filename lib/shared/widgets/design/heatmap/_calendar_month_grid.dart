part of 'app_activity_heatmap.dart';

class _CalendarMonthGrid extends StatelessWidget {
  final Color baseColor;
  final DateTime today;
  final int days;
  final bool weekStartsMonday;
  final bool showDayNumbers;
  final double maxCellSize;
  final DateTime? selectedDay;
  final int Function(DateTime date) levelForDate;
  final ValueChanged<DateTime>? onDayTap;

  const _CalendarMonthGrid({
    required this.baseColor,
    required this.today,
    required this.days,
    required this.weekStartsMonday,
    required this.showDayNumbers,
    required this.maxCellSize,
    required this.selectedDay,
    required this.levelForDate,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final headers = weekStartsMonday
        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final cells = _buildCalendarCells();
    final rows = cells.length ~/ 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 5.0;
        final rawWidth = (constraints.maxWidth - gap * 6) / 7;
        final cellHeight = rawWidth.clamp(12.0, maxCellSize);
        final radius = cellHeight >= 24 ? 7.0 : 4.5;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                for (var c = 0; c < 7; c++) ...[
                  if (c > 0) const SizedBox(width: gap),
                  Expanded(
                    child: Center(
                      child: Text(
                        headers[c],
                        style: AppText.l1.cl(AppTheme.c.subText),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Space.y.t08,
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              Row(
                children: [
                  for (var c = 0; c < 7; c++) ...[
                    if (c > 0) const SizedBox(width: gap),
                    Expanded(
                      child: _HeatmapCell(
                        day: cells[r * 7 + c],
                        today: today,
                        selectedDay: selectedDay,
                        baseColor: baseColor,
                        height: cellHeight,
                        radius: radius,
                        showDayNumber: showDayNumbers,
                        level: cells[r * 7 + c] == null
                            ? 0
                            : levelForDate(cells[r * 7 + c]!),
                        onDayTap: onDayTap,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  List<DateTime?> _buildCalendarCells() {
    final startDay = DateTime(today.year, today.month, today.day - (days - 1));
    final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
    final leading = (startDay.weekday - firstWeekday + 7) % 7;

    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var i = 0; i < days; i++)
        DateTime(startDay.year, startDay.month, startDay.day + i),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}
