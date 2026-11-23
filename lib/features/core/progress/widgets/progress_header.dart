import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';

class ProgressHeader extends StatelessWidget {
  final ProgressRange selectedRange;
  final DateTime startDay;
  final DateTime endDay;
  final int? deltaVsPreviousPercent;
  final ValueChanged<ProgressRange> onRangeChanged;

  const ProgressHeader({
    super.key,
    required this.selectedRange,
    required this.startDay,
    required this.endDay,
    required this.deltaVsPreviousPercent,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final fmt = DateFormat('MMM d');
    final rangeSpan = '${fmt.format(startDay)} – ${fmt.format(endDay)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress', style: AppText.h1b.cl(AppTheme.c.text)),
              Space.y.t04,
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    rangeSpan,
                    style: AppText.b2.cl(AppTheme.c.subText),
                  ),
                  if (deltaVsPreviousPercent != null)
                    _MomentumDeltaBadge(delta: deltaVsPreviousPercent!),
                ],
              ),
            ],
          ),
        ),
        Space.x.t12,
        _RangeSegmentedControl(
          selected: selectedRange,
          onChanged: onRangeChanged,
        ),
      ],
    );
  }
}

class _MomentumDeltaBadge extends StatelessWidget {
  final int delta;

  const _MomentumDeltaBadge({required this.delta});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final isPositive = delta > 0;
    final isFlat = delta == 0;
    final color = isPositive
        ? AppTheme.c.success
        : (isFlat ? AppTheme.c.subText : AppTheme.c.warning);
    final prefix = isPositive ? '↑ +' : (isFlat ? '' : '↓ ');
    final label = isFlat ? 'Steady vs prev' : '$prefix$delta% vs prev';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.l1b.cl(color).copyWith(fontSize: 10.5),
      ),
    );
  }
}

class _RangeSegmentedControl extends StatelessWidget {
  final ProgressRange selected;
  final ValueChanged<ProgressRange> onChanged;

  const _RangeSegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.c.subBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final range in ProgressRange.values) ...[
            GestureDetector(
              onTap: () => onChanged(range),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppProps.fast,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: range == selected
                      ? AppTheme.c.specBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  range.shortLabel,
                  style: AppText.b2b.cl(
                    range == selected ? AppTheme.c.accent : AppTheme.c.subText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
