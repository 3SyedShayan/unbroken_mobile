import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

void main() {
  group('HabitsState Ordering & Sink Behavior', () {
    final habitA = Habit(
      id: 'h_a',
      name: 'Habit A',
      sortOrder: 0,
      createdAt: DateTime(2026, 1, 1),
    );
    final habitB = Habit(
      id: 'h_b',
      name: 'Habit B',
      sortOrder: 1,
      createdAt: DateTime(2026, 1, 1),
    );
    final habitC = Habit(
      id: 'h_c',
      name: 'Habit C',
      sortOrder: 2,
      createdAt: DateTime(2026, 1, 1),
    );

    final baseState = HabitsState(
      habits: [habitA, habitB, habitC],
      entries: const [],
      fetch: BlocState<List<Habit>>(),
      action: BlocState<void>(),
    );

    test('activeHabits sorts by fallback sortOrder when habitOrder is empty', () {
      final active = baseState.activeHabits(const []);
      expect(active.map((h) => h.id).toList(), ['h_a', 'h_b', 'h_c']);
    });

    test('activeHabits respects centralized habitOrder when present', () {
      // Reordered as C, A, B
      final active = baseState.activeHabits(['h_c', 'h_a', 'h_b']);
      expect(active.map((h) => h.id).toList(), ['h_c', 'h_a', 'h_b']);
    });

    test('displayHabits sinks completed habits to bottom while preserving habitOrder', () {
      final now = DateTime(2026, 11, 14, 12, 0);
      const settings = DaySettings(
        dayEndHour: 3,
        habitOrder: ['h_c', 'h_a', 'h_b'],
        sinkCompletedHabits: true,
      );

      // Mark habit C as completed for today
      final stateWithCheckIn = baseState.copyWith(
        entries: [
          Entry(
            id: 'h_c_2026-11-14',
            habitId: 'h_c',
            logicalDayKey: '2026-11-14',
            timestamp: now,
          ),
        ],
      );

      final displayed = stateWithCheckIn.displayHabits(
        asOf: now,
        settings: settings,
      );

      // C should be sunk to bottom; A and B stay on top in relative order
      expect(displayed.map((h) => h.id).toList(), ['h_a', 'h_b', 'h_c']);
    });
  });

  group('HabitsState.recentDaysCompletion', () {
    final habitA = Habit(
      id: 'h_a',
      name: 'Habit A',
      sortOrder: 0,
      createdAt: DateTime(2026, 1, 1),
    );
    final habitB = Habit(
      id: 'h_b',
      name: 'Habit B',
      sortOrder: 1,
      createdAt: DateTime(2026, 1, 1),
    );

    test('returns 10 days ordered oldest to today even when dayEndHour > 0', () {
      const settings = DaySettings(dayEndHour: 3);
      // 10 AM on Nov 14 => logical today is 2026-11-14
      final today = settings.logicalDay(DateTime(2026, 11, 14, 10, 0));
      final state = HabitsState(
        habits: [habitA, habitB],
        entries: [
          Entry(
            id: 'h_a_2026-11-05',
            habitId: 'h_a',
            logicalDayKey: '2026-11-05',
            timestamp: DateTime(2026, 11, 5, 12),
          ),
          Entry(
            id: 'h_a_2026-11-10',
            habitId: 'h_a',
            logicalDayKey: '2026-11-10',
            timestamp: DateTime(2026, 11, 10, 12),
          ),
          Entry(
            id: 'h_a_2026-11-14',
            habitId: 'h_a',
            logicalDayKey: '2026-11-14',
            timestamp: DateTime(2026, 11, 14, 9),
          ),
          // Entry for another habit on Nov 13 should be ignored
          Entry(
            id: 'h_b_2026-11-13',
            habitId: 'h_b',
            logicalDayKey: '2026-11-13',
            timestamp: DateTime(2026, 11, 13, 12),
          ),
        ],
        fetch: BlocState<List<Habit>>(),
        action: BlocState<void>(),
      );

      final result = state.recentDaysCompletion(habit: habitA, today: today);

      expect(result.length, 10);
      // Window: Nov 5 (0), 6 (1), 7 (2), 8 (3), 9 (4), 10 (5), 11 (6), 12 (7), 13 (8), 14 (9)
      expect(
        result,
        [true, false, false, false, false, true, false, false, false, true],
      );
    });

    test('handles month boundaries cleanly using calendar arithmetic', () {
      final today = DateTime(2026, 3, 3);
      final state = HabitsState(
        habits: [habitA],
        entries: [
          // 9 days before 2026-03-03 is 2026-02-22
          Entry(
            id: 'h_a_2026-02-22',
            habitId: 'h_a',
            logicalDayKey: '2026-02-22',
            timestamp: DateTime(2026, 2, 22, 12),
          ),
          Entry(
            id: 'h_a_2026-02-28',
            habitId: 'h_a',
            logicalDayKey: '2026-02-28',
            timestamp: DateTime(2026, 2, 28, 12),
          ),
          Entry(
            id: 'h_a_2026-03-01',
            habitId: 'h_a',
            logicalDayKey: '2026-03-01',
            timestamp: DateTime(2026, 3, 1, 12),
          ),
        ],
        fetch: BlocState<List<Habit>>(),
        action: BlocState<void>(),
      );

      final result = state.recentDaysCompletion(habit: habitA, today: today);

      // Window: Feb 22 (0), 23 (1), 24 (2), 25 (3), 26 (4), 27 (5), 28 (6), Mar 1 (7), 2 (8), 3 (9)
      expect(
        result,
        [true, false, false, false, false, false, true, true, false, false],
      );
    });
  });
}
