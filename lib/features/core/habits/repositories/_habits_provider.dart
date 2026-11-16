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
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Future<void> upsertHabit(String uid, Map<String, dynamic> raw) async {
    try {
      final habitId = (raw['id'] as String).toLowerCase();
      final docRef = _userHabits(uid).doc(habitId);

      final payload = Map<String, dynamic>.from(raw);
      payload['id'] = habitId;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (payload['createdAt'] is String) {
        payload['createdAt'] =
            Timestamp.fromDate(DateTime.parse(payload['createdAt'] as String));
      } else if (payload['createdAt'] == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> reorderHabits(
    String uid,
    List<Map<String, dynamic>> habits,
  ) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < habits.length; i++) {
        final habitId = (habits[i]['id'] as String).toLowerCase();
        final docRef = _userHabits(uid).doc(habitId);
        batch.update(docRef, {
          'sortOrder': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    try {
      final id = habitId.toLowerCase();
      final habitRef = _userHabits(uid).doc(id);

      // Query entries belonging to this habit
      final entriesSnap =
          await _userEntries(uid).where('habitId', isEqualTo: id).get();

      final batch = _firestore.batch();
      batch.delete(habitRef);
      for (final doc in entriesSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
  }) async {
    try {
      final cleanHabitId = habitId.toLowerCase();
      final entryId = '${cleanHabitId}_$logicalDayKey';
      final entryRef = _userEntries(uid).doc(entryId);

      final isIos = defaultTargetPlatform == TargetPlatform.iOS;
      final payload = <String, dynamic>{
        'id': entryId,
        'habitId': cleanHabitId,
        'logicalDayKey': logicalDayKey,
        'source': 'mobile',
        'platform': isIos ? 'ios' : 'android',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await entryRef.set(payload, SetOptions(merge: false));
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
  }) async {
    try {
      final cleanHabitId = habitId.toLowerCase();
      final entryId = '${cleanHabitId}_$logicalDayKey';
      await _userEntries(uid).doc(entryId).delete();
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
    return copy;
  }
}

