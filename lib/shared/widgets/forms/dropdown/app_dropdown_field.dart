import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/forms/decorations/app_input_decorations.dart';

double get appDropdownMenuMaxHeight {
  final h = (AppMedia.height * 0.42);
  return h.clamp(200.un(), 400.un()).toDouble();
}

Widget appDropdownCollapsedLabel(String text) {
  return Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14.sp(),
        color: AppTheme.c.text,
      ),
    ),
  );
}

DropdownMenuItem<T> appDropdownMenuItem<T>({
  required T value,
  required String text,
  required bool showDividerBelow,
}) {
  return DropdownMenuItem<T>(
    value: value,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp(),
            color: AppTheme.c.text,
          ),
        ),
        if (showDividerBelow) const _AppDropdownMenuItemSeparator(),
      ],
    ),
  );
}

/// Inset separator between menu rows: soft gradient + rounded caps (reads clearer than a flat [Divider]).
class _AppDropdownMenuItemSeparator extends StatelessWidget {
  const _AppDropdownMenuItemSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12.un(),
        8.un(),
        12.un(),
        0,
      ),
      child: Container(
        height: 1.5.un(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.un()),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.0),
              AppTheme.c.primary.withValues(alpha: 0.14),
              AppTheme.c.subText.withValues(alpha: 0.12),
              AppTheme.c.primary.withValues(alpha: 0.16),
              AppTheme.c.primary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.c.primary.withValues(alpha: 0.07),
              blurRadius: 3.un(),
              offset: Offset(0, 0.5.un()),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration appDropdownFieldDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffixTrailing,
}) {
  return AppInputDecoration.auth(
    hintText: hint,
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: suffixTrailing != null
        ? Padding(
            padding: EdgeInsets.all(12.un()),
            child: suffixTrailing,
          )
        : null,
  );
}

/// Compact spinner for dropdown suffix while options load.
class AppDropdownFieldProgress extends StatelessWidget {
  const AppDropdownFieldProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.un(),
      height: 18.un(),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
