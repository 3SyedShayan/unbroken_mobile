import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

/// Semantic color variant for [AppBadge].
enum AppBadgeVariant {
  primary,
  accent,
  success,
  warning,
  error,
  neutral,
}

/// A compact status badge / pill used across Uni Connect.
///
/// Typical usages:
/// - User roles: "ADMIN", "MODERATOR", "STUDENT"
/// - Internship status: "PAID", "REMOTE", "FULL-TIME", "PENDING"
/// - Event tags: "LIVE", "UPCOMING", "CANCELLED", "WORKSHOP"
/// - Community badges: "OFFICIAL", "CAMPUS CLUB"
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.showDot = false,
    this.customColor,
  });

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;
  final bool showDot;
  final Color? customColor;

  Color _resolveColor() {
    if (customColor != null) return customColor!;
    return switch (variant) {
      AppBadgeVariant.primary => AppTheme.c.primary,
      AppBadgeVariant.accent => AppTheme.c.accent,
      AppBadgeVariant.success => AppTheme.c.success,
      AppBadgeVariant.warning => AppTheme.c.warning,
      AppBadgeVariant.error => AppTheme.c.error,
      AppBadgeVariant.neutral => AppTheme.c.subText,
    };
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = _resolveColor();

    return Container(
      padding: Space.sym(SpaceToken.t08, SpaceToken.t04),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 999.radius(),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            Space.x.t04,
          ] else if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            Space.x.t04,
          ],
          Text(
            label,
            style: AppText.l1b.cl(color),
          ),
        ],
      ),
    );
  }
}
