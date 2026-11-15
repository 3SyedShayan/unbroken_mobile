import 'package:unbroken_mobile/features/core/habits/domain/streak_calculator.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class HabitMetrics {
  final Habit habit;
  final List<Entry> entries;
  final DaySettings settings;
  final DateTime now;
  final StreakStats stats;

  HabitMetrics({
    required this.habit,
    required this.entries,
    required this.settings,
    required this.now,
  }) : stats = StreakCalculator.stats(
          habit: habit,
          entries: entries,
          asOf: now,
          settings: settings,
        );

  int get totalDays {
    return entries.where((e) => e.habitId == habit.id).length;
  }

  int get consistency {
    final start = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    final currentLogicalDay = settings.logicalDay(now);
    final daysElapsed =
        currentLogicalDay.difference(start).inDays + 1;
    final totalElapsed = daysElapsed < 1 ? 1 : daysElapsed;
    final pct = (totalDays / totalElapsed * 100).round();
    return pct.clamp(0, 100);
  }
}

