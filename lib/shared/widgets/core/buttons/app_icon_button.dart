import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/headless/app_touch.dart';

/// Standard circular icon action button for screen headers and toolbars.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.padding,
    this.color,
    this.iconColor,
    this.iconSize,
    this.tooltip,
    this.isActive = false,
    this.showDot = false,
  });

  final VoidCallback onTap;
  final IconData icon;
  final EdgeInsets? padding;
  final Color? color;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;
  final bool isActive;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final bgColor =
        color ??
        (isActive
            ? AppTheme.c.primary.withValues(alpha: 0.12)
            : AppTheme.c.subBackground);
    final fgColor =
        iconColor ?? (isActive ? AppTheme.c.primary : AppTheme.c.text);

    Widget target = AppTouch(
      onTap: onTap,
      child: Container(
        padding: padding ?? Space.a.t08,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: color == null
              ? Border.all(
                  color: isActive
                      ? AppTheme.c.primary.withValues(alpha: 0.35)
                      : AppTheme.c.border,
                )
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize ?? SpaceToken.t20,
          color: fgColor,
        ),
      ),
    );

    if (showDot) {
      target = Stack(
        clipBehavior: Clip.none,
        children: [
          target,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppTheme.c.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.c.background, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip == null) return target;
    return Tooltip(message: tooltip!, child: target);
  }
}
