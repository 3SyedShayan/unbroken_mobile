import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';

part '_habits_provider.dart';

class HabitsRepo {
  static final HabitsRepo _instance = HabitsRepo._();
  HabitsRepo._();
  factory HabitsRepo() => _instance;
  static HabitsRepo get ins => _instance;

  final _provider = _HabitsProvider();

  Stream<List<Map<String, dynamic>>> observeHabits(String uid) =>
      _provider.observeHabits(uid);

  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) =>
      _provider.observeEntries(uid, windowStartKey: windowStartKey);

  Future<void> upsertHabit(String uid, Map<String, dynamic> habitData) =>
      _provider.upsertHabit(uid, habitData);

  Future<void> reorderHabits(String uid, List<Map<String, dynamic>> habits) =>
      _provider.reorderHabits(uid, habits);

  Future<void> deleteHabit(String uid, String habitId) =>
      _provider.deleteHabit(uid, habitId);

  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
  }) =>
      _provider.recordCheckIn(
        uid,
        habitId: habitId,
        logicalDayKey: logicalDayKey,
      );

  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
  }) =>
      _provider.removeCheckIn(
        uid,
        habitId: habitId,
        logicalDayKey: logicalDayKey,
      );
}

