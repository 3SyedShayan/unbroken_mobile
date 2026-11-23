import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/home/domain/today_summary_calculator.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

void main() {
  group('TodaySummaryCalculator', () {
    const settings = DaySettings(dayEndHour: 3, atRiskWindowHours: 4);
    final h1 = Habit(
      id: 'h_1',
      name: 'Meditate',
      createdAt: DateTime(2026, 11, 1),
    );
    final h2 = Habit(
      id: 'h_2',
      name: 'Read',
      createdAt: DateTime(2026, 11, 1),
    );

    Entry entry(String habitId, String dayKey) => Entry(
          id: '${habitId}_$dayKey',
          habitId: habitId,
          logicalDayKey: dayKey,
          timestamp: DateTime(2026, 11, 23, 12),
        );

    test('returns 0% and motivational prompt when both habits and tasks are empty', () {
      final summary = TodaySummaryCalculator.compute(
        activeHabits: const [],
        entries: const [],
        todayTasks: const [],
        now: DateTime(2026, 11, 23, 10, 0),
        settings: settings,
      );

      expect(summary.combinedPercent, 0);
      expect(summary.combinedRatio, 0.0);
      expect(summary.isUnbroken, isFalse);
      expect(summary.isAtRisk, isFalse);
      expect(summary.greeting, "Let's build momentum");
    });

    test('weights habits and tasks 50/50 and requires both for unbroken', () {
      final now = DateTime(2026, 11, 23, 14, 0);
      final dayKey = settings.logicalDayKey(now);

      // All 2 habits done, 0 of 1 tasks done => 50% (NOT unbroken)
      final halfSummary = TodaySummaryCalculator.compute(
        activeHabits: [h1, h2],
        entries: [entry('h_1', dayKey), entry('h_2', dayKey)],
        todayTasks: const [FocusItem(id: 's0', text: 'Ship PR', done: false)],
        now: now,
        settings: settings,
      );
      expect(halfSummary.habitsCompleted, 2);
      expect(halfSummary.tasksCompleted, 0);
      expect(halfSummary.combinedPercent, 50);
      expect(halfSummary.isUnbroken, isFalse);
      expect(halfSummary.greeting, 'Keep it rolling');

      // Now task is also done => 100% and unbroken!
      final fullSummary = TodaySummaryCalculator.compute(
        activeHabits: [h1, h2],
        entries: [entry('h_1', dayKey), entry('h_2', dayKey)],
        todayTasks: const [FocusItem(id: 's0', text: 'Ship PR', done: true)],
        now: now,
        settings: settings,
      );
      expect(fullSummary.combinedPercent, 100);
      expect(fullSummary.isUnbroken, isTrue);
      expect(fullSummary.greeting, "You're unbroken today");
    });

    test('falls back to habits-only when no tasks exist', () {
      final now = DateTime(2026, 11, 23, 14, 0);
      final dayKey = settings.logicalDayKey(now);

      final summary = TodaySummaryCalculator.compute(
        activeHabits: [h1, h2],
        entries: [entry('h_1', dayKey), entry('h_2', dayKey)],
        todayTasks: const [],
        now: now,
        settings: settings,
      );
      expect(summary.combinedPercent, 100);
      expect(summary.isUnbroken, isTrue);
    });

    test('computes at-risk countdown accurately across dayEndHour boundary', () {
      // 1:30 AM on Nov 24 with dayEndHour=3 => logical day Nov 23, ends at 3:00 AM (1h 30m left)
      final lateNight = DateTime(2026, 11, 24, 1, 30);
      final summary = TodaySummaryCalculator.compute(
        activeHabits: [h1, h2],
        entries: const [],
        todayTasks: const [],
        now: lateNight,
        settings: settings,
      );

      expect(summary.isAtRisk, isTrue);
      expect(summary.atRiskCountdownLabel, '1h 30m left to stay unbroken');
      expect(summary.greeting, 'Protect your streak');
    });
  });
}
