import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/firebase/firestore_write_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';

part '_habits_provider.dart';

class HabitsRepo {
  static HabitsRepo _instance = HabitsRepo._();
  final bool _isTest;

  HabitsRepo._() : _isTest = false;
  factory HabitsRepo() => _instance;

  @visibleForTesting
  HabitsRepo.test() : _isTest = true;

  static HabitsRepo get ins => _instance;

  @visibleForTesting
  static set ins(HabitsRepo repo) => _instance = repo;

  final _provider = _HabitsProvider();

  Stream<List<Map<String, dynamic>>> observeHabits(String uid) =>
      _provider.observeHabits(uid);

  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) =>
      _provider.observeEntries(uid, windowStartKey: windowStartKey);

  Future<List<Map<String, dynamic>>> fetchEntriesRange(
    String uid, {
    required String startKey,
    required String endKeyExclusive,
    bool preferCache = false,
  }) {
    if (_isTest) return Future.value(const []);
    return _provider.fetchEntriesRange(
      uid,
      startKey: startKey,
      endKeyExclusive: endKeyExclusive,
      preferCache: preferCache,
    );
  }

  Future<void> upsertHabit(
    String uid,
    Map<String, dynamic> habitData, {
    bool isUpdate = false,
    List<String>? appendHabitOrder,
  }) =>
      _provider.upsertHabit(
        uid,
        habitData,
        isUpdate: isUpdate,
        appendHabitOrder: appendHabitOrder,
      );

  Future<void> reorderHabits(
    String uid,
    List<String> habitOrder,
  ) =>
      _provider.reorderHabits(uid, habitOrder);

  Future<void> deleteHabit(String uid, String habitId) =>
      _provider.deleteHabit(uid, habitId);

  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) =>
      _provider.recordCheckIn(
        uid,
        habitId: habitId,
        logicalDayKey: logicalDayKey,
        habitStatsUpdate: habitStatsUpdate,
      );

  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) =>
      _provider.removeCheckIn(
        uid,
        habitId: habitId,
        logicalDayKey: logicalDayKey,
        habitStatsUpdate: habitStatsUpdate,
      );
}

