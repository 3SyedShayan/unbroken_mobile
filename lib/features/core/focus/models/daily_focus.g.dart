// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_focus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyFocus _$DailyFocusFromJson(Map<String, dynamic> json) => _DailyFocus(
  logicalDayKey: json['logicalDayKey'] as String,
  slots:
      (json['slots'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FocusItem.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, FocusItem>{},
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DailyFocusToJson(_DailyFocus instance) =>
    <String, dynamic>{
      'logicalDayKey': instance.logicalDayKey,
      'slots': instance.slots,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
