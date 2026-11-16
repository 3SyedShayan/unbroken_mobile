import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';

part '_focus_provider.dart';

class FocusRepo {
  static FocusRepo _instance = FocusRepo._();
  FocusRepo._();
  factory FocusRepo() => _instance;

  @visibleForTesting
  FocusRepo.test();

  static FocusRepo get ins => _instance;

  @visibleForTesting
  static set ins(FocusRepo repo) => _instance = repo;

  final _provider = _FocusProvider();

  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) =>
      _provider.observeFocus(uid, windowStartKey: windowStartKey);

  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) =>
      _provider.upsertFocus(uid, logicalDayKey, focusData);

  Future<void> deleteFocus(String uid, String logicalDayKey) =>
      _provider.deleteFocus(uid, logicalDayKey);
}

