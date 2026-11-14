import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/headless/app_touch.dart';

/// Visual hierarchy level for [AppSectionHeader].
enum AppSectionHeaderStyle {
  /// Prominent feed / detail section heading (`AppText.h3b`).
  primary,

  /// Muted sub-group caption (`AppText.b2b` in `subText`), used in settings and forms.
  subtle,
}

/// Consistent section heading with optional trailing action (e.g. "See All").
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.style = AppSectionHeaderStyle.primary,
    this.actionLabel,
    this.onActionTap,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final AppSectionHeaderStyle style;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final titleStyle = switch (style) {
      AppSectionHeaderStyle.primary => AppText.h3b.cl(AppTheme.c.text),
      AppSectionHeaderStyle.subtle => AppText.b2b.cl(AppTheme.c.subText),
    };

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onActionTap != null) ...[
            Space.x.t12,
            AppTouch(
              onTap: onActionTap!,
              child: Text(
                actionLabel ?? 'See All',
                style: AppText.b2b.cl(AppTheme.c.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

