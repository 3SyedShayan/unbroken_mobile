import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_stats.freezed.dart';
part 'streak_stats.g.dart';

@freezed
abstract class StreakStats with _$StreakStats {
  const factory StreakStats({
    @Default(0) int current,
    @Default(0) int best,
    DateTime? lastCompletedDay,
  }) = _StreakStats;

  factory StreakStats.fromJson(Map<String, dynamic> json) =>
      _$StreakStatsFromJson(json);
}

