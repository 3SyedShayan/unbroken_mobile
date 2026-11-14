import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/router/router.dart';

/// Contract for global snackbar notification services.
abstract interface class ISnackbarService {
  void showSuccess(
    String message, {
    String? title,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  });

  void showError(
    String message, {
    String? title,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  });

  void showWarning(
    String message, {
    String? title,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  });

  void showInfo(
    String message, {
    String? title,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  });

  void hideCurrent([BuildContext? context]);
}

/// Provider-backed service managing consistent global snackbar notifications.
///
/// Dispatches floating bottom snackbars using [ScaffoldMessengerState] with
/// tactile haptics, theme token alignment, and optional action buttons.
class SnackbarService extends ChangeNotifier implements ISnackbarService {
  SnackbarService._();

  /// Singleton instance used by the static facade and provider registration.
  static final SnackbarService instance = SnackbarService._();

  ScaffoldMessengerState? _resolveMessenger([BuildContext? context]) {
    if (context != null) {
      final local = ScaffoldMessenger.maybeOf(context);
      if (local != null) return local;
    }
    return scaffoldMessengerKey.currentState ??
        (navigator.currentContext != null
            ? ScaffoldMessenger.maybeOf(navigator.currentContext!)
            : null);
  }

  @override
  void showSuccess(
    String message, {
    String? title = 'Success',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    HapticFeedback.lightImpact();
    _show(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppTheme.c.success,
      duration: duration,
      action: action,
      onTap: onTap,
      context: context,
    );
  }

  @override
  void showError(
    String message, {
    String? title = 'Error',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    HapticFeedback.mediumImpact();
    _show(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppTheme.c.error,
      duration: duration,
      action: action,
      onTap: onTap,
      context: context,
    );
  }

  @override
  void showWarning(
    String message, {
    String? title = 'Warning',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    HapticFeedback.lightImpact();
    _show(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppTheme.c.warning,
      duration: duration,
      action: action,
      onTap: onTap,
      context: context,
    );
  }

  @override
  void showInfo(
    String message, {
    String? title = 'Info',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    HapticFeedback.lightImpact();
    _show(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppTheme.c.primary,
      duration: duration,
      action: action,
      onTap: onTap,
      context: context,
    );
  }

  @override
  void hideCurrent([BuildContext? context]) {
    _resolveMessenger(context)?.hideCurrentSnackBar();
  }

  void _show({
    required String? title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    final messenger = _resolveMessenger(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final contentWidget = Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        Space.x.t12,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title.isNotEmpty) ...[
                Text(
                  title,
                  style: AppText.b2b.cl(Colors.white),
                ),
                Space.y.t04,
              ],
              Text(
                message,
                style: AppText.b2.cl(Colors.white),
              ),
            ],
          ),
        ),
      ],
    );

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor.withValues(alpha: 0.95),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: SpaceToken.t16,
          vertical: SpaceToken.t12,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SpaceToken.t16,
          vertical: 12.sp(),
        ),
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        content: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: contentWidget,
              )
            : contentWidget,
      ),
    );
  }
}

/// Static facade for [SnackbarService], maintaining project-wide consistency.
class AppSnackbars {
  AppSnackbars._();

  static void success(
    String message, {
    String? title = 'Success',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
  }) {
    SnackbarService.instance.showSuccess(
      message,
      title: title,
      duration: duration,
      action: action,
      onTap: onTap,
    );
  }

  static void error(
    String message, {
    String? title = 'Error',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
  }) {
    SnackbarService.instance.showError(
      message,
      title: title,
      duration: duration,
      action: action,
      onTap: onTap,
    );
  }

  static void warning(
    String message, {
    String? title = 'Warning',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
  }) {
    SnackbarService.instance.showWarning(
      message,
      title: title,
      duration: duration,
      action: action,
      onTap: onTap,
    );
  }

  static void info(
    String message, {
    String? title = 'Info',
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onTap,
  }) {
    SnackbarService.instance.showInfo(
      message,
      title: title,
      duration: duration,
      action: action,
      onTap: onTap,
    );
  }

  static void hideCurrent() {
    SnackbarService.instance.hideCurrent();
  }
}

/// BuildContext extension for reactive/context-based snackbar calls via Provider.
extension SnackbarContextExtension on BuildContext {
  SnackbarService get snackbar =>
      Provider.of<SnackbarService>(this, listen: false);
}
