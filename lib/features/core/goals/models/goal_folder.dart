import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';

part 'goal_folder.freezed.dart';
part 'goal_folder.g.dart';

@freezed
abstract class GoalFolder with _$GoalFolder {
  const GoalFolder._();

  const factory GoalFolder({
    required String id,
    required String name,
    required GoalCadence cadence,
    @Default('') String emoji,
    @Default('#E07A5F') String colorHex,
    @Default(0) int sortOrder,
    @Default(false) bool isArchived,
    String? periodKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GoalFolder;

  factory GoalFolder.fromJson(Map<String, dynamic> json) =>
      _$GoalFolderFromJson(json);
}
