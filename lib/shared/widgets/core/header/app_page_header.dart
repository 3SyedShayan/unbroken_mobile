import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/app_back_button.dart';

enum _AppPageHeaderVariant { tab, page }

/// Unified top header for root bottom-nav tabs ([AppPageHeader.tab]) and
/// pushed sub-screens ([AppPageHeader.page]).
class AppPageHeader extends StatelessWidget {
  const AppPageHeader.tab({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.searchField,
    this.showSearch = false,
    this.padding,
  }) : _variant = _AppPageHeaderVariant.tab,
       showBack = false,
       onBack = null;

  const AppPageHeader.page({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBack = true,
    this.actions = const [],
    this.searchField,
    this.showSearch = false,
    this.padding,
  }) : _variant = _AppPageHeaderVariant.page;

  final _AppPageHeaderVariant _variant;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;
  final Widget? searchField;
  final bool showSearch;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final isTab = _variant == _AppPageHeaderVariant.tab;
    final resolvedPadding =
        padding ??
        (isTab
            ? Space.h.t20 + Space.t.t16 + Space.b.t12
            : Space.h.t20 + Space.t.t12 + Space.b.t12);

    return Padding(
      padding: resolvedPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isTab && showBack) ...[
                AppBackButton(onTap: onBack),
                Space.x.t12,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: (isTab ? AppText.h1b : AppText.h3b).cl(
                        AppTheme.c.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      if (isTab) Space.y.t04,
                      Text(
                        subtitle!,
                        style: (isTab ? AppText.b2 : AppText.l1).cl(
                          AppTheme.c.subText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                Space.x.t12,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions
                      .asMap()
                      .entries
                      .expand((e) => [if (e.key > 0) Space.x.t08, e.value])
                      .toList(),
                ),
              ],
            ],
          ),
          if (searchField != null)
            AnimatedSize(
              duration: AppProps.fast,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: showSearch
                  ? Padding(padding: Space.t.t12, child: searchField)
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }
}

