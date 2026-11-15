import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/habits/domain/streak_calculator.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

void main() {
  group('StreakCalculator', () {
    const settings = DaySettings(dayEndHour: 3);
    final today = DateTime(2026, 11, 14, 12, 0); // Logical day: 2026-11-14

    test('Empty completed days returns zero streak', () {
      final stats = StreakCalculator.calculateStreak(
        completedDays: {},
        asOf: today,
        settings: settings,
      );
      expect(stats.current, 0);
      expect(stats.best, 0);
      expect(stats.lastCompletedDay, isNull);
    });

    test('Completed today counts as streak 1', () {
      final stats = StreakCalculator.calculateStreak(
        completedDays: {DateTime(2026, 11, 14)},
        asOf: today,
        settings: settings,
      );
      expect(stats.current, 1);
      expect(stats.best, 1);
      expect(stats.lastCompletedDay, DateTime(2026, 11, 14));
    });

    test('Not completed today but completed yesterday anchors on yesterday (grace)', () {
      final stats = StreakCalculator.calculateStreak(
        completedDays: {
          DateTime(2026, 11, 12),
          DateTime(2026, 11, 13),
        },
        asOf: today, // Today is 14th, not yet completed
        settings: settings,
      );
      expect(stats.current, 2);
      expect(stats.best, 2);
    });

    test('Missed both today and yesterday breaks streak to zero', () {
      final stats = StreakCalculator.calculateStreak(
        completedDays: {
          DateTime(2026, 11, 10),
          DateTime(2026, 11, 11),
          DateTime(2026, 11, 12),
        },
        asOf: today, // 14th; 13th was missed
        settings: settings,
      );
      expect(stats.current, 0);
      expect(stats.best, 3);
    });

    test('Calculates best streak across historic runs', () {
      final stats = StreakCalculator.calculateStreak(
        completedDays: {
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 2),
          DateTime(2026, 10, 3),
          DateTime(2026, 10, 4),
          DateTime(2026, 10, 5), // run of 5
          DateTime(2026, 11, 13),
          DateTime(2026, 11, 14), // current run of 2
        },
        asOf: today,
        settings: settings,
      );
      expect(stats.current, 2);
      expect(stats.best, 5);
    });
  });
}

