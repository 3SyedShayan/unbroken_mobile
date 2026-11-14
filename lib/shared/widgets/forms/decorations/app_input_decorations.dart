import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

abstract final class AppInputDecoration {
  static InputDecoration auth({
    required String hintText,
    required String labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle: TextStyle(color: AppTheme.c.subText, fontSize: 14.sp()),
      floatingLabelStyle: TextStyle(
        color: AppTheme.c.primary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.c.specBackground,
      border: OutlineInputBorder(
        borderRadius: 12.radius(),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: 12.radius(),
        borderSide: BorderSide(color: AppTheme.c.primary.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: 12.radius(),
        borderSide: BorderSide(color: AppTheme.c.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: 12.radius(),
        borderSide: BorderSide(color: AppTheme.c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: 12.radius(),
        borderSide: BorderSide(color: AppTheme.c.error, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.un(),
        vertical: 16.un(),
      ),
    );
  }
}
