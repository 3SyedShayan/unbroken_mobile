import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
abstract class Entry with _$Entry {
  const Entry._();

  const factory Entry({
    required String id,
    required String habitId,
    required String logicalDayKey,
    @Default('mobile') String source,
    @Default('ios') String platform,
    required DateTime timestamp,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'];
    DateTime timestamp;
    if (rawTimestamp is DateTime) {
      timestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      timestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is num) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp.toInt());
    } else if (rawTimestamp != null &&
        (rawTimestamp.runtimeType.toString() == 'Timestamp' ||
            rawTimestamp.runtimeType.toString() == '_Timestamp')) {
      timestamp = (rawTimestamp as dynamic).toDate() as DateTime;
    } else {
      timestamp = DateTime.now();
    }

    final sanitized = Map<String, dynamic>.from(json);
    sanitized['timestamp'] = timestamp.toIso8601String();
    return _$EntryFromJson(sanitized);
  }

  static String generateId(String habitId, String logicalDayKey) =>
      '${habitId}_$logicalDayKey';
}

