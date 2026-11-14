import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

extension ImplicitAnimationExtension on Widget {
  Widget withAnimatedOpacity({
    required bool visible,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration ?? AppProps.fast,
      curve: curve,
      child: this,
    );
  }

  /// Animates size changes smoothly whenever this widget's bounds change.
  Widget withAnimatedSize({
    Duration? duration,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
  }) {
    return AnimatedSize(
      duration: duration ?? AppProps.fast,
      curve: curve,
      alignment: alignment,
      child: this,
    );
  }

  /// Wraps this widget in an [AnimatedSwitcher] for smooth transition cross-fading.
  Widget withAnimatedSwitcher({
    Key? key,
    Duration? duration,
    Curve switchInCurve = Curves.easeOutCubic,
    Curve switchOutCurve = Curves.easeInCubic,
  }) {
    return AnimatedSwitcher(
      duration: duration ?? AppProps.medium,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      child: KeyedSubtree(key: key ?? ValueKey(runtimeType), child: this),
    );
  }
}
