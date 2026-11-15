// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakStats _$StreakStatsFromJson(Map<String, dynamic> json) => _StreakStats(
  current: (json['current'] as num?)?.toInt() ?? 0,
  best: (json['best'] as num?)?.toInt() ?? 0,
  lastCompletedDay: json['lastCompletedDay'] == null
      ? null
      : DateTime.parse(json['lastCompletedDay'] as String),
);

Map<String, dynamic> _$StreakStatsToJson(_StreakStats instance) =>
    <String, dynamic>{
      'current': instance.current,
      'best': instance.best,
      'lastCompletedDay': instance.lastCompletedDay?.toIso8601String(),
    };
