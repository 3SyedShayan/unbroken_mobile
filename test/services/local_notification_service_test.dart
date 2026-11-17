import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:unbroken_mobile/services/notifications/local_notification_service.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('LocalNotificationService Constants & Seams', () {
    test('notification constants match architecture specifications', () {
      expect(LocalNotificationService.morningReminderId, equals(1001));
      expect(LocalNotificationService.nightReminderId, equals(1002));
      expect(LocalNotificationService.channelId, equals('unbroken_daily_reminders'));
      expect(LocalNotificationService.channelName, equals('Daily Reminders'));
      expect(LocalNotificationService.morningPayload, equals('open_focus_tasks'));
      expect(LocalNotificationService.nightPayload, equals('open_habits_goals'));
    });

    test('singleton and test seam injection works', () {
      final original = LocalNotificationService.ins;
      final testInstance = LocalNotificationService.test();
      LocalNotificationService.ins = testInstance;
      expect(LocalNotificationService.ins, same(testInstance));
      LocalNotificationService.ins = original;
    });
  });

  group('LocalNotificationService parseTimeString', () {
    final service = LocalNotificationService.ins;

    test('parses valid 24h strings', () {
      expect(service.parseTimeString('09:00'), equals((9, 0)));
      expect(service.parseTimeString('21:45'), equals((21, 45)));
      expect(service.parseTimeString('00:00'), equals((0, 0)));
      expect(service.parseTimeString('23:59'), equals((23, 59)));
    });

    test('falls back to defaults for invalid strings', () {
      expect(service.parseTimeString('invalid'), equals((9, 0)));
      expect(service.parseTimeString('24:00'), equals((9, 0)));
      expect(service.parseTimeString('12:60'), equals((9, 0)));
      expect(service.parseTimeString('-1:30'), equals((9, 0)));
      expect(service.parseTimeString(''), equals((9, 0)));
      expect(
        service.parseTimeString('bad', defaultHour: 21, defaultMinute: 15),
        equals((21, 15)),
      );
    });
  });

  group('LocalNotificationService nextInstanceOfTime', () {
    final service = LocalNotificationService.ins;

    test('returns future time on the same calendar day if time has not passed', () {
      final utc = tz.getLocation('UTC');
      final now = tz.TZDateTime.now(utc);
      final futureHour = (now.hour + 2) % 24;

      if (futureHour > now.hour) {
        final next = service.nextInstanceOfTime(futureHour, 0, utc);
        expect(next.year, equals(now.year));
        expect(next.month, equals(now.month));
        expect(next.day, equals(now.day));
        expect(next.hour, equals(futureHour));
        expect(next.minute, equals(0));
      }
    });

    test('rolls over to tomorrow if time has already passed today', () {
      final utc = tz.getLocation('UTC');
      final now = tz.TZDateTime.now(utc);
      final pastHour = (now.hour - 2 + 24) % 24;

      if (pastHour < now.hour) {
        final next = service.nextInstanceOfTime(pastHour, 0, utc);
        expect(next.isAfter(now), isTrue);
        final expectedDate = now.add(const Duration(days: 1));
        expect(next.day, equals(expectedDate.day));
        expect(next.hour, equals(pastHour));
        expect(next.minute, equals(0));
      }
    });
  });
}
