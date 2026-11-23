import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';
import 'package:unbroken_mobile/services/firebase/collections.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/firebase/firestore_write_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';

part '_focus_provider.dart';

class FocusRepo {
  static FocusRepo _instance = FocusRepo._();
  final bool _isTest;

  FocusRepo._() : _isTest = false;
  factory FocusRepo() => _instance;

  @visibleForTesting
  FocusRepo.test() : _isTest = true;

  static FocusRepo get ins => _instance;

  @visibleForTesting
  static set ins(FocusRepo repo) => _instance = repo;

  final _provider = _FocusProvider();

  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) =>
      _provider.observeFocus(uid, windowStartKey: windowStartKey);

  Future<List<Map<String, dynamic>>> fetchFocusRange(
    String uid, {
    required String startKey,
    required String endKeyExclusive,
    bool preferCache = false,
  }) {
    if (_isTest) return Future.value(const []);
    return _provider.fetchFocusRange(
      uid,
      startKey: startKey,
      endKeyExclusive: endKeyExclusive,
      preferCache: preferCache,
    );
  }

  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) =>
      _provider.upsertFocus(uid, logicalDayKey, focusData);

  Future<void> deleteFocus(String uid, String logicalDayKey) =>
      _provider.deleteFocus(uid, logicalDayKey);
}

