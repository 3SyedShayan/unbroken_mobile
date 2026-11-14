import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';

/// Unified empty-state view for directories, inboxes, and filtered lists.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.actionStyle = AppButtonStyle.creamy,
    this.accentColor,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final AppButtonStyle actionStyle;
  final Color? accentColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final accent = accentColor ?? AppTheme.c.primary;

    return Center(
      child: Padding(
        padding: padding ?? Space.a.t32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Space.a.t20,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: accent,
              ),
            ),
            Space.y.t20,
            Text(
              title,
              style: AppText.h3b.cl(AppTheme.c.text),
              textAlign: TextAlign.center,
            ),
            Space.y.t08,
            Text(
              subtitle,
              style: AppText.b2.cl(AppTheme.c.subText),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              Space.y.t20,
              AppButton(
                label: actionLabel,
                icon: actionIcon,
                style: actionStyle,
                size: .small,
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

