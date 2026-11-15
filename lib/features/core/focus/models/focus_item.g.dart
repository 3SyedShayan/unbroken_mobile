// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FocusItem _$FocusItemFromJson(Map<String, dynamic> json) => _FocusItem(
  id: json['id'] as String,
  text: json['text'] as String? ?? '',
  done: json['done'] as bool? ?? false,
);

Map<String, dynamic> _$FocusItemToJson(_FocusItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'done': instance.done,
    };
