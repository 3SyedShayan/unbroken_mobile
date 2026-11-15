part of '../configs.dart';

/// The design's habit accent palette (warm, per-habit color).
abstract class HabitPalette {
  static const colors = [
    '#E2603A', // Flame Orange
    '#E0A32E', // Flame Amber
    '#4FA96A', // Emerald Green
    '#2FA39A', // Teal
    '#3E7BC4', // Cobalt Blue
    '#8B5C8F', // Violet Plum
  ];
  static const defaultColor = '#E2603A';

  static Color parse(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('0xFF$cleaned'));
    } else if (cleaned.length == 8) {
      return Color(int.parse('0x$cleaned'));
    }
    return const Color(0xFFE2603A);
  }
}

/// Color tokens for the light theme matching Unbroken brand.
sealed class AppColors {
  /// Primary brand accent, active streak flame (`#E2603A`).
  static const primary = Color(0xFFE2603A);
  static const primaryLight = Color(0xFFE87D5E);
  static const primaryDark = Color(0xFFBF4824);

  /// Default brand orange accent (`#F26B21`).
  static const accent = Color(0xFFF26B21);
  static const accentWarm = Color(0xFFF5A623);
  static const flameAmber = Color(0xFFE0A32E);

  /// Text / icon color rendered ON a primary-colored surface.
  static const onPrimary = Color(0xFFFFFFFF);

  /// Text / icon color rendered ON an accent-colored surface.
  static const onAccent = Color(0xFFFFFFFF);

  /// Primary high-contrast typography (`#2A211B`).
  static const text = Color(0xFF2A211B);

  /// Secondary captions, subheadings, and metadata (`#8A7B6E`).
  static const subText = Color(0xFF8A7B6E);
  static const hint = Color(0xFFB0A091);
  static const inkFaint = Color(0xFFB0A091);
  static const inkMuted = Color(0xFF9A8A7B);
  static const inkFainter = Color(0xFFA8977F);

  /// Warm cream card/popover fill (`#FFFBF4`).
  static const background = Color(0xFFFFFBF4);

  /// Elevated card / inner row surface (`#FFFFFF`).
  static const specBackground = Color(0xFFFFFFFF);

  /// Main ground gradient / subBackground (`#F5E7D3`).
  static const subBackground = Color(0xFFF5E7D3);

  /// Hairline card outlines and row dividers (`#F3EADF`).
  static const border = Color(0xFFF3EADF);
  static const divider = Color(0xFFF1E7D9);
  static const fieldBorder = Color(0xFFECDFCC);
  static const dashedBorder = Color(0xFFE4D5C0);
  static const emptyCell = Color(0xFFF1E7D9);
  static const backButton = Color(0xFFF3E7D6);

  static const success = Color(0xFF4FA96A);
  static const error = Color(0xFFE04838);
  static const warning = Color(0xFFE0A32E);
  static const info = Color(0xFF3E7BC4);
}

/// Color tokens for the dark theme matching Unbroken brand.
sealed class AppColorsDark {
  static const primary = Color(0xFFE2603A);
  static const accent = Color(0xFFF26B21);
  static const accentWarm = Color(0xFFF5A623);
  static const flameAmber = Color(0xFFE0A32E);

  static const onPrimary = Color(0xFFFFFFFF);
  static const onAccent = Color(0xFFFFFFFF);

  static const text = Color(0xFFFFFBF4);
  static const subText = Color(0xFFB0A091);
  static const hint = Color(0xFF8A7B6E);
  static const inkFaint = Color(0xFF8A7B6E);
  static const inkMuted = Color(0xFF8A7B6E);
  static const inkFainter = Color(0xFF6E5F52);

  static const background = Color(0xFF1A1412);
  static const subBackground = Color(0xFF241C18);
  static const specBackground = Color(0xFF2F241F);

  static const border = Color(0xFF3D3029);
  static const divider = Color(0xFF332721);
  static const fieldBorder = Color(0xFF473931);
  static const dashedBorder = Color(0xFF524239);
  static const emptyCell = Color(0xFF2F241F);
  static const backButton = Color(0xFF332721);

  static const error = Color(0xFFE04838);
  static const success = Color(0xFF4FA96A);
  static const warning = Color(0xFFE0A32E);
  static const info = Color(0xFF3E7BC4);
}
