import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unbroken_mobile/configs/configs.dart';

/// A global, reusable shimmer loading container that wraps the [shimmer] package.
///
/// Automatically uses the application's semantic theme colors for consistent look-and-feel.
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  /// Factory helper for creating a rectangular shimmer block with custom dimensions.
  static Widget rectangular({
    Key? key,
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AppShimmer(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4.un()),
        ),
      ),
    );
  }

  /// Factory helper for creating a circular shimmer block.
  static Widget circular({
    Key? key,
    required double radius,
  }) {
    return AppShimmer(
      key: key,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppTheme.c.specBackground,
      highlightColor: highlightColor ?? AppTheme.c.subBackground,
      period: period,
      direction: direction,
      child: child,
    );
  }
}

extension ShimmerExtension on Widget {
  /// Wraps this widget in an [AppShimmer] loading effect.
  ///
  /// If [enabled] is false, returns this widget unmodified.
  Widget withShimmer({
    bool enabled = true,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
    ShimmerDirection direction = ShimmerDirection.ltr,
  }) {
    if (!enabled) return this;
    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      direction: direction,
      child: this,
    );
  }
}

