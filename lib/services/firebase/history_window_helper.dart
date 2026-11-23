import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

/// Represents an immutable past calendar month bucket `[startKey, endKeyExclusive)`.
class HistoryMonthBucket {
  final String monthKey;
  final String startKey;
  final String endKeyExclusive;

  const HistoryMonthBucket({
    required this.monthKey,
    required this.startKey,
    required this.endKeyExclusive,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryMonthBucket &&
        other.monthKey == monthKey &&
        other.startKey == startKey &&
        other.endKeyExclusive == endKeyExclusive;
  }

  @override
  int get hashCode => Object.hash(monthKey, startKey, endKeyExclusive);

  @override
  String toString() =>
      'HistoryMonthBucket($monthKey: $startKey..<$endKeyExclusive)';
}

/// Pure calendar math for month-anchored hot Firestore listeners and
/// cache-first cold monthly history ranges.
///
/// Anchoring the hot stream to the 1st of the previous calendar month keeps
/// the query predicate identical for an entire month so Firestore's persistent
/// cache and resume tokens avoid re-reading unchanged documents on daily opens.
abstract final class HistoryWindowHelper {
  const HistoryWindowHelper._();

  /// First day of the previous calendar month relative to [now].
  static DateTime hotWindowStartDate(DateTime now) =>
      DateTime(now.year, now.month - 1, 1);

  /// Canonical `YYYY-MM-DD` start key for the anchored hot listener window.
  static String hotWindowStartKey(DateTime now) =>
      DaySettings.dayKey(hotWindowStartDate(now));

  /// Number of inclusive calendar days from [hotWindowStartDate] through [now].
  static int hotWindowCoveredDays(DateTime now) {
    final start = hotWindowStartDate(now);
    return DateTime.utc(now.year, now.month, now.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
  }

  /// Extracts the `YYYY-MM` month key from a canonical `YYYY-MM-DD` day key.
  static String monthKeyForDayKey(String logicalDayKey) {
    if (logicalDayKey.length >= 7) {
      return logicalDayKey.substring(0, 7);
    }
    return logicalDayKey;
  }

  /// Returns non-overlapping past calendar months strictly before
  /// [hotWindowStartDate] needed to cover [requiredDays] ending at [now].
  static List<HistoryMonthBucket> coldMonthsForWindow(
    DateTime now,
    int requiredDays,
  ) {
    if (requiredDays <= 0) return const [];

    final hotStart = hotWindowStartDate(now);
    final earliestNeeded =
        DateTime(now.year, now.month, now.day - (requiredDays - 1));
    if (!earliestNeeded.isBefore(hotStart)) {
      return const [];
    }

    final buckets = <HistoryMonthBucket>[];
    var cursor = DateTime(earliestNeeded.year, earliestNeeded.month, 1);
    while (cursor.isBefore(hotStart)) {
      final next = DateTime(cursor.year, cursor.month + 1, 1);
      final y = cursor.year.toString().padLeft(4, '0');
      final m = cursor.month.toString().padLeft(2, '0');
      buckets.add(
        HistoryMonthBucket(
          monthKey: '$y-$m',
          startKey: DaySettings.dayKey(cursor),
          endKeyExclusive: DaySettings.dayKey(next),
        ),
      );
      cursor = next;
    }
    return buckets;
  }
}
