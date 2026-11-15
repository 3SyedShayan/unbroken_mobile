import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';

part 'daily_task_result.freezed.dart';
part 'daily_task_result.g.dart';

@freezed
abstract class DailyTaskResult with _$DailyTaskResult {
  const DailyTaskResult._();

  const factory DailyTaskResult({
    required String dayKey,
    required DateTime day,
    @Default(<FocusItem>[]) List<FocusItem> items,
  }) = _DailyTaskResult;

  factory DailyTaskResult.fromJson(Map<String, dynamic> json) =>
      _$DailyTaskResultFromJson(json);

  int get totalCount => items.where((it) => it.text.trim().isNotEmpty).length;

  int get completedCount =>
      items.where((it) => it.done && it.text.trim().isNotEmpty).length;

  double get completionRatio =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  bool get isCleared => totalCount > 0 && completedCount == totalCount;
}

