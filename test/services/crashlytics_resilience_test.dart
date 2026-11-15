import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/services/firebase/crash/crashlytics.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

void main() {
  group('EnhancedCrashlytics and AppLog resilience when uninitialized', () {
    test('appLog safely completes across all log levels without throwing', () {
      expect(
        () {
          'Debug message'.appLog(level: AppLogLevel.debug);
          'Info message'.appLog(level: AppLogLevel.info);
          'Warning message'.appLog(level: AppLogLevel.warning);
          'Error message'.appLog(level: AppLogLevel.error);
          'Success message'.appLog(level: AppLogLevel.success);
          'Explicit crashlytics message'.appLog(toCrashlytics: true);
        },
        returnsNormally,
      );
    });

    test('flog and custom keys safe before Firebase initialization', () {
      expect(
        () {
          EnhancedCrashlytics.ins.flog('Test flog');
          EnhancedCrashlytics.ins.setCustomKey('test_key', 'test_value');
          EnhancedCrashlytics.ins.trackUserAction('tap_button');
        },
        returnsNormally,
      );
    });

    test('recordNonFatalEvent and recordFatalEvent do not throw when uninitialized', () async {
      await expectLater(
        EnhancedCrashlytics.ins.recordNonFatalEvent(
          Exception('Non-fatal test'),
          StackTrace.current,
          reason: 'Testing uninitialized resilience',
        ),
        completes,
      );

      await expectLater(
        EnhancedCrashlytics.ins.recordFatalEvent(
          Exception('Fatal test'),
          StackTrace.current,
          reason: 'Testing uninitialized resilience',
        ),
        completes,
      );
    });
  });
}

