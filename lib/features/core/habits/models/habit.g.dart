// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Habit _$HabitFromJson(Map<String, dynamic> json) => _Habit(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String? ?? '',
  colorHex: json['colorHex'] as String? ?? HabitPalette.defaultColor,
  frequency: json['frequency'] as String? ?? 'daily',
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isArchived: json['isArchived'] as bool? ?? false,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
  totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
  lastCompletedDayKey: json['lastCompletedDayKey'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$HabitToJson(_Habit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'colorHex': instance.colorHex,
  'frequency': instance.frequency,
  'sortOrder': instance.sortOrder,
  'isArchived': instance.isArchived,
  'currentStreak': instance.currentStreak,
  'bestStreak': instance.bestStreak,
  'totalCheckIns': instance.totalCheckIns,
  'lastCompletedDayKey': instance.lastCompletedDayKey,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
