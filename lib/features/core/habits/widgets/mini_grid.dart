import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class MiniGrid extends StatelessWidget {
  final Color color;
  final List<bool> done;

  const MiniGrid({
    super.key,
    required this.color,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < done.length; i++) ...[
          if (i > 0) Space.x.t04,
          AnimatedContainer(
            duration: AppProps.fast,
            curve: Curves.easeOutCubic,
            width: 5,
            height: 12,
            decoration: BoxDecoration(
              color: done[i]
                  ? color
                  : AppColors.emptyCell,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}

