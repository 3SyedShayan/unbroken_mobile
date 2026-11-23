import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class MomentumSummaryRow extends StatelessWidget {
  final int consistencyPercent;
  final int unbrokenDaysCount;
  final int bestHabitStreak;

  const MomentumSummaryRow({
    super.key,
    required this.consistencyPercent,
    required this.unbrokenDaysCount,
    required this.bestHabitStreak,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            value: '$consistencyPercent%',
            label: 'Consistency',
            valueColor: AppTheme.c.text,
          ),
        ),
        Space.x.t08,
        Expanded(
          child: _SummaryTile(
            value: '$unbrokenDaysCount',
            label: 'Unbroken days',
            valueColor: unbrokenDaysCount > 0 ? AppTheme.c.accent : AppTheme.c.text,
          ),
        ),
        Space.x.t08,
        Expanded(
          child: _SummaryTile(
            value: '${bestHabitStreak}d',
            label: 'Best run',
            valueColor: AppTheme.c.text,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.sym(10, 14),
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.stat.cl(valueColor)),
          Space.y.t04,
          Text(
            label,
            style: AppText.l1.cl(AppTheme.c.subText),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
