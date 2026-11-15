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
    final list = <FocusItem>[];
    for (var i = 0; i < 3; i++) {
      final key = i.toString();
      if (slots.containsKey(key)) {
        list.add(slots[key]!);
      } else {
        list.add(FocusItem(id: 's$i', text: '', done: false));
      }
    }
    return list;
  }

  bool get isCleared {
    final written =
        itemsList.where((item) => item.text.trim().isNotEmpty).toList();
    return written.isNotEmpty && written.every((item) => item.done);
  }
}

