// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalFolder _$GoalFolderFromJson(Map<String, dynamic> json) => _GoalFolder(
  id: json['id'] as String,
  name: json['name'] as String,
  cadence: $enumDecode(_$GoalCadenceEnumMap, json['cadence']),
  emoji: json['emoji'] as String? ?? '',
  colorHex: json['colorHex'] as String? ?? '#E07A5F',
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isArchived: json['isArchived'] as bool? ?? false,
  periodKey: json['periodKey'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GoalFolderToJson(_GoalFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cadence': _$GoalCadenceEnumMap[instance.cadence]!,
      'emoji': instance.emoji,
      'colorHex': instance.colorHex,
      'sortOrder': instance.sortOrder,
      'isArchived': instance.isArchived,
      'periodKey': instance.periodKey,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$GoalCadenceEnumMap = {
  GoalCadence.weekly: 'weekly',
  GoalCadence.monthly: 'monthly',
  GoalCadence.weekend: 'weekend',
  GoalCadence.custom: 'custom',
};
