part of '../configs.dart';

/// Color tokens for the light theme matching Uni Connect brand.
sealed class AppColors {
  static const primary = Color(0xFF1968B3);
  static const primaryLight = Color(0xFF4A90C9);
  static const primaryDark = Color(0xFF0D4A7A);

  static const accent = Color(0xFFF59A23);

  /// Text / icon color rendered ON a primary-colored surface.
  static const onPrimary = Color(0xFFFFFFFF);

  /// Text / icon color rendered ON an accent-colored surface.
  static const onAccent = Color(0xFFFFFFFF);

  static const text = Color(0xFF0F2A44);
  static const subText = Color(0xFF5A6B7D);
  static const hint = Color(0xFFA0A7B4);

  static const background = Color(0xFFF7F9FC);
  static const specBackground = Color(0xFFFFFFFF);
  static const subBackground = Color(0xFFF0F4F8);

  /// Subtle border for cards, inputs, and dividers.
  static const border = Color(0xFFE8EDF3);

  static const success = Color(0xFF2E7D4F);
  static const error = Color(0xFFC62828);
  static const warning = Color(0xFFF59A23);
  static const info = Color(0xFF1968B3);
}

/// Color tokens for the dark theme matching Uni Connect brand.
sealed class AppColorsDark {
  static const primary = Color(0xFF4A90C9);
  static const accent = Color(0xFFF59A23);

  static const onPrimary = Color(0xFFFFFFFF);
  static const onAccent = Color(0xFFFFFFFF);

  static const text = Color(0xFFF8FAFC);
  static const subText = Color(0xFF94A3B8);
  static const background = Color(0xFF0B192C);

  static const subBackground = Color(0xFF16253B);
  static const specBackground = Color(0xFF101F33);

  static const border = Color(0xFF223854);

  static const error = Color(0xFFEF5350);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
}
