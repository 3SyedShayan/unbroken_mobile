import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unbroken_mobile/core/env/app_env.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';
import 'package:unbroken_mobile/services/logging/route_logger.dart';
part '_exts.dart';

class EnhancedCrashlytics {
  EnhancedCrashlytics._();

  static EnhancedCrashlytics? _instance;
  FirebaseCrashlytics? _firebaseCrashlytics;
  static String? _lastAction;
  bool _apiContextSet = false;

  static EnhancedCrashlytics get ins {
    _instance ??= EnhancedCrashlytics._();
    return _instance!;
  }

  FirebaseCrashlytics? get _crashlytics {
    if (_firebaseCrashlytics != null) return _firebaseCrashlytics;
    if (Firebase.apps.isNotEmpty) {
      try {
        _firebaseCrashlytics = FirebaseCrashlytics.instance;
        return _firebaseCrashlytics;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        'Firebase not initialized. Skipping Enhanced Crashlytics init.'.appLog(
          level: AppLogLevel.warning,
          tag: 'CRASHLYTICS',
        );
        return;
      }

      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      _firebaseCrashlytics = crashlytics;

      await _setAppVersionInfo();

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        if (kDebugMode) {
          FlutterError.presentError(errorDetails);
        } else {
          originalOnError?.call(errorDetails);
        }
        _addNavigationContext().then((_) {
          _crashlytics?.recordFlutterError(errorDetails);
        }).catchError((_) {});
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          '[UNHANDLED_ASYNC] $error'.appLog(
            tag: 'PLATFORM',
            level: AppLogLevel.error,
            error: error,
            stackTrace: stack,
          );
        }
        _recordEvent(
          error,
          stack,
          fatal: true,
          reason: 'PlatformDispatcher unhandled error',
        );
        return true;
      };

