part of 'app_activity_heatmap.dart';

class _WeekColumnsGrid extends StatelessWidget {
  final Color baseColor;
  final DateTime today;
  final int weeks;
  final bool weekStartsMonday;
  final bool fitWidth;
  final double maxCellSize;
  final DateTime? selectedDay;
  final int Function(DateTime date) levelForDate;
  final ValueChanged<DateTime>? onDayTap;

  const _WeekColumnsGrid({
    required this.baseColor,
    required this.today,
    required this.weeks,
    required this.weekStartsMonday,
    required this.fitWidth,
    required this.maxCellSize,
    required this.selectedDay,
    required this.levelForDate,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final columns = _buildWeekColumns();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 3.0;
        const axisWidth = 14.0;
        const axisGap = 6.0;
        final availableWidth =
            (constraints.maxWidth - axisWidth - axisGap).clamp(60.0, 2000.0);
        final cellSize = fitWidth
            ? ((availableWidth - (weeks - 1) * gap) / weeks)
                .clamp(6.0, maxCellSize)
            : 13.0.clamp(8.0, maxCellSize);
        final radius = (cellSize * 0.24).clamp(2.0, 4.0);
        final gridWidth = weeks * cellSize + (weeks - 1) * gap;

        final matrix = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MonthHeaderStrip(
              columns: columns,
              cellSize: cellSize,
              gap: gap,
              totalWidth: gridWidth,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < columns.length; c++) ...[
                  if (c > 0) const SizedBox(width: gap),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var r = 0; r < 7; r++) ...[
                        if (r > 0) const SizedBox(height: gap),
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: _HeatmapCell(
                            day: columns[c].days[r],
                            today: today,
                            selectedDay: selectedDay,
                            baseColor: baseColor,
                            height: cellSize,
                            radius: radius,
                            showDayNumber: false,
                            level: columns[c].days[r] == null
                                ? 0
                                : levelForDate(columns[c].days[r]!),
                            onDayTap: onDayTap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeekdayAxisColumn(
              weekStartsMonday: weekStartsMonday,
              cellSize: cellSize,
              gap: gap,
              width: axisWidth,
            ),
            const SizedBox(width: axisGap),
            Expanded(
              child: fitWidth
                  ? matrix
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: matrix,
                    ),
            ),
          ],
        );
      },
    );
  }

  List<_WeekColumnData> _buildWeekColumns() {
    final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
    final rowOfToday = (today.weekday - firstWeekday + 7) % 7;
    final currentWeekStart =
        DateTime(today.year, today.month, today.day - rowOfToday);

    final columns = <_WeekColumnData>[];
    var lastMonth = -1;
    var lastLabeledCol = -99;

    for (var c = 0; c < weeks; c++) {
      final weeksBack = (weeks - 1) - c;
      final weekStart = DateTime(
        currentWeekStart.year,
        currentWeekStart.month,
        currentWeekStart.day - weeksBack * 7,
      );
      final days = List<DateTime?>.generate(7, (r) {
        final d = DateTime(weekStart.year, weekStart.month, weekStart.day + r);
        return d.isAfter(today) ? null : d;
      });

      String? monthLabel;
      if (weekStart.month != lastMonth) {
        lastMonth = weekStart.month;
        if (!(c == 0 && weekStart.day > 20) && (c - lastLabeledCol >= 2)) {
          monthLabel = DateFormat('MMM').format(weekStart);
          lastLabeledCol = c;
        }
      }

      columns.add(_WeekColumnData(days: days, monthLabel: monthLabel));
    }
    return columns;
  }
}

class _WeekColumnData {
  final List<DateTime?> days;
  final String? monthLabel;

  const _WeekColumnData({required this.days, required this.monthLabel});
}

class _MonthHeaderStrip extends StatelessWidget {
  final List<_WeekColumnData> columns;
  final double cellSize;
  final double gap;
  final double totalWidth;

  const _MonthHeaderStrip({
    required this.columns,
    required this.cellSize,
    required this.gap,
    required this.totalWidth,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return SizedBox(
      width: totalWidth,
      height: 13,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var c = 0; c < columns.length; c++)
            if (columns[c].monthLabel != null)
              Positioned(
                left: c * (cellSize + gap),
                top: 0,
                child: Text(
                  columns[c].monthLabel!,
                  style: AppText.l1.cl(AppTheme.c.subText).copyWith(fontSize: 9.5),
                ),
              ),
        ],
      ),
    );
  }
}

class _WeekdayAxisColumn extends StatelessWidget {
  final bool weekStartsMonday;
  final double cellSize;
  final double gap;
  final double width;

  const _WeekdayAxisColumn({
    required this.weekStartsMonday,
    required this.cellSize,
    required this.gap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final labels = weekStartsMonday
        ? const ['M', '', 'W', '', 'F', '', '']
        : const ['', 'M', '', 'W', '', 'F', ''];

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 17),
          for (var r = 0; r < 7; r++) ...[
            if (r > 0) SizedBox(height: gap),
            SizedBox(
              height: cellSize,
              child: Center(
                child: Text(
                  labels[r],
                  style: AppText.l1.cl(AppTheme.c.subText).copyWith(fontSize: 9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
