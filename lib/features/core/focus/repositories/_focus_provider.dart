part of 'focus_repo.dart';

class _FocusProvider {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userFocus(String uid) =>
      _firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.focus);

  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    Query<Map<String, dynamic>> query = _userFocus(uid);
    if (windowStartKey != null) {
      query = query.where('logicalDayKey', isGreaterThanOrEqualTo: windowStartKey);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = _cleanDoc(doc.data());
        if (!data.containsKey('logicalDayKey') || data['logicalDayKey'] == null) {
          data['logicalDayKey'] = doc.id;
        }
        return data;
      }).toList();
    });
  }

  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> raw,
  ) async {
    try {
      final docRef = _userFocus(uid).doc(logicalDayKey);
      final payload = Map<String, dynamic>.from(raw);
      payload['logicalDayKey'] = logicalDayKey;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteFocus(String uid, String logicalDayKey) async {
    try {
      await _userFocus(uid).doc(logicalDayKey).delete();
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

