part of 'app_activity_heatmap.dart';

class _HeatmapCell extends StatelessWidget {
  final DateTime? day;
  final DateTime today;
  final DateTime? selectedDay;
  final Color baseColor;
  final double height;
  final double radius;
  final bool showDayNumber;
  final int level;
  final ValueChanged<DateTime>? onDayTap;

  const _HeatmapCell({
    required this.day,
    required this.today,
    required this.selectedDay,
    required this.baseColor,
    required this.height,
    required this.radius,
    required this.showDayNumber,
    required this.level,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    if (day == null) {
      return SizedBox(height: height);
    }

    final isToday = day == today;
    final isSelected = selectedDay != null && day == selectedDay;
    final fillColor = AppActivityHeatmap.colorForLevel(
      baseColor,
      AppTheme.c.emptyCell,
      level,
    );

    BoxBorder? border;
    if (isSelected) {
      border = Border.all(color: AppTheme.c.text, width: 1.8);
    } else if (isToday && level == 0) {
      border = Border.all(color: baseColor.withValues(alpha: 0.75), width: 1.4);
    }

    final numberColor = level >= 3 ? AppTheme.c.onPrimary : AppTheme.c.subText;

    final cell = AnimatedContainer(
      duration: AppProps.fast,
      curve: Curves.easeOutCubic,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: showDayNumber
          ? Text(
              '${day!.day}',
              style: AppText.l1.cl(numberColor).copyWith(
                    fontSize: 10.5,
                    fontWeight: level >= 3 ? FontWeight.w600 : FontWeight.w500,
                  ),
            )
          : null,
    );

    if (onDayTap == null) return cell;
    return GestureDetector(
      onTap: () => onDayTap!(day!),
      behavior: HitTestBehavior.opaque,
      child: cell,
    );
  }
}

class _HeatmapFooter extends StatelessWidget {
  final Color baseColor;
  final bool showLegend;
  final String? leadingText;

  const _HeatmapFooter({
    required this.baseColor,
    required this.showLegend,
    required this.leadingText,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        if (leadingText != null)
          Expanded(
            child: Text(
              leadingText!,
              style: AppText.l1.cl(AppTheme.c.subText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          const Spacer(),
        if (showLegend)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Less',
                style: AppText.l1.cl(AppTheme.c.subText).copyWith(fontSize: 10),
              ),
              Space.x.t04,
              for (var level = 0; level <= 4; level++) ...[
                if (level > 0) const SizedBox(width: 3),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppActivityHeatmap.colorForLevel(
                      baseColor,
                      AppTheme.c.emptyCell,
                      level,
                    ),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ],
              Space.x.t04,
              Text(
                'More',
                style: AppText.l1.cl(AppTheme.c.subText).copyWith(fontSize: 10),
              ),
            ],
          ),
      ],
    );
  }
}
