import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class MiniGrid extends StatelessWidget {
  static const double cellSize = 12;
  static const double cellGap = 3;
  static const double cellRadius = 2.5;

  final Color color;
  final List<bool> done;
  final bool highlightToday;

  const MiniGrid({
    super.key,
    required this.color,
    required this.done,
    this.highlightToday = true,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < done.length; i++) ...[
          if (i > 0) const SizedBox(width: cellGap),
          AnimatedContainer(
            duration: AppProps.fast,
            curve: Curves.easeOutCubic,
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: done[i] ? color : AppColors.emptyCell,
              borderRadius: BorderRadius.circular(cellRadius),
              border: highlightToday && i == done.length - 1 && !done[i]
                  ? Border.all(
                      color: color.withValues(alpha: 0.6),
                      width: 1.2,
                    )
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

