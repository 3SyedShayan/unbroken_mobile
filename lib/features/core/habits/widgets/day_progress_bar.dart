import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';

class DayProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const DayProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final pct = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final isAllDone = total > 0 && completed == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final fillWidth = (maxWidth * pct).clamp(8.0, maxWidth);

            return Container(
              height: 9,
              width: maxWidth,
              decoration: BoxDecoration(
                color: AppColors.emptyCell,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: AppProps.medium,
                  curve: Curves.easeOutCubic,
                  width: total == 0 ? 0 : fillWidth,
                  height: 9,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentWarm],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            );
          },
        ),
        Space.y.t08,
        AppAnimatedText(
          text: isAllDone
              ? 'All $total done — nice fire 🔥'
              : '$completed of $total habits done today',
          style: AppText.b2.cl(
            isAllDone ? AppColors.accent : AppColors.subText,
          ),
        ),
      ],
    );
  }
}
