import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_range.dart';

enum ActivityFilter {
  all('All'),
  habits('Habits'),
  tasks('Tasks');

  final String label;
  const ActivityFilter(this.label);
}

class ActivityDaySummary {
  final DateTime day;
  final String dayKey;
  final int habitsDone;
  final int habitsTotal;
  final int tasksDone;
  final int tasksTotal;
  final int allLevel;
  final int habitsLevel;
  final int tasksLevel;
  final bool isUnbroken;

  const ActivityDaySummary({
    required this.day,
    required this.dayKey,
    required this.habitsDone,
    required this.habitsTotal,
    required this.tasksDone,
    required this.tasksTotal,
    required this.allLevel,
    required this.habitsLevel,
    required this.tasksLevel,
    required this.isUnbroken,
  });

  int levelFor(ActivityFilter filter) {
    switch (filter) {
      case ActivityFilter.all:
        return allLevel;
      case ActivityFilter.habits:
        return habitsLevel;
      case ActivityFilter.tasks:
        return tasksLevel;
    }
  }
}

class HabitRangeSummary {
  final Habit habit;
  final int completedDaysInRange;
  final int eligibleDaysInRange;
  final int consistencyPercent;
  final int currentStreak;
  final int bestStreak;
  final Set<String> completedDayKeys;

  const HabitRangeSummary({
    required this.habit,
    required this.completedDaysInRange,
    required this.eligibleDaysInRange,
    required this.consistencyPercent,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedDayKeys,
  });
}

class TaskRangeSummary {
  final int currentStreak;
  final int bestStreak;
  final int clearedDaysInRange;
  final int trackedDaysInRange;
  final int completionRatePercent;

  const TaskRangeSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.clearedDaysInRange,
    required this.trackedDaysInRange,
    required this.completionRatePercent,
  });
}

class DayOfWeekInsight {
  final int weekday;
  final String weekdayName;
  final int averagePercent;

  const DayOfWeekInsight({
    required this.weekday,
    required this.weekdayName,
    required this.averagePercent,
  });
}

class ProgressSnapshot {
  final ProgressRange range;
  final DateTime startDay;
  final DateTime endDay;
  final Map<String, ActivityDaySummary> daysByKey;
  final int consistencyPercent;
  final int? deltaVsPreviousPercent;
  final int activeDaysCount;
  final int unbrokenDaysCount;
  final int bestHabitStreak;
  final int activeStreaksCount;
  final TaskRangeSummary taskSummary;
  final List<HabitRangeSummary> habitSummaries;
  final DayOfWeekInsight? strongestWeekday;
  final HabitRangeSummary? topHabit;
  final int goalsCompletedInRange;

  const ProgressSnapshot({
    required this.range,
    required this.startDay,
    required this.endDay,
    required this.daysByKey,
    required this.consistencyPercent,
    required this.deltaVsPreviousPercent,
    required this.activeDaysCount,
    required this.unbrokenDaysCount,
    required this.bestHabitStreak,
    required this.activeStreaksCount,
    required this.taskSummary,
    required this.habitSummaries,
    required this.strongestWeekday,
    required this.topHabit,
    required this.goalsCompletedInRange,
  });
}
