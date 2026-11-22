import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

enum AnimatedTextDirection {
  up,
  down,
  fadeOnly,
}

class AppAnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Duration? duration;
  final double slideOffset;
  final AnimatedTextDirection direction;
  final AlignmentGeometry? alignment;

  const AppAnimatedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.duration,
    this.slideOffset = 10.0,
    this.direction = AnimatedTextDirection.up,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration ?? AppProps.medium;

    final double inOffset;
    final double outOffset;
    switch (direction) {
      case AnimatedTextDirection.up:
        inOffset = slideOffset;
        outOffset = -slideOffset;
      case AnimatedTextDirection.down:
        inOffset = -slideOffset;
        outOffset = slideOffset;
      case AnimatedTextDirection.fadeOnly:
        inOffset = 0.0;
        outOffset = 0.0;
    }

    final resolvedAlignment = alignment ??
        (textAlign == TextAlign.center
            ? Alignment.center
            : (textAlign == TextAlign.right
                ? Alignment.centerRight
                : Alignment.centerLeft));

    return AnimatedSwitcher(
      duration: effectiveDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: resolvedAlignment,
          children: <Widget>[
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey<String>(text);
        final targetDy = isIncoming ? inOffset : outOffset;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final progress = (1.0 - animation.value);
            final currentDy = progress * targetDy;
            return Opacity(
              opacity: animation.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0.0, currentDy),
                child: child,
              ),
            );
          },
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
