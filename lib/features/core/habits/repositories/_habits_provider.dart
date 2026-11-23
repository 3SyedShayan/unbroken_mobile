part of 'habits_repo.dart';

class _HabitsProvider {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userHabits(String uid) =>
      _firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.habits);

  CollectionReference<Map<String, dynamic>> _userEntries(String uid) =>
      _firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries);

  Stream<List<Map<String, dynamic>>> observeHabits(String uid) {
    return _userHabits(uid).snapshots().map((snapshot) {
      SyncStatusTracker.ins.reportSnapshot(
        isFromCache: snapshot.metadata.isFromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      );
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) {
    Query<Map<String, dynamic>> query = _userEntries(uid);
    if (windowStartKey != null) {
      query = query.where('logicalDayKey', isGreaterThanOrEqualTo: windowStartKey);
    }
    return query.snapshots().map((snapshot) {
      SyncStatusTracker.ins.reportSnapshot(
        isFromCache: snapshot.metadata.isFromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      );
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchEntriesRange(
    String uid, {
    required String startKey,
    required String endKeyExclusive,
    bool preferCache = false,
  }) async {
    try {
      final query = _userEntries(uid)
          .where('logicalDayKey', isGreaterThanOrEqualTo: startKey)
          .where('logicalDayKey', isLessThan: endKeyExclusive);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (preferCache) {
        try {
          snapshot = await query.get(const GetOptions(source: Source.cache));
        } catch (_) {
          snapshot = await query
              .get(const GetOptions(source: Source.serverAndCache))
              .timeout(FirebaseConfig.queryTimeout);
        }
      } else {
        snapshot = await query
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(FirebaseConfig.queryTimeout);
      }
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> upsertHabit(
    String uid,
    Map<String, dynamic> raw, {
    bool isUpdate = false,
    List<String>? appendHabitOrder,
  }) async {
    try {
      final habitId = (raw['id'] as String).toLowerCase();
      final docRef = _userHabits(uid).doc(habitId);

      final payload = Map<String, dynamic>.from(raw);
      final rawName = (payload['name'] as String? ?? '').trim();
      payload['name'] = rawName.isEmpty
          ? 'Habit'
          : (rawName.length > 100 ? rawName.substring(0, 100) : rawName);
      final rawEmoji = payload['emoji'] as String? ?? '';
      payload['emoji'] =
          rawEmoji.length > 16 ? rawEmoji.substring(0, 16) : rawEmoji;
      payload['sortOrder'] =
          ((payload['sortOrder'] as num?)?.toInt() ?? 0).clamp(0, 10000);
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (payload['lastCompletedDayKey'] == null) {
        payload.remove('lastCompletedDayKey');
      }

      if (isUpdate) {
        payload.remove('id');
        payload.remove('createdAt');
        await runOptimisticWrite(
          () => docRef.update(payload),
          tag: 'HABITS',
        );
      } else {
        payload['id'] = habitId;
        if (payload['createdAt'] is String) {
          payload['createdAt'] = Timestamp.fromDate(
            DateTime.parse(payload['createdAt'] as String),
          );
        } else if (payload['createdAt'] == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
        }

        if (appendHabitOrder != null) {
          final batch = _firestore.batch();
          batch.set(docRef, payload, SetOptions(merge: false));
          final userRef = _firestore.collection(Collections.users).doc(uid);
          batch.update(userRef, {
            'habitOrder': appendHabitOrder.map((e) => e.toLowerCase()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          await runOptimisticWrite(() => batch.commit(), tag: 'HABITS');
        } else {
          await runOptimisticWrite(
            () => docRef.set(payload, SetOptions(merge: false)),
            tag: 'HABITS',
          );
        }
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> reorderHabits(
    String uid,
    List<String> habitOrder,
  ) async {
    try {
      final userRef = _firestore.collection(Collections.users).doc(uid);
      await runOptimisticWrite(
        () => userRef.update({
          'habitOrder': habitOrder.map((id) => id.toLowerCase()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        tag: 'HABITS',
      );
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    try {
      final id = habitId.toLowerCase();
      final habitRef = _userHabits(uid).doc(id);

      // Query entries belonging to this habit
      final entriesSnap = await _userEntries(uid)
          .where('habitId', isEqualTo: id)
          .get()
          .timeout(FirebaseConfig.queryTimeout);

      final refs = <DocumentReference<Map<String, dynamic>>>[
        habitRef,
        ...entriesSnap.docs.map((doc) => doc.reference),
      ];
      await commitChunkedDeletes(_firestore, refs, tag: 'HABITS');
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    try {
      final cleanHabitId = habitId.toLowerCase();
      final entryId = '${cleanHabitId}_$logicalDayKey';
      final entryRef = _userEntries(uid).doc(entryId);

      final String platform;
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          platform = 'ios';
          break;
        case TargetPlatform.macOS:
          platform = 'macos';
          break;
        case TargetPlatform.android:
          platform = 'android';
          break;
        default:
          platform = 'ios';
      }

      final payload = <String, dynamic>{
        'id': entryId,
        'habitId': cleanHabitId,
        'logicalDayKey': logicalDayKey,
        'source': 'mobile',
        'platform': platform,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (habitStatsUpdate != null && habitStatsUpdate.isNotEmpty) {
        final batch = _firestore.batch();
        batch.set(entryRef, payload, SetOptions(merge: false));
        final habitUpdates = Map<String, dynamic>.from(habitStatsUpdate)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        batch.update(_userHabits(uid).doc(cleanHabitId), habitUpdates);
        await runOptimisticWrite(() => batch.commit(), tag: 'HABITS');
      } else {
        await runOptimisticWrite(
          () => entryRef.set(payload, SetOptions(merge: false)),
          tag: 'HABITS',
        );
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    try {
      final cleanHabitId = habitId.toLowerCase();
      final entryId = '${cleanHabitId}_$logicalDayKey';
      final entryRef = _userEntries(uid).doc(entryId);

      if (habitStatsUpdate != null && habitStatsUpdate.isNotEmpty) {
        final batch = _firestore.batch();
        batch.delete(entryRef);
        final habitUpdates = Map<String, dynamic>.from(habitStatsUpdate)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        batch.update(_userHabits(uid).doc(cleanHabitId), habitUpdates);
        await runOptimisticWrite(() => batch.commit(), tag: 'HABITS');
      } else {
        await runOptimisticWrite(() => entryRef.delete(), tag: 'HABITS');
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Map<String, dynamic> _cleanDoc(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    copy.forEach((key, value) {
      if (value is Timestamp) {
        copy[key] = value.toDate().toIso8601String();
      }
    });
    if (copy.containsKey('timestamp') && copy['timestamp'] == null) {
      copy['timestamp'] = DateTime.now().toIso8601String();
    }
    if (copy.containsKey('createdAt') && copy['createdAt'] == null) {
      copy['createdAt'] = DateTime.now().toIso8601String();
    }
    return copy;
  }
}

