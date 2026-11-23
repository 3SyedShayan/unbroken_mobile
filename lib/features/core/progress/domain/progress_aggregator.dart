import 'package:unbroken_mobile/features/core/focus/domain/focus_streak_calculator.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_focus.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/habits/domain/streak_calculator.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

abstract class ProgressAggregator {
  static const Map<int, String> _weekdayNames = {
    DateTime.monday: 'Mondays',
    DateTime.tuesday: 'Tuesdays',
    DateTime.wednesday: 'Wednesdays',
    DateTime.thursday: 'Thursdays',
    DateTime.friday: 'Fridays',
    DateTime.saturday: 'Saturdays',
    DateTime.sunday: 'Sundays',
  };

  /// Maps a completion ratio in [0.0, 1.0] to a 5-level GitHub intensity bucket (0..4).
  static int ratioToLevel(double ratio) {
    if (ratio <= 0.0) return 0;
    if (ratio <= 0.34) return 1;
    if (ratio <= 0.67) return 2;
    if (ratio < 1.0) return 3;
    return 4;
  }

  static ProgressSnapshot compute({
    required List<Habit> activeHabits,
    required List<Entry> entries,
    required List<DailyFocus> focusList,
    required List<Goal> goals,
    required DaySettings settings,
    required ProgressRange range,
    required DateTime now,
    int? observedWindowDays,
  }) {
    final today = settings.logicalDay(now);
    final endDay = DateTime(today.year, today.month, today.day);
    final startDay = DateTime(endDay.year, endDay.month, endDay.day - (range.days - 1));

    // Index entries by dayKey and by habitId for O(1) lookups.
    final habitsDoneByDay = <String, Set<String>>{};
    final daysDoneByHabit = <String, Set<String>>{};
    for (final entry in entries) {
      habitsDoneByDay
          .putIfAbsent(entry.logicalDayKey, () => <String>{})
          .add(entry.habitId);
      daysDoneByHabit
          .putIfAbsent(entry.habitId, () => <String>{})
          .add(entry.logicalDayKey);
    }

    // Index focus documents by logicalDayKey.
    final focusByDay = <String, DailyFocus>{
      for (final f in focusList) f.logicalDayKey: f,
    };

    // Precompute logical creation day for each active habit.
    final habitCreatedDay = <String, DateTime>{
      for (final h in activeHabits) h.id: settings.logicalDay(h.createdAt),
    };

    final currentPeriod = _evaluateWindow(
      startDay: startDay,
      endDay: endDay,
      activeHabits: activeHabits,
      habitCreatedDay: habitCreatedDay,
      habitsDoneByDay: habitsDoneByDay,
      focusByDay: focusByDay,
    );

    int? deltaVsPrevious;
    final canComputeDelta =
        observedWindowDays == null || observedWindowDays >= range.days * 2;
    if (canComputeDelta) {
      final prevEnd = DateTime(startDay.year, startDay.month, startDay.day - 1);
      final prevStart = DateTime(prevEnd.year, prevEnd.month, prevEnd.day - (range.days - 1));
      final prevPeriod = _evaluateWindow(
        startDay: prevStart,
        endDay: prevEnd,
        activeHabits: activeHabits,
        habitCreatedDay: habitCreatedDay,
        habitsDoneByDay: habitsDoneByDay,
        focusByDay: focusByDay,
      );
      if (prevPeriod.activeDaysCount >= 3 && prevPeriod.eligibleDaysCount > 0) {
        deltaVsPrevious = currentPeriod.consistencyPercent - prevPeriod.consistencyPercent;
      }
    }

    // Per-habit summaries preserving caller's activeHabits order.
    final habitSummaries = <HabitRangeSummary>[];
    var bestHabitStreak = 0;
    var activeStreaksCount = 0;

    for (final habit in activeHabits) {
      final completedKeys = daysDoneByHabit[habit.id] ?? const <String>{};
      final created = habitCreatedDay[habit.id]!;
      var completedInRange = 0;
      var eligibleInRange = 0;

      var cursor = startDay;
      while (!cursor.isAfter(endDay)) {
        final key = DaySettings.dayKey(cursor);
        final done = completedKeys.contains(key);
        if (done) completedInRange += 1;
        if (!created.isAfter(cursor) || done) {
          eligibleInRange += 1;
        }
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      }

      final consistency = eligibleInRange > 0
          ? (completedInRange / eligibleInRange * 100).round().clamp(0, 100)
          : 0;

      final stats = StreakCalculator.stats(
        habit: habit,
        entries: entries,
        asOf: now,
        settings: settings,
      );

      if (stats.best > bestHabitStreak) bestHabitStreak = stats.best;
      if (stats.current > 0) activeStreaksCount += 1;

      habitSummaries.add(HabitRangeSummary(
        habit: habit,
        completedDaysInRange: completedInRange,
        eligibleDaysInRange: eligibleInRange,
        consistencyPercent: consistency,
        currentStreak: stats.current,
        bestStreak: stats.best,
        completedDayKeys: Set<String>.unmodifiable(completedKeys),
      ));
    }

    final taskStats = FocusStreakCalculator.stats(
      focusList: focusList,
      asOf: now,
      settings: settings,
    );

    final taskSummary = TaskRangeSummary(
      currentStreak: taskStats.current,
      bestStreak: taskStats.best,
      clearedDaysInRange: currentPeriod.tasksClearedDays,
      trackedDaysInRange: currentPeriod.tasksTrackedDays,
      completionRatePercent: currentPeriod.taskCompletionRatePercent,
    );

    final strongestWeekday = _computeStrongestWeekday(
      activeDaysCount: currentPeriod.activeDaysCount,
      weekdayRatios: currentPeriod.weekdayRatios,
    );

    HabitRangeSummary? topHabit;
    for (final summary in habitSummaries) {
      if (summary.completedDaysInRange == 0) continue;
      if (topHabit == null ||
          summary.consistencyPercent > topHabit.consistencyPercent ||
          (summary.consistencyPercent == topHabit.consistencyPercent &&
              summary.completedDaysInRange > topHabit.completedDaysInRange)) {
        topHabit = summary;
      }
    }

    var goalsCompletedInRange = 0;
    for (final goal in goals) {
      if (!goal.isCompleted || goal.completedAt == null) continue;
      final completedLogicalDay = settings.logicalDay(goal.completedAt!);
      if (!completedLogicalDay.isBefore(startDay) &&
          !completedLogicalDay.isAfter(endDay)) {
        goalsCompletedInRange += 1;
      }
    }

    return ProgressSnapshot(
      range: range,
      startDay: startDay,
      endDay: endDay,
      daysByKey: currentPeriod.daysByKey,
      consistencyPercent: currentPeriod.consistencyPercent,
      deltaVsPreviousPercent: deltaVsPrevious,
      activeDaysCount: currentPeriod.activeDaysCount,
      unbrokenDaysCount: currentPeriod.unbrokenDaysCount,
      bestHabitStreak: bestHabitStreak,
      activeStreaksCount: activeStreaksCount,
      taskSummary: taskSummary,
      habitSummaries: habitSummaries,
      strongestWeekday: strongestWeekday,
      topHabit: topHabit,
      goalsCompletedInRange: goalsCompletedInRange,
    );
  }

