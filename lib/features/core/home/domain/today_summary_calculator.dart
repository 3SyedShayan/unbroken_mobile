import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/habits/domain/icon_state_resolver.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class TodaySummary {
  final int habitsCompleted;
  final int habitsTotal;
  final int tasksCompleted;
  final int tasksTotal;
  final double combinedRatio;
  final int combinedPercent;
  final bool isUnbroken;
  final bool isAtRisk;
  final String? atRiskCountdownLabel;
  final String greeting;

  const TodaySummary({
    required this.habitsCompleted,
    required this.habitsTotal,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.combinedRatio,
    required this.combinedPercent,
    required this.isUnbroken,
    required this.isAtRisk,
    required this.atRiskCountdownLabel,
    required this.greeting,
  });
}

abstract class TodaySummaryCalculator {
  static TodaySummary compute({
    required List<Habit> activeHabits,
    required List<Entry> entries,
    required List<FocusItem> todayTasks,
    required DateTime now,
    required DaySettings settings,
  }) {
    final today = settings.logicalDay(now);
    final todayKey = settings.logicalDayKey(now);

    final habitsTotal = activeHabits.length;
    final completedIds = entries
        .where((e) => e.logicalDayKey == todayKey)
        .map((e) => e.habitId)
        .toSet();
    final habitsCompleted =
        activeHabits.where((h) => completedIds.contains(h.id)).length;

    final validTasks =
        todayTasks.where((it) => it.text.trim().isNotEmpty).toList();
    final tasksTotal = validTasks.length;
    final tasksCompleted = validTasks.where((it) => it.done).length;

    final habitRatio =
        habitsTotal > 0 ? (habitsCompleted / habitsTotal).clamp(0.0, 1.0) : 0.0;
    final taskRatio =
        tasksTotal > 0 ? (tasksCompleted / tasksTotal).clamp(0.0, 1.0) : 0.0;

    final double combinedRatio;
    if (habitsTotal > 0 && tasksTotal > 0) {
      combinedRatio = (habitRatio + taskRatio) / 2.0;
    } else if (habitsTotal > 0) {
      combinedRatio = habitRatio;
    } else if (tasksTotal > 0) {
      combinedRatio = taskRatio;
    } else {
      combinedRatio = 0.0;
    }

    final hasAnything = habitsTotal > 0 || tasksTotal > 0;
    final isUnbroken = hasAnything &&
        (habitsTotal == 0 || habitsCompleted >= habitsTotal) &&
        (tasksTotal == 0 || tasksCompleted >= tasksTotal);

    final iconState = IconStateResolver.state(
      habits: activeHabits,
      entries: entries,
      asOf: now,
      settings: settings,
    );
    final isAtRisk = iconState == IconState.atRisk;

    String? countdownLabel;
    if (isAtRisk) {
      final remaining = settings.endOfLogicalDay(today).difference(now);
      final totalMinutes = remaining.inMinutes < 1 ? 1 : remaining.inMinutes;
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      if (hours > 0 && mins > 0) {
        countdownLabel = '${hours}h ${mins}m left to stay unbroken';
      } else if (hours > 0) {
        countdownLabel = '${hours}h left to stay unbroken';
      } else {
        countdownLabel = '${mins}m left to stay unbroken';
      }
    }

    final String greeting;
    if (!hasAnything) {
      greeting = 'Let\'s build momentum';
    } else if (isUnbroken) {
      greeting = 'You\'re unbroken today';
    } else if (isAtRisk) {
      greeting = 'Protect your streak';
    } else if (habitsCompleted == 0 && tasksCompleted == 0) {
      greeting = 'Let\'s get going';
    } else if (combinedRatio >= 0.7) {
      greeting = 'Almost unbroken';
    } else {
      greeting = 'Keep it rolling';
    }

    return TodaySummary(
      habitsCompleted: habitsCompleted,
      habitsTotal: habitsTotal,
      tasksCompleted: tasksCompleted,
      tasksTotal: tasksTotal,
      combinedRatio: combinedRatio,
      combinedPercent: (combinedRatio * 100).round().clamp(0, 100),
      isUnbroken: isUnbroken,
      isAtRisk: isAtRisk,
      atRiskCountdownLabel: countdownLabel,
      greeting: greeting,
    );
  }
}