      'Enhanced Crashlytics initialized successfully'.appLog(
        level: AppLogLevel.info,
        tag: 'CRASHLYTICS',
      );
    } catch (e) {
      'Error in Enhanced Crashlytics init: $e'.appLog(
        level: AppLogLevel.error,
        tag: 'CRASHLYTICS',
      );
    }
  }

  Future<void> recordNonFatalEvent(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool includeNavigation = false,
    String? lastAction,
  }) async {
    await _recordEvent(
      exception,
      stackTrace,
      reason: reason,
      includeNavigation: includeNavigation,
      lastAction: lastAction,
    );
  }

  Future<void> recordFatalEvent(
    dynamic exception,
    StackTrace stackTrace, {
    String? reason,
    String? lastAction,
  }) async {
    await _recordEvent(
      exception,
      stackTrace,
      reason: reason,
      fatal: true,
      includeNavigation: true,
      lastAction: lastAction,
    );
  }

  /// This is the BRAIN of the Crashlytics, it has almost all the configurations
  /// that we can use to record the events to Crashlytics.
  Future<void> _recordEvent(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    bool includeNavigation = false,
    String? lastAction,
  }) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;

    try {
      /// Add navigation context if requested or if fatal, just to avoid extra memory usage
      /// we are not adding the navigation context for non-fatal errors. BUT, if needed
      /// we can use [includeNavigation] flag.
      if (includeNavigation || fatal) {
        await _addNavigationContext();
      }

      // Add last action if provided
      if (lastAction != null) {
        await crashlytics.setCustomKey('last_action', lastAction);
      } else if (_lastAction != null) {
        await crashlytics.setCustomKey('last_action', _lastAction!);
      }

      if (exception is HttpFault) {
        final body = exception.body;
        Future.wait([
          if (body.status != null)
            crashlytics.setCustomKey('api_status_code', body.status!),
          if (body.message != null)
            crashlytics.setCustomKey('api_response_message', body.message!),
          if (body.data != null) ...[
            crashlytics.setCustomKey('api_response', body.data.toString()),
            if (body.data!['uri'] != null)
              crashlytics.setCustomKey('api_url', body.data!['uri'].toString()),
            if (body.data!['method'] != null)
              crashlytics.setCustomKey(
                'api_method',
                body.data!['method'].toString(),
              ),
          ],
        ]);

        _apiContextSet = true;
      } else if (exception is http.ClientException) {
        Future.wait([
          crashlytics.setCustomKey('api_response_message', exception.message),
          if (exception.uri != null)
            crashlytics.setCustomKey('api_url', exception.uri.toString()),
        ]);
        _apiContextSet = true;
      } else if (exception is http.Response) {
        Future.wait([
          crashlytics.setCustomKey('api_status_code', exception.statusCode),
          if (exception.request != null) ...[
            crashlytics.setCustomKey('api_method', exception.request!.method),
            crashlytics.setCustomKey(
              'api_url',
              exception.request!.url.toString(),
            ),
          ],
          if (exception.body.isNotEmpty)
            crashlytics.setCustomKey('api_response', exception.body),
        ]);
        _apiContextSet = true;
      } else if (_apiContextSet) {
        Future.wait([
          crashlytics.setCustomKey('api_status_code', 0),
          crashlytics.setCustomKey('api_method', ''),
          crashlytics.setCustomKey('api_url', ''),
          crashlytics.setCustomKey('api_response', ''),
          crashlytics.setCustomKey('api_response_message', ''),
        ]);
        _apiContextSet = false;
      }

      await crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      'Recorded ${fatal ? 'fatal' : 'non-fatal'} error: $reason'.appLog(
        level: AppLogLevel.info,
        tag: 'CRASHLYTICS',
      );
    } catch (e) {
      'Failed to record error to Crashlytics: $e'.appLog(
        level: AppLogLevel.error,
        tag: 'CRASHLYTICS',
      );
    }
  }

  void flog(String message) {
    try {
      _crashlytics?.log(message);
    } catch (_) {}
  }

  /// The only missing piece of the puzzle in Crashlytics are it doesn't
  /// recording the Navigation History. So, we already have a service [RouteLogger]
  /// that is recording the Navigation History. Hence, we'll be using that to have our
  /// history stored in Crashlytics.
  Future<void> _addNavigationContext() async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;

    try {
      /// Get last 10 routes from RouteLogger, this is to avoid any memory issues
      /// with the navigation history.
      final routeHistory = RouteLogger.routeHistory;
      final last10Routes = routeHistory.length > 10
          ? routeHistory.sublist(routeHistory.length - 10)
          : routeHistory;

      // Set navigation breadcrumbs
      await crashlytics.setCustomKey(
        'navigation_history',
        last10Routes.join(' → '),
      );
    } catch (e) {
      'Failed to add navigation context: $e'.appLog(
        level: AppLogLevel.error,
        tag: 'CRASHLYTICS',
      );
    }
  }

  Future<void> _setAppVersionInfo() async {
    try {
      await _crashlytics?.setCustomKey('flavor', Env.current.flavor.name);
    } catch (_) {}
  }

  void setCustomKey(String key, dynamic value) {
    try {
      _crashlytics?.setCustomKey(key, value);
    } catch (_) {}
  }

  /// Track user action for crash context, this might NOT be used very much
  /// but keeping it here for future reference.
  void trackUserAction(String action) {
    _lastAction = action;
    'User action: $action'.appLog(level: AppLogLevel.info, tag: 'USER_ACTION');
  }

  Future<void> setUserContext({String? userId}) async {
    if (userId != null) {
      try {
        await _crashlytics?.setUserIdentifier(userId);
      } catch (_) {}
    }
  }

  Future<void> clearUserContext() async {
    try {
      await _crashlytics?.setUserIdentifier('');
    } catch (_) {}
  }

  /// --- ONLY FOR TESTING --- ///
  /// Forces a crash for testing
  void testCrash() {
    assert(
      !kReleaseMode,
      'testCrash() should only be used in debug/profile mode',
    );
    _crashlytics?.crash();
  }

  /// Test navigation tracking
  Future<void> testNavigationTracking() async {
    assert(
      !kReleaseMode,
      'testNavigationTracking() should only be used in debug/profile mode',
    );

    // Add navigation context and log it
    await _addNavigationContext();
    'Navigation tracking test completed'.appLog(
      level: AppLogLevel.info,
      tag: 'CRASHLYTICS',
    );

    // Optionally trigger a non-fatal error to see navigation context
    await recordNonFatalEvent(
      'Navigation tracking test',
      StackTrace.current,
      reason: 'Testing navigation context in crashes',
      includeNavigation: true,
    );
  }
}
