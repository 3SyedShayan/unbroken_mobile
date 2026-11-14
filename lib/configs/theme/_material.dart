part of '../configs.dart';

TextTheme _buildTextTheme(_ThemeModel theme) {
  const base = TextStyle(fontFamily: FontFamily.poppins);

  return TextTheme(
    displayLarge: base.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    displayMedium: base.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    displaySmall: base.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    headlineLarge: base.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    headlineMedium: base.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    headlineSmall: base.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    titleLarge: base.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: theme.text,
    ),
    titleMedium: base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.text,
    ),
    titleSmall: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: theme.text,
    ),
    bodyLarge: base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: theme.text,
    ),
    bodyMedium: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: theme.text,
    ),
    bodySmall: base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: theme.subText,
    ),
    labelLarge: base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: theme.text,
    ),
    labelMedium: base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.subText,
    ),
    labelSmall: base.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: theme.subText,
    ),
  );
}

ThemeData _buildMaterialTheme({
  required Brightness brightness,
  required _ThemeModel theme,
  required ColorScheme colorScheme,
  required Color textButtonForeground,
  required Color cursorColor,
  required Color? floatingForeground,
  required Color? floatingBackground,
}) {
  return ThemeData(
    brightness: brightness,
    useMaterial3: false,
    fontFamily: FontFamily.poppins,
    primaryColor: theme.primary,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: theme.background,
    iconTheme: IconThemeData(color: theme.text),
    primaryIconTheme: IconThemeData(color: theme.text),
    appBarTheme: AppBarTheme(
      backgroundColor: theme.background,
      foregroundColor: theme.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: theme.text),
      actionsIconTheme: IconThemeData(color: theme.text),
      titleTextStyle: TextStyle(
        fontFamily: FontFamily.poppins,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: theme.text,
      ),
    ),
    textTheme: _buildTextTheme(theme),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textButtonForeground,
        textStyle: const TextStyle(
          fontFamily: FontFamily.poppins,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: floatingBackground,
      foregroundColor: floatingForeground,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: cursorColor,
      selectionColor: cursorColor.withValues(alpha: 0.3),
      selectionHandleColor: cursorColor,
    ),
  );
}

final materialLightTheme = _buildMaterialTheme(
  brightness: Brightness.light,
  theme: _lightTheme,
  colorScheme: ColorScheme.light(
    primary: _lightTheme.primary,
    secondary: _lightTheme.accent,
    surface: _lightTheme.specBackground,
    error: _lightTheme.error,
    onPrimary: _lightTheme.onPrimary,
    onError: Colors.white,
  ),
  textButtonForeground: _lightTheme.primary,
  cursorColor: _lightTheme.primary,
  floatingBackground: _lightTheme.primary,
  floatingForeground: _lightTheme.onPrimary,
);

final materialDarkTheme = _buildMaterialTheme(
  brightness: Brightness.dark,
  theme: _darkTheme,
  colorScheme: ColorScheme.dark(
    primary: _darkTheme.primary,
    secondary: _darkTheme.accent,
    surface: _darkTheme.specBackground,
    error: _darkTheme.error,
    onPrimary: _darkTheme.onPrimary,
    onError: Colors.white,
  ),
  textButtonForeground: _darkTheme.text,
  cursorColor: _darkTheme.accent,
  floatingBackground: _darkTheme.primary,
  floatingForeground: _darkTheme.onPrimary,
);
