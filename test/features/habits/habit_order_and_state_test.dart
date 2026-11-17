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
}
