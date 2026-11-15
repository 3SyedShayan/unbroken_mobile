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

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  static String generateId(String habitId, String logicalDayKey) =>
      '${habitId}_$logicalDayKey';
}

