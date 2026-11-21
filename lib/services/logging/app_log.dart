import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/firebase/crash/crashlytics.dart';

enum AppLogLevel {
  debug('\x1B[37m'), // White
  info('\x1B[36m'), // Cyan
  warning('\x1B[33m'), // Yellow
  error('\x1B[31m'), // Red
  success('\x1B[32m') // Green
  ;

  final String colorCode;

  const AppLogLevel(this.colorCode);
}

extension LogExtension on Object {
  void appLog({
    String tag = 'APP_LOG',
    AppLogLevel level = AppLogLevel.debug,
    bool enableColors = true,
    bool showCallerInfo = false,
    bool toCrashlytics = false,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now().toIso8601String();
    toCrashlytics = toCrashlytics || level != AppLogLevel.debug;

    final color = (enableColors && _supportsAnsiColors) ? level.colorCode : '';
    final reset = (enableColors && _supportsAnsiColors) ? '\x1B[0m' : '';

    final shouldShowCaller = showCallerInfo || level == AppLogLevel.error;
    final callerInfo = shouldShowCaller ? _getCallerInfo() : '';
    final callerSection = callerInfo.isNotEmpty ? ' [$callerInfo]' : '';

    final header = '[$tag$callerSection] $this';

    // Format top 2-3 project stack frames for errors to avoid console clutter
    final formattedStack = (stackTrace != null)
        ? _formatConciseStackTrace(stackTrace)
        : (error is Error && error.stackTrace != null)
            ? _formatConciseStackTrace(error.stackTrace!)
            : null;

    final fullMessage =
        formattedStack != null ? '$header\n$formattedStack' : header;

    // 1. VM Service logger (Flutter DevTools / analyzer)
    developer.log(
      '$color$header$reset',
      time: DateTime.now(),
      level: _logLevelToInt(level),
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // 2. Direct console output in debug mode (terminal `flutter run`, Xcode, logcat)
    if (kDebugMode) {
      debugPrint('$color$fullMessage$reset');
    }

    // 3. Crashlytics reporting for warnings and errors
    final crashlyticsMessage = '[$tag$callerSection] $now $this';
    if (toCrashlytics && level != AppLogLevel.error) {
      crashlyticsMessage.flog();
    } else if (level == AppLogLevel.error) {
      crashlyticsMessage.flog();
    }
  }

  bool get _supportsAnsiColors =>
      !Platform.isWindows || stdout.supportsAnsiEscapes;

  int _logLevelToInt(AppLogLevel level) => switch (level) {
    AppLogLevel.debug => 500,
    AppLogLevel.info => 800,
    AppLogLevel.warning => 900,
    AppLogLevel.error => 1000,
    AppLogLevel.success => 850,
  };

  String _getCallerInfo() {
    try {
      final lines = StackTrace.current.toString().split('\n');
      for (final line in lines) {
        if (!line.contains('app_log.dart') &&
            !line.contains('LogExtension') &&
            !line.contains('app_bloc_observer.dart')) {
          final match = RegExp(r'\((.+?):(\d+):\d+\)$').firstMatch(line.trim());
          if (match != null) {
            final file =
                match.group(1)?.split(Platform.pathSeparator).last ?? 'unknown';
            final lineNum = match.group(2) ?? '0';
            return '$file:$lineNum';
          }
        }
      }
    } catch (_) {}
    return '';
  }

  String _formatConciseStackTrace(StackTrace stackTrace, {int maxFrames = 3}) {
    final lines = stackTrace.toString().split('\n');
    final relevant = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // Filter out internal framework plumbing to keep console clean and short
      if (trimmed.contains('dart:ui') ||
          trimmed.contains('dart:async') ||
          trimmed.contains('package:flutter/') ||
          trimmed.contains('package:nested') ||
          trimmed.contains('app_log.dart') ||
          trimmed.contains('app_bloc_observer.dart')) {
        continue;
      }
      relevant.add('    → $trimmed');
      if (relevant.length >= maxFrames) break;
    }
    if (relevant.isEmpty) {
      for (final line in lines.take(2)) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) relevant.add('    → $trimmed');
      }
    }
    return relevant.join('\n');
  }
}
