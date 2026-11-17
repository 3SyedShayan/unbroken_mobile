import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';

part 'daily_focus.freezed.dart';
part 'daily_focus.g.dart';

@freezed
abstract class DailyFocus with _$DailyFocus {
  const DailyFocus._();

  const factory DailyFocus({
    required String logicalDayKey,
    @Default(<String, FocusItem>{}) Map<String, FocusItem> slots,
    DateTime? updatedAt,
  }) = _DailyFocus;

  factory DailyFocus.fromJson(Map<String, dynamic> json) =>
      _$DailyFocusFromJson(json);

  List<FocusItem> get itemsList {
    final sortedKeys = slots.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    final list = <FocusItem>[];
    for (final key in sortedKeys) {
      final item = slots[key];
      if (item != null && item.text.trim().isNotEmpty) {
        list.add(item);
      }
    }
    return list;
  }

  bool get isCleared {
    return itemsList.isNotEmpty && itemsList.every((item) => item.done);
  }
}

