// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entry _$EntryFromJson(Map<String, dynamic> json) => _Entry(
  id: json['id'] as String,
  habitId: json['habitId'] as String,
  logicalDayKey: json['logicalDayKey'] as String,
  source: json['source'] as String? ?? 'mobile',
  platform: json['platform'] as String? ?? 'ios',
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$EntryToJson(_Entry instance) => <String, dynamic>{
  'id': instance.id,
  'habitId': instance.habitId,
  'logicalDayKey': instance.logicalDayKey,
  'source': instance.source,
  'platform': instance.platform,
  'timestamp': instance.timestamp.toIso8601String(),
};
