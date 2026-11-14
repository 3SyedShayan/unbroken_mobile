import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/headless/app_touch.dart';

/// Standard circular pop/back button matching [AppIconButton] geometry.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.padding,
    this.color,
    this.iconColor,
    this.iconSize,
    this.tooltip = 'Back',
  });

  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? color;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final button = AppTouch(
      onTap: onTap ?? () => ''.pop(context),
      child: Container(
        padding: padding ?? Space.a.t08,
        decoration: BoxDecoration(
          color: color ?? AppTheme.c.subBackground,
          shape: BoxShape.circle,
          border: color == null ? Border.all(color: AppTheme.c.border) : null,
        ),
        child: Icon(
          LucideIcons.arrow_left,
          size: iconSize ?? SpaceToken.t20,
          color: iconColor ?? AppTheme.c.text,
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