  static _WindowEval _evaluateWindow({
    required DateTime startDay,
    required DateTime endDay,
    required List<Habit> activeHabits,
    required Map<String, DateTime> habitCreatedDay,
    required Map<String, Set<String>> habitsDoneByDay,
    required Map<String, DailyFocus> focusByDay,
  }) {
    final daysByKey = <String, ActivityDaySummary>{};
    final weekdayRatios = <int, List<double>>{};

    var sumAllRatio = 0.0;
    var eligibleDaysCount = 0;
    var activeDaysCount = 0;
    var unbrokenDaysCount = 0;
    var tasksClearedDays = 0;
    var tasksTrackedDays = 0;
    var sumTaskRatio = 0.0;

    var cursor = startDay;
    while (!cursor.isAfter(endDay)) {
      final key = DaySettings.dayKey(cursor);
      final doneSet = habitsDoneByDay[key] ?? const <String>{};

      var eligibleHabits = 0;
      var habitsDone = 0;
      for (final h in activeHabits) {
        final didComplete = doneSet.contains(h.id);
        final created = habitCreatedDay[h.id]!;
        if (!created.isAfter(cursor) || didComplete) {
          eligibleHabits += 1;
          if (didComplete) habitsDone += 1;
        }
      }

      final habitRatio =
          eligibleHabits > 0 ? (habitsDone / eligibleHabits).clamp(0.0, 1.0) : 0.0;

      final focus = focusByDay[key];
      final focusItems = focus?.itemsList ?? const [];
      final tasksTotal = focusItems.length;
      final tasksDone = focusItems.where((it) => it.done).length;
      final taskRatio =
          tasksTotal > 0 ? (tasksDone / tasksTotal).clamp(0.0, 1.0) : 0.0;

      if (tasksTotal > 0) {
        tasksTrackedDays += 1;
        sumTaskRatio += taskRatio;
        if (tasksDone >= tasksTotal) {
          tasksClearedDays += 1;
        }
      }

      final double allRatio;
      if (eligibleHabits > 0 && tasksTotal > 0) {
        allRatio = (habitRatio + taskRatio) / 2.0;
      } else if (eligibleHabits > 0) {
        allRatio = habitRatio;
      } else if (tasksTotal > 0) {
        allRatio = taskRatio;
      } else {
        allRatio = 0.0;
      }

      final hasAnyActivity = habitsDone > 0 || tasksDone > 0;
      if (hasAnyActivity) activeDaysCount += 1;

      final hasEligible = eligibleHabits > 0 || tasksTotal > 0;
      if (hasEligible) {
        eligibleDaysCount += 1;
        sumAllRatio += allRatio;
        weekdayRatios.putIfAbsent(cursor.weekday, () => <double>[]).add(allRatio);
      }

      final isUnbroken = hasEligible &&
          (eligibleHabits == 0 || habitsDone >= eligibleHabits) &&
          (tasksTotal == 0 || tasksDone >= tasksTotal);
      if (isUnbroken) unbrokenDaysCount += 1;

      final allLevel = isUnbroken
          ? 4
          : ratioToLevel(allRatio >= 1.0 ? 0.99 : allRatio);

      daysByKey[key] = ActivityDaySummary(
        day: cursor,
        dayKey: key,
        habitsDone: habitsDone,
        habitsTotal: eligibleHabits,
        tasksDone: tasksDone,
        tasksTotal: tasksTotal,
        allLevel: allLevel,
        habitsLevel: ratioToLevel(habitRatio),
        tasksLevel: ratioToLevel(taskRatio),
        isUnbroken: isUnbroken,
      );

      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    final consistencyPercent = eligibleDaysCount > 0
        ? (sumAllRatio / eligibleDaysCount * 100).round().clamp(0, 100)
        : 0;
    final taskCompletionRatePercent = tasksTrackedDays > 0
        ? (sumTaskRatio / tasksTrackedDays * 100).round().clamp(0, 100)
        : 0;

    return _WindowEval(
      daysByKey: daysByKey,
      consistencyPercent: consistencyPercent,
      eligibleDaysCount: eligibleDaysCount,
      activeDaysCount: activeDaysCount,
      unbrokenDaysCount: unbrokenDaysCount,
      tasksClearedDays: tasksClearedDays,
      tasksTrackedDays: tasksTrackedDays,
      taskCompletionRatePercent: taskCompletionRatePercent,
      weekdayRatios: weekdayRatios,
    );
  }

  static DayOfWeekInsight? _computeStrongestWeekday({
    required int activeDaysCount,
    required Map<int, List<double>> weekdayRatios,
  }) {
    if (activeDaysCount < 7 || weekdayRatios.isEmpty) return null;

    int? bestWeekday;
    double bestAvg = -1.0;

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final list = weekdayRatios[weekday];
      if (list == null || list.isEmpty) continue;
      final avg = list.reduce((a, b) => a + b) / list.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestWeekday = weekday;
      }
    }

    if (bestWeekday == null || bestAvg <= 0.0) return null;
    return DayOfWeekInsight(
      weekday: bestWeekday,
      weekdayName: _weekdayNames[bestWeekday] ?? '',
      averagePercent: (bestAvg * 100).round().clamp(0, 100),
    );
  }
}

class _WindowEval {
  final Map<String, ActivityDaySummary> daysByKey;
  final int consistencyPercent;
  final int eligibleDaysCount;
  final int activeDaysCount;
  final int unbrokenDaysCount;
  final int tasksClearedDays;
  final int tasksTrackedDays;
  final int taskCompletionRatePercent;
  final Map<int, List<double>> weekdayRatios;

  const _WindowEval({
    required this.daysByKey,
    required this.consistencyPercent,
    required this.eligibleDaysCount,
    required this.activeDaysCount,
    required this.unbrokenDaysCount,
    required this.tasksClearedDays,
    required this.tasksTrackedDays,
    required this.taskCompletionRatePercent,
    required this.weekdayRatios,
  });
}
