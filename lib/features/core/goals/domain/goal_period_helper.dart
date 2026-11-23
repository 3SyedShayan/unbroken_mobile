import 'package:intl/intl.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

enum GoalDateUrgency { normal, dueSoon, overdue }

class GoalDateBadge {
  final String label;
  final GoalDateUrgency urgency;

  const GoalDateBadge({required this.label, required this.urgency});
}

abstract class GoalPeriodHelper {
  /// Generates a Firestore-safe folder ID (always <= 48 chars, well under 64).
  static String generateFolderId({required String name, DateTime? now}) {
    final date = now ?? DateTime.now();
    final lower = name.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(ch)) {
        buffer.write(ch);
      } else if (ch == ' ' || ch == '-' || ch == '_') {
        buffer.write('-');
      }
    }
    final cleaned = buffer
        .toString()
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final slug = cleaned.isEmpty
        ? 'folder'
        : (cleaned.length > 24 ? cleaned.substring(0, 24) : cleaned);
    return 'gf_${date.microsecondsSinceEpoch}_$slug';
  }

  static String? periodKeyFor(GoalCadence cadence, DateTime now) {
    switch (cadence) {
      case GoalCadence.weekly:
        final (isoYear, isoWeek) = _isoWeek(now);
        return '$isoYear-W${isoWeek.toString().padLeft(2, '0')}';
      case GoalCadence.monthly:
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        return '$y-$m';
      case GoalCadence.weekend:
        final (isoYear, isoWeek) = _isoWeek(now);
        return '$isoYear-W${isoWeek.toString().padLeft(2, '0')}-WE';
      case GoalCadence.custom:
        return null;
    }
  }

  static String? cadenceCountdownLabel(
    GoalCadence cadence,
    DateTime today, {
    bool weekStartsMonday = false,
  }) {
    final d = DateTime(today.year, today.month, today.day);
    switch (cadence) {
      case GoalCadence.weekly:
        final firstWeekday = weekStartsMonday ? DateTime.monday : DateTime.sunday;
        final dayIndex = (d.weekday - firstWeekday + 7) % 7;
        final remaining = 7 - dayIndex;
        return remaining == 1 ? 'Last day of week' : '${remaining}d left this week';
      case GoalCadence.monthly:
        final daysInMonth = DateTime(d.year, d.month + 1, 0).day;
        final remaining = daysInMonth - d.day + 1;
        final monthShort = DateFormat('MMM').format(d);
        return remaining == 1
            ? 'Last day of $monthShort'
            : '${remaining}d left in $monthShort';
      case GoalCadence.weekend:
        if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
          return 'This weekend';
        }
        final satOffset = DateTime.saturday - d.weekday;
        return 'Weekend in ${satOffset}d';
      case GoalCadence.custom:
        return null;
    }
  }

  static GoalDateBadge? targetDateBadge(String? targetDateKey, DateTime today) {
    if (targetDateKey == null || targetDateKey.trim().isEmpty) return null;
    final target = DaySettings.startOfDay(targetDateKey);
    if (target == null) return null;

    final utcTarget = DateTime.utc(target.year, target.month, target.day);
    final utcToday = DateTime.utc(today.year, today.month, today.day);
    final diff = utcTarget.difference(utcToday).inDays;

    if (diff < 0) {
      return GoalDateBadge(
        label: diff == -1 ? 'Overdue 1d' : 'Overdue ${-diff}d',
        urgency: GoalDateUrgency.overdue,
      );
    }
    if (diff == 0) {
      return const GoalDateBadge(
        label: 'Due today',
        urgency: GoalDateUrgency.dueSoon,
      );
    }
    if (diff == 1) {
      return const GoalDateBadge(
        label: 'Tomorrow',
        urgency: GoalDateUrgency.dueSoon,
      );
    }
    if (diff <= 7) {
      return GoalDateBadge(
        label: 'In ${diff}d',
        urgency: GoalDateUrgency.normal,
      );
    }
    return GoalDateBadge(
      label: DateFormat('MMM d').format(target),
      urgency: GoalDateUrgency.normal,
    );
  }

  static (int isoYear, int isoWeek) _isoWeek(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    final thursday =
        utcDate.add(Duration(days: DateTime.thursday - utcDate.weekday));
    final jan1 = DateTime.utc(thursday.year, 1, 1);
    final dayOfYear = thursday.difference(jan1).inDays;
    final week = (dayOfYear ~/ 7) + 1;
    return (thursday.year, week);
  }
}
