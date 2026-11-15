// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyTaskResult _$DailyTaskResultFromJson(Map<String, dynamic> json) =>
    _DailyTaskResult(
      dayKey: json['dayKey'] as String,
      day: DateTime.parse(json['day'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => FocusItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FocusItem>[],
    );

Map<String, dynamic> _$DailyTaskResultToJson(_DailyTaskResult instance) =>
    <String, dynamic>{
      'dayKey': instance.dayKey,
      'day': instance.day.toIso8601String(),
      'items': instance.items,
    };
