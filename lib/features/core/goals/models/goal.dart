import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
abstract class Goal with _$Goal {
  const Goal._();

  const factory Goal({
    required String id,
    required String folderId,
    required String title,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    String? notes,
    String? targetDateKey,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
