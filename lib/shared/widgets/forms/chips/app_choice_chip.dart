import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/headless/app_touch.dart';

/// Unified filter / selection pill chip powered strictly by [AppTheme] and [AppText].
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.avatar,
    this.selectedColor,
    this.padding,
  });

  final Widget label;
  final Widget? avatar;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final activeBg = selectedColor ?? AppTheme.c.primary;
    final fgColor = selected ? AppTheme.c.onPrimary : AppTheme.c.text;
    final textStyle = (selected ? AppText.b2b : AppText.b2).cl(fgColor);

    return AppTouch(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: AppProps.fast,
        padding: padding ?? Space.sym(SpaceToken.t16, SpaceToken.t08),
        decoration: BoxDecoration(
          color: selected ? activeBg : AppTheme.c.subBackground,
          borderRadius: AppProps.radiusPill.radius(),
          border: Border.all(
            color: selected ? activeBg : AppTheme.c.border,
          ),
        ),
        child: DefaultTextStyle.merge(
          style: textStyle,
          child: IconTheme.merge(
            data: IconThemeData(
              size: 14,
              color: selected ? AppTheme.c.onPrimary : AppTheme.c.subText,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar != null) ...[
                  avatar!,
                  Space.x.t04,
                ],
                label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
