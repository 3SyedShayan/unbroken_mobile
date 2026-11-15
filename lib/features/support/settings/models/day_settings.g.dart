// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaySettings _$DaySettingsFromJson(Map<String, dynamic> json) => _DaySettings(
  dayEndHour: (json['dayEndHour'] as num?)?.toInt() ?? 3,
  atRiskWindowHours: (json['atRiskWindowHours'] as num?)?.toInt() ?? 4,
  habitOrder:
      (json['habitOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weekStartMonday: json['weekStartMonday'] as bool? ?? false,
  hasOnboarded: json['hasOnboarded'] as bool? ?? false,
  didCheckInOnce: json['didCheckInOnce'] as bool? ?? false,
  sinkCompletedHabits: json['sinkCompletedHabits'] as bool? ?? true,
  rolloverTasks: json['rolloverTasks'] as bool? ?? false,
  streakSounds: json['streakSounds'] as bool? ?? true,
  reminders: json['reminders'] as bool? ?? false,
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DaySettingsToJson(_DaySettings instance) =>
    <String, dynamic>{
      'dayEndHour': instance.dayEndHour,
      'atRiskWindowHours': instance.atRiskWindowHours,
      'habitOrder': instance.habitOrder,
      'weekStartMonday': instance.weekStartMonday,
      'hasOnboarded': instance.hasOnboarded,
      'didCheckInOnce': instance.didCheckInOnce,
      'sinkCompletedHabits': instance.sinkCompletedHabits,
      'rolloverTasks': instance.rolloverTasks,
      'streakSounds': instance.streakSounds,
      'reminders': instance.reminders,
      'schemaVersion': instance.schemaVersion,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
