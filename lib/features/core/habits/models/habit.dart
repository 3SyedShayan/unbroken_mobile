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

  factory Habit.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    DateTime createdAt;
    if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is num) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt.toInt());
    } else if (rawCreatedAt != null &&
        (rawCreatedAt.runtimeType.toString() == 'Timestamp' ||
            rawCreatedAt.runtimeType.toString() == '_Timestamp')) {
      createdAt = (rawCreatedAt as dynamic).toDate() as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    final rawUpdatedAt = json['updatedAt'];
    DateTime? updatedAt;
    if (rawUpdatedAt is DateTime) {
      updatedAt = rawUpdatedAt;
    } else if (rawUpdatedAt is String) {
      updatedAt = DateTime.tryParse(rawUpdatedAt);
    } else if (rawUpdatedAt is num) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt.toInt());
    } else if (rawUpdatedAt != null &&
        (rawUpdatedAt.runtimeType.toString() == 'Timestamp' ||
            rawUpdatedAt.runtimeType.toString() == '_Timestamp')) {
      updatedAt = (rawUpdatedAt as dynamic).toDate() as DateTime;
    }

    final sanitized = Map<String, dynamic>.from(json);
    sanitized['createdAt'] = createdAt.toIso8601String();
    if (updatedAt != null) {
      sanitized['updatedAt'] = updatedAt.toIso8601String();
    }
    return _$HabitFromJson(sanitized);
  }

  Color get color => HabitPalette.parse(colorHex);

  static String generateId({required String name, DateTime? createdAt}) {
    final date = createdAt ?? DateTime.now();
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final rawSlug = slugify(name);
    final slug = rawSlug.length > 25 ? rawSlug.substring(0, 25) : rawSlug;
    final suffix = (date.microsecondsSinceEpoch % 1679616)
        .toRadixString(36)
        .padLeft(4, '0');
    return 'h_$y$m${d}_${slug}_$suffix';
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
