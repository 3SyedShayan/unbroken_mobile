import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_item.freezed.dart';
part 'focus_item.g.dart';

@freezed
abstract class FocusItem with _$FocusItem {
  const factory FocusItem({
    required String id,
    @Default('') String text,
    @Default(false) bool done,
  }) = _FocusItem;

  factory FocusItem.fromJson(Map<String, dynamic> json) =>
      _$FocusItemFromJson(json);
}

