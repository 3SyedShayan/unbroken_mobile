import 'package:unbroken_mobile/configs/configs.dart';
import 'package:flutter/material.dart';

class AnimatedLinearProgress extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  const AnimatedLinearProgress({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 10,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    Widget buildProgressBar(double targetValue) {
      return TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: 0.0, end: targetValue),
        builder: (context, animatedValue, child) {
          return LinearProgressIndicator(
            value: animatedValue,
            backgroundColor: backgroundColor,
            minHeight: minHeight,
            borderRadius: borderRadius,
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          );
        },
      );
    }

    if (delay == Duration.zero) {
      return buildProgressBar(value);
    }

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LinearProgressIndicator(
            value: 0.0,
            backgroundColor: backgroundColor,
            minHeight: minHeight,
            borderRadius: borderRadius,
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          );
        }

        return buildProgressBar(value);
      },
    );
  }

}

extension AnimatedLinearProgressDoubleExtension on double {
  Widget toAnimatedLinearProgress({
    Color? backgroundColor,
    Color? valueColor,
    double minHeight = 10,
    BorderRadius? borderRadius,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return AnimatedLinearProgress(
      value: this,
      backgroundColor: backgroundColor ?? AppTheme.c.subBackground,
      valueColor: valueColor ?? AppTheme.c.primary,
      minHeight: minHeight,
      borderRadius: borderRadius,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }
}

extension AnimatedLinearProgressWidgetExtension on Widget {
  Widget withLinearProgress({
    required double value,
    Color? backgroundColor,
    Color? valueColor,
    double minHeight = 4,
    BorderRadius? borderRadius,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeOutCubic,
    bool showProgress = true,
  }) {
    if (!showProgress) return this;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        this,
        AnimatedLinearProgress(
          value: value,
          backgroundColor: backgroundColor ?? AppTheme.c.subBackground,
          valueColor: valueColor ?? AppTheme.c.primary,
          minHeight: minHeight,
          borderRadius: borderRadius,
          duration: duration,
          curve: curve,
        ),
      ],
    );
  }
}

