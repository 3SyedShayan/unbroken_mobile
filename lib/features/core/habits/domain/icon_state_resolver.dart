import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

enum IconState {
  noHabits,
  untouched,
  partial,
  allDone,
  atRisk,
}

abstract class IconStateResolver {
  static IconState state({
    required List<Habit> habits,
    required List<Entry> entries,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    if (activeHabits.isEmpty) return IconState.noHabits;

    final todayKey = settings.logicalDayKey(asOf);
    final completedHabitIds = entries
        .where((e) => e.logicalDayKey == todayKey)
        .map((e) => e.habitId)
        .toSet();

    final completedCount = activeHabits
        .where((h) => completedHabitIds.contains(h.id))
        .length;

    if (completedCount == activeHabits.length) {
      return IconState.allDone;
    }

    final end = settings.endOfLogicalDay(settings.logicalDay(asOf));
    final windowStart = end.subtract(Duration(hours: settings.atRiskWindowHours));

    if (asOf.isAfter(windowStart) || asOf.isAtSameMomentAs(windowStart)) {
      return IconState.atRisk;
    }

    return completedCount == 0 ? IconState.untouched : IconState.partial;
  }
}

