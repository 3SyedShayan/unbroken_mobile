import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_settings.freezed.dart';
part 'day_settings.g.dart';

@freezed
abstract class DaySettings with _$DaySettings {
  const DaySettings._();

  const factory DaySettings({
    @Default(3) int dayEndHour,
    @Default(4) int atRiskWindowHours,
    @Default(<String>[]) List<String> habitOrder,
    @Default(false) bool weekStartMonday,
    @Default(false) bool hasOnboarded,
    @Default(false) bool didCheckInOnce,
    @Default(true) bool sinkCompletedHabits,
    @Default(false) bool rolloverTasks,
    @Default(true) bool streakSounds,
    @Default(false) bool reminders,
    @Default(1) int schemaVersion,
    DateTime? updatedAt,
  }) = _DaySettings;

  factory DaySettings.fromJson(Map<String, dynamic> json) =>
      _$DaySettingsFromJson(json);

  /// Returns the start-of-day for the logical day containing [date].
  /// With [dayEndHour] == 3, 2026-11-14 01:30 belongs to logical day 2026-11-13.
  DateTime logicalDay(DateTime date) {
    final startOfCalendarDay = DateTime(date.year, date.month, date.day);
    final boundary =
        DateTime(date.year, date.month, date.day, dayEndHour, 0, 0);
    if (date.isBefore(boundary)) {
      return startOfCalendarDay.subtract(const Duration(days: 1));
    }
    return startOfCalendarDay;
  }

  /// The exact moment the given logical day ends.
  DateTime endOfLogicalDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final nextDay = start.add(const Duration(days: 1));
    return DateTime(nextDay.year, nextDay.month, nextDay.day, dayEndHour, 0, 0);
  }

  /// Canonical 'YYYY-MM-DD' day key for the logical day containing [date].
  String logicalDayKey(DateTime date) {
    return dayKey(logicalDay(date));
  }

  /// Formats a start-of-day DateTime as 'YYYY-MM-DD'.
  static String dayKey(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a 'YYYY-MM-DD' string to start of day DateTime.
  static DateTime? startOfDay(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }
}

