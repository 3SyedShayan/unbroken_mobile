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
  }) : stats = _resolveStats(
          habit: habit,
          entries: entries,
          settings: settings,
          now: now,
        );

  static StreakStats _resolveStats({
    required Habit habit,
    required List<Entry> entries,
    required DaySettings settings,
    required DateTime now,
  }) {
    final computed = StreakCalculator.stats(
      habit: habit,
      entries: entries,
      asOf: now,
      settings: settings,
    );
    final best =
        computed.best > habit.bestStreak ? computed.best : habit.bestStreak;
    final today = settings.logicalDay(now);
    final todayKey = DaySettings.dayKey(today);
    final yesterdayKey = DaySettings.dayKey(
      DateTime(today.year, today.month, today.day - 1),
    );
    final isStillActive = computed.current > 0 &&
        (habit.lastCompletedDayKey == todayKey ||
            habit.lastCompletedDayKey == yesterdayKey);
    final current = (isStillActive && habit.currentStreak > computed.current)
        ? habit.currentStreak
        : computed.current;
    return StreakStats(
      current: current,
      best: best,
      lastCompletedDay: computed.lastCompletedDay,
    );
  }

  int get totalDays {
    final loadedCount = entries.where((e) => e.habitId == habit.id).length;
    return loadedCount > habit.totalCheckIns ? loadedCount : habit.totalCheckIns;
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

