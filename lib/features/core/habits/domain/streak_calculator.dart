import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

abstract class StreakCalculator {
  static StreakStats stats({
    required Habit habit,
    required List<Entry> entries,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final completedDays = <DateTime>{};
    for (final entry in entries) {
      if (entry.habitId == habit.id) {
        final parsed = DaySettings.startOfDay(entry.logicalDayKey);
        if (parsed != null) {
          completedDays.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      }
    }
    return calculateStreak(
      completedDays: completedDays,
      asOf: asOf,
      settings: settings,
    );
  }

  static StreakStats calculateStreak({
    required Set<DateTime> completedDays,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    if (completedDays.isEmpty) {
      return const StreakStats(current: 0, best: 0, lastCompletedDay: null);
    }

    final sorted = completedDays.toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;

    for (final day in sorted) {
      if (previous != null &&
          DateTime(day.year, day.month, day.day) ==
              DateTime(previous.year, previous.month, previous.day)
                  .add(const Duration(days: 1))) {
        run += 1;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      previous = day;
    }

    final currentDay = settings.logicalDay(asOf);
    final previousDay = currentDay.subtract(const Duration(days: 1));

    DateTime? anchor;
    if (completedDays.contains(currentDay)) {
      anchor = currentDay;
    } else if (completedDays.contains(previousDay)) {
      anchor = previousDay;
    } else {
      anchor = null;
    }

    var current = 0;
    if (anchor != null) {
      var cursor = anchor;
      while (completedDays.contains(cursor)) {
        current += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    return StreakStats(
      current: current,
      best: best,
      lastCompletedDay: sorted.last,
    );
  }
}

