part of '../configs.dart';

/// Responsive design utility that scales UI elements based on device characteristics.
///
/// AppUnit automatically calibrates to match Figma designs exactly while maintaining
/// device-aware responsiveness. Call [autoCalibrateFigma] after [init] to enable
/// automatic calibration.
///
/// Example:
/// ```dart
/// // Designer specifies 12px padding
/// Container(padding: EdgeInsets.all(12.un()))  // Returns exactly 12px
///
/// // Designer specifies 16px font
/// Text('Hello', style: TextStyle(fontSize: 16.font()))  // Returns exactly 16px
/// ```
///
/// See also:
/// - [autoCalibrateFigma] for automatic calibration setup
/// - [calibrateForDesign] for manual calibration
/// - [un] for general measurements (width, height, margins, padding)
/// - [font] for font sizes
/// - [sp] for spacing values
class AppUnit {
  /// Base padding value calculated from the device ratio.
  /// Defaults to standard mobile base (6.0) to prevent zero-sizing before init.
  static double padding = 6.0;

  /// Core scaling ratio calculated from screen dimensions and pixel density.
  /// Typically capped at 2.4 on most devices. Defaults to 2.0 for standard mobile.
  static double ratio = 2.0;

  /// Figma design calibration multiplier applied to all AppUnit outputs.
  ///
  /// Default is 1.0 (no calibration / 1:1 design scale).
  static double designCalibration = 1.0;

  /// Initializes AppUnit by calculating the scaling ratio based on device characteristics.
  ///
  /// This method:
  /// 1. Calculates base ratio from screen aspect ratio (width/height)
  /// 2. Factors in device pixel density (DPI)
  /// 3. Applies adjustments for small, high-DPI screens
  /// 4. Applies large screen multipliers with safety caps
  /// 5. Applies small screen density caps
  /// 6. Calculates base padding value
  ///
  /// Note: This should be called after [AppMedia.init] and before using any
  /// AppUnit methods.
  static void init() {
    ratio = AppMedia.width / AppMedia.height;
    final pixelDensity = AppMedia.media().devicePixelRatio;
    ratio = (ratio) + ((pixelDensity + ratio) / 2);

    if (AppMedia.width <= 380 && pixelDensity >= 3) {
      ratio *= 0.85;
    }

    _initLargeScreens();
    _initSmallScreensHighDensity();

    padding = ratio * 3;
  }

  /// Applies large screen scaling with a safety cap.
  ///
  /// Multiplies [ratio] by 1.5 to scale up UI elements for larger screens,
  /// but caps it at 2.4 to prevent elements from becoming too large.
  static void _initLargeScreens() {
    const safe = 2.4;

    ratio *= 1.5;

    if (ratio > safe) {
      ratio = safe;
    }
  }

  /// Applies caps to prevent UI elements from becoming too large on small screens.
  ///
  /// Uses screen size breakpoints from [AppScreen] to determine appropriate caps:
  /// - Non-small screens (>480px): cap at 2.0
  /// - Non-extra-small screens (>360px): cap at 1.6
  /// - Non-extra-extra-small screens (>300px): cap at 1.4
  ///
  /// This ensures that high-DPI small devices don't get oversized UI elements.
  static void _initSmallScreensHighDensity() {
    if (!AppScreen.sm && ratio > 2.0) {
      ratio = 2.0;
    }
    if (!AppScreen.xs && ratio > 1.6) {
      ratio = 1.6;
    }
    if (!AppScreen.xxs && ratio > 1.4) {
      ratio = 1.4;
    }
  }

  /// Returns calibrated spacing value for padding, margins, and space tokens.
  ///
  /// Scales proportionally with device padding relative to standard mobile (~6.0).
  ///
  /// Parameters:
  /// - [multiplier]: Spacing value (e.g. 12 for 12dp spacing/font)
  static double sp([num multiplier = 1.0]) {
    if (padding == 0.0 || ratio == 0.0) {
      return multiplier.toDouble() * designCalibration;
    }
    final scale = padding / 6.0;
    return multiplier * scale * designCalibration;
  }

  /// Returns calibrated measurement for general UI elements (width, height, margins, padding).
  ///
  /// Converts Figma/design pixel values to device-appropriate logical pixels,
  /// scaling smoothly with screen ratio relative to standard mobile design base.
  ///
  /// Parameters:
  /// - [unit]: The pixel value from your Figma design
  static double un(num unit) {
    if (ratio == 0.0) {
      return unit.toDouble() * designCalibration;
    }
    // Base design ratio for standard mobile (~2.0) has ((2.0 * 0.77) + 1.0) == 2.54.
    // Normalizing by 2.54 yields 1:1 on standard mobile and smooth scaling elsewhere.
    final scale = ((ratio * 0.77) + 1.0) / 2.54;
    return unit * scale * designCalibration;
  }

  /// Returns calibrated font size for text elements.
  static double font(num unit) {
    if (ratio == 0.0) {
      return unit.toDouble() * designCalibration;
    }
    // Normalizing base ratio ((2.0 * 2.0) + 2.0) == 6.0 yields 1:1 on standard mobile.
    final scale = ((ratio * 2.0) + 2.0) / 6.0;
    return unit * scale * designCalibration;
  }

  /// Automatically calibrates [designCalibration] to match Figma outputs exactly.
  static void autoCalibrateFigma([double figmaUnit = 12.0]) {
    if (ratio == 0.0) return;
    final currentScale = ((ratio * 0.77) + 1.0) / 2.54;
    if (currentScale > 0) {
      designCalibration = 1.0 / currentScale;
    }
  }

  /// Manually sets the design calibration multiplier.
  ///
  /// Parameters:
  /// - [calibration]: The multiplier to apply to all AppUnit outputs.
  static void calibrateForDesign(double calibration) {
    designCalibration = calibration;
  }
}
