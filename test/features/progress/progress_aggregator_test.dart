import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_focus.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_aggregator.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

void main() {
  group('ProgressAggregator intensity helpers', () {
    test('ratioToLevel maps boundary thresholds to 0..4', () {
      expect(ProgressAggregator.ratioToLevel(0.0), 0);
      expect(ProgressAggregator.ratioToLevel(-0.1), 0);
      expect(ProgressAggregator.ratioToLevel(0.01), 1);
      expect(ProgressAggregator.ratioToLevel(0.34), 1);
      expect(ProgressAggregator.ratioToLevel(0.35), 2);
      expect(ProgressAggregator.ratioToLevel(0.67), 2);
      expect(ProgressAggregator.ratioToLevel(0.68), 3);
      expect(ProgressAggregator.ratioToLevel(0.99), 3);
      expect(ProgressAggregator.ratioToLevel(1.0), 4);
    });

    test('streakLengthToLevel maps consecutive run length to 0..4', () {
      expect(ProgressAggregator.streakLengthToLevel(0), 0);
      expect(ProgressAggregator.streakLengthToLevel(1), 1);
      expect(ProgressAggregator.streakLengthToLevel(2), 1);
      expect(ProgressAggregator.streakLengthToLevel(3), 2);
      expect(ProgressAggregator.streakLengthToLevel(6), 2);
      expect(ProgressAggregator.streakLengthToLevel(7), 3);
      expect(ProgressAggregator.streakLengthToLevel(13), 3);
      expect(ProgressAggregator.streakLengthToLevel(14), 4);
      expect(ProgressAggregator.streakLengthToLevel(30), 4);
    });
  });

  group('ProgressAggregator.compute', () {
    const settings = DaySettings(dayEndHour: 3);
    final now = DateTime(2026, 11, 23, 15, 0); // logical today: 2026-11-23

    Entry entry(String habitId, DateTime day) {
      final key = DaySettings.dayKey(day);
      return Entry(
        id: '${habitId}_$key',
        habitId: habitId,
        logicalDayKey: key,
        timestamp: day,
      );
    }

    DailyFocus focusFor(DateTime day, List<(String text, bool done)> tasks) {
      final key = DaySettings.dayKey(day);
      final slots = <String, FocusItem>{};
      for (var i = 0; i < tasks.length; i++) {
        slots['$i'] = FocusItem(id: 's$i', text: tasks[i].$1, done: tasks[i].$2);
      }
      return DailyFocus(logicalDayKey: key, slots: slots);
    }

    test('newly created habit does not downgrade past perfect days', () {
      final oldHabit = Habit(
        id: 'h_old',
        name: 'Old Habit',
        createdAt: DateTime(2026, 10, 1, 9, 0),
      );
      final newHabit = Habit(
        id: 'h_new',
        name: 'New Habit',
        createdAt: DateTime(2026, 11, 23, 9, 0), // created today only
      );

      final yesterday = DateTime(2026, 11, 22);
      final snapshot = ProgressAggregator.compute(
        activeHabits: [oldHabit, newHabit],
        entries: [entry('h_old', yesterday)],
        focusList: const [],
        goals: const [],
        settings: settings,
        range: ProgressRange.oneMonth,
        now: now,
      );

      final yesterdaySummary = snapshot.daysByKey['2026-11-22']!;
      expect(yesterdaySummary.habitsDone, 1);
      expect(yesterdaySummary.habitsTotal, 1);
      expect(yesterdaySummary.habitsLevel, 4);
      expect(yesterdaySummary.allLevel, 4);
      expect(yesterdaySummary.isUnbroken, isTrue);

      final todaySummary = snapshot.daysByKey['2026-11-23']!;
      expect(todaySummary.habitsTotal, 2);
      expect(todaySummary.habitsDone, 0);
    });

    test('weights habits and tasks 50/50 on task days and habits-only on task-free days', () {
      final h1 = Habit(
        id: 'h_1',
        name: 'Run',
        createdAt: DateTime(2026, 10, 1, 8, 0),
      );

      final dayWithTasks = DateTime(2026, 11, 20);
      final dayWithoutTasks = DateTime(2026, 11, 21);

      final snapshot = ProgressAggregator.compute(
        activeHabits: [h1],
        entries: [
          entry('h_1', dayWithTasks),
          entry('h_1', dayWithoutTasks),
        ],
        focusList: [
          // 1/3 tasks done (0.333) + 1/1 habit done (1.0) => avg 0.666 => level 2
          focusFor(dayWithTasks, [
            ('Secret task 1', true),
            ('Secret task 2', false),
            ('Secret task 3', false),
          ]),
        ],
        goals: const [],
        settings: settings,
        range: ProgressRange.oneMonth,
        now: now,
      );

      final d1 = snapshot.daysByKey['2026-11-20']!;
      expect(d1.habitsLevel, 4);
      expect(d1.tasksLevel, 1); // 1/3 = 0.333 <= 0.34 => level 1
      expect(d1.allLevel, 2); // (1.0 + 0.333) / 2 = 0.666 <= 0.67 => level 2
      expect(d1.isUnbroken, isFalse);

      final d2 = snapshot.daysByKey['2026-11-21']!;
      expect(d2.habitsLevel, 4);
      expect(d2.tasksTotal, 0);
      expect(d2.allLevel, 4);
      expect(d2.isUnbroken, isTrue);
    });

    test('streak-depth shading carries prior streak into window day 1', () {
      final h1 = Habit(
        id: 'h_1',
        name: 'Meditate',
        createdAt: DateTime(2026, 9, 1, 8, 0),
      );

      // Build 20-day unbroken streak ending on startDay (Oct 25) -> level 4 on Oct 25
      final startDay = DateTime(2026, 10, 25); // 30-day window: Oct 25..Nov 23
      final entries = <Entry>[
        for (var i = 19; i >= 0; i--)
          entry('h_1', DateTime(startDay.year, startDay.month, startDay.day - i)),
      ];

      final snapshot = ProgressAggregator.compute(
        activeHabits: [h1],
        entries: entries,
        focusList: const [],
        goals: const [],
        settings: settings,
        range: ProgressRange.oneMonth,
        now: now,
      );

      final levels = snapshot.habitSummaries.single.streakDepthLevels;
      // 14 prior days + Oct 25 = 15th consecutive day => level 4!
      expect(levels['2026-10-25'], 4);
      expect(levels['2026-10-26'], 0);
    });

    test('computes period-over-period delta when prior window is valid and observed', () {
      final h1 = Habit(
        id: 'h_1',
        name: 'Read',
        createdAt: DateTime(2026, 8, 1, 8, 0),
      );

      // 3 active days in previous 30d window (Sep 25..Oct 24), 10 in current 30d (Oct 25..Nov 23)
      final entries = <Entry>[
        entry('h_1', DateTime(2026, 10, 1)),
        entry('h_1', DateTime(2026, 10, 2)),
        entry('h_1', DateTime(2026, 10, 3)),
        for (var d = 1; d <= 10; d++) entry('h_1', DateTime(2026, 11, d)),
      ];

      final withDelta = ProgressAggregator.compute(
        activeHabits: [h1],
        entries: entries,
        focusList: const [],
        goals: const [],
        settings: settings,
        range: ProgressRange.oneMonth,
        now: now,
        observedWindowDays: 95,
      );
      // current = round(10/30 * 100) = 33, prev = round(3/30 * 100) = 10 => delta = +23
      expect(withDelta.deltaVsPreviousPercent, 23);

      // When observedWindowDays < range.days * 2, delta is suppressed (null)
      final truncated = ProgressAggregator.compute(
        activeHabits: [h1],
        entries: entries,
        focusList: const [],
        goals: const [],
        settings: settings,
        range: ProgressRange.oneMonth,
        now: now,
        observedWindowDays: 45,
      );
      expect(truncated.deltaVsPreviousPercent, isNull);
    });

    test('computes strongestWeekday, topHabit, and goalsCompletedInRange across 3M and 6M', () {
      final h1 = Habit(
        id: 'h_1',
        name: 'Lift',
        createdAt: DateTime(2026, 5, 1, 8, 0),
      );
      final h2 = Habit(
        id: 'h_2',
        name: 'Stretch',
        createdAt: DateTime(2026, 5, 1, 8, 0),
      );

      // Populate 8 Tuesdays in Nov/Oct/Sep so activeDaysCount >= 7 and Tuesdays dominate
      final entries = <Entry>[];
      for (var i = 0; i < 12; i++) {
        final d = DateTime(2026, 11, 17 - i * 7); // Tuesdays!
        entries.add(entry('h_1', d));
        entries.add(entry('h_2', d));
      }

      final goals = [
        Goal(
          id: 'g1',
          folderId: 'f1',
          title: 'In range completed',
          isCompleted: true,
          completedAt: DateTime(2026, 11, 10, 14),
        ),
        Goal(
          id: 'g2',
          folderId: 'f1',
          title: 'Incomplete',
          isCompleted: false,
        ),
        Goal(
          id: 'g3',
          folderId: 'f1',
          title: 'Old completed',
          isCompleted: true,
          completedAt: DateTime(2026, 6, 1, 14),
        ),
      ];

      final snapshot3M = ProgressAggregator.compute(
        activeHabits: [h1, h2],
        entries: entries,
        focusList: const [],
        goals: goals,
        settings: settings,
        range: ProgressRange.threeMonths,
        now: now,
      );

      expect(snapshot3M.daysByKey.length, 91);
      expect(snapshot3M.strongestWeekday?.weekday, DateTime.tuesday);
      expect(snapshot3M.strongestWeekday?.weekdayName, 'Tuesdays');
      expect(snapshot3M.topHabit?.habit.id, 'h_1');
      expect(snapshot3M.goalsCompletedInRange, 1);

      final snapshot6M = ProgressAggregator.compute(
        activeHabits: [h1, h2],
        entries: entries,
        focusList: const [],
        goals: goals,
        settings: settings,
        range: ProgressRange.sixMonths,
        now: now,
      );
      expect(snapshot6M.daysByKey.length, 182);
    });
  });
}
