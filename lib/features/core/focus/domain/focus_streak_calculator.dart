import 'package:unbroken_mobile/features/core/focus/models/daily_focus.dart';
import 'package:unbroken_mobile/features/core/habits/domain/streak_calculator.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

abstract class FocusStreakCalculator {
  static StreakStats stats({
    required List<DailyFocus> focusList,
    required DateTime asOf,
    required DaySettings settings,
  }) {
    final completedDays = <DateTime>{};
    for (final focus in focusList) {
      if (focus.isCleared) {
        final parsed = DaySettings.startOfDay(focus.logicalDayKey);
        if (parsed != null) {
          completedDays.add(DateTime(parsed.year, parsed.month, parsed.day));
        }
      }
    }
    return StreakCalculator.calculateStreak(
      completedDays: completedDays,
      asOf: asOf,
      settings: settings,
    );
  }
}

