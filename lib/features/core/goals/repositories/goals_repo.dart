import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/firebase/firestore_write_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';

part '_goals_provider.dart';

class GoalsRepo {
  static GoalsRepo _instance = GoalsRepo._();
  GoalsRepo._();
  factory GoalsRepo() => _instance;

  @visibleForTesting
  GoalsRepo.test();

  static GoalsRepo get ins => _instance;

  @visibleForTesting
  static set ins(GoalsRepo repo) => _instance = repo;

  final _provider = _GoalsProvider();

  Stream<List<Map<String, dynamic>>> observeFolders(String uid) =>
      _provider.observeFolders(uid);

  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) =>
      _provider.observeGoals(uid, folderId: folderId);

  Future<void> upsertFolder(
    String uid,
    Map<String, dynamic> folderData, {
    bool isUpdate = false,
  }) =>
      _provider.upsertFolder(uid, folderData, isUpdate: isUpdate);

  Future<void> deleteFolder(String uid, String folderId) =>
      _provider.deleteFolder(uid, folderId);

  Future<void> upsertGoal(
    String uid,
    Map<String, dynamic> goalData, {
    bool isUpdate = false,
  }) =>
      _provider.upsertGoal(uid, goalData, isUpdate: isUpdate);

  Future<void> deleteGoal(String uid, String goalId) =>
      _provider.deleteGoal(uid, goalId);
}
