import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unbroken_mobile/configs/configs.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
abstract class Habit with _$Habit {
  const Habit._();

  const factory Habit({
    required String id,
    required String name,
    @Default('') String emoji,
    @Default(HabitPalette.defaultColor) String colorHex,
    @Default('daily') String frequency,
    @Default(0) int sortOrder,
    @Default(false) bool isArchived,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    @Default(0) int totalCheckIns,
    String? lastCompletedDayKey,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

  Color get color => HabitPalette.parse(colorHex);

  static String generateId({required String name, DateTime? createdAt}) {
    final date = createdAt ?? DateTime.now();
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final slug = slugify(name);
    return 'h_$y$m${d}_$slug';
  }

  static String slugify(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.runes) {
      final s = String.fromCharCode(char);
      if (RegExp(r'[a-z0-9]').hasMatch(s)) {
        buffer.write(s);
      } else if (s == ' ' || s == '-' || s == '_') {
        buffer.write('-');
      }
    }
    final cleaned = buffer.toString().replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    final trimmed = cleaned.length > 30 ? cleaned.substring(0, 30) : cleaned;
    return trimmed.isEmpty ? 'habit' : trimmed;
  }
}
