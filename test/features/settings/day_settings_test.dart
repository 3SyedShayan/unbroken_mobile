import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

void main() {
  group('DaySettings 3:00 AM Day Boundary', () {
    const settings = DaySettings(dayEndHour: 3);

    test('1:30 AM counts towards previous calendar day', () {
      final date = DateTime(2026, 11, 14, 1, 30);
      final logical = settings.logicalDay(date);
      expect(logical, DateTime(2026, 11, 13));
      expect(settings.logicalDayKey(date), '2026-11-13');
    });

    test('3:00 AM counts towards current calendar day', () {
      final date = DateTime(2026, 11, 14, 3, 0);
      final logical = settings.logicalDay(date);
      expect(logical, DateTime(2026, 11, 14));
      expect(settings.logicalDayKey(date), '2026-11-14');
    });

    test('11:59 PM counts towards current calendar day', () {
      final date = DateTime(2026, 11, 14, 23, 59, 59);
      final logical = settings.logicalDay(date);
      expect(logical, DateTime(2026, 11, 14));
      expect(settings.logicalDayKey(date), '2026-11-14');
    });

    test('dayKey and startOfDay roundtrip correctly', () {
      final date = DateTime(2026, 11, 14);
      final key = DaySettings.dayKey(date);
      expect(key, '2026-11-14');
      final parsed = DaySettings.startOfDay(key);
      expect(parsed, DateTime(2026, 11, 14));
    });

    test('startOfDay rejects invalid formats', () {
      expect(DaySettings.startOfDay('invalid'), isNull);
      expect(DaySettings.startOfDay('2026-13-01'), isNull);
      expect(DaySettings.startOfDay('2026-02-32'), isNull);
    });
  });
}

