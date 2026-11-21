import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';

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

  Future<void> upsertFolder(String uid, Map<String, dynamic> folderData) =>
      _provider.upsertFolder(uid, folderData);

  Future<void> deleteFolder(String uid, String folderId) =>
      _provider.deleteFolder(uid, folderId);

  Future<void> upsertGoal(String uid, Map<String, dynamic> goalData) =>
      _provider.upsertGoal(uid, goalData);

  Future<void> deleteGoal(String uid, String goalId) =>
      _provider.deleteGoal(uid, goalId);
}
