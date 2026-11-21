part of 'goals_repo.dart';

class _GoalsProvider {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userGoalFolders(String uid) =>
      _firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.goalFolders);

  CollectionReference<Map<String, dynamic>> _userGoals(String uid) =>
      _firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.goals);

  Stream<List<Map<String, dynamic>>> observeFolders(String uid) {
    return _userGoalFolders(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) {
    Query<Map<String, dynamic>> query = _userGoals(uid);
    if (folderId != null) {
      query = query.where('folderId', isEqualTo: folderId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Future<void> upsertFolder(String uid, Map<String, dynamic> raw) async {
    try {
      final folderId = raw['id'] as String;
      final docRef = _userGoalFolders(uid).doc(folderId);

      final payload = Map<String, dynamic>.from(raw);
      payload['id'] = folderId;
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

  Future<void> deleteFolder(String uid, String folderId) async {
    try {
      final folderRef = _userGoalFolders(uid).doc(folderId);
      final goalsSnap =
          await _userGoals(uid).where('folderId', isEqualTo: folderId).get();

      final batch = _firestore.batch();
      batch.delete(folderRef);
      for (final doc in goalsSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> upsertGoal(String uid, Map<String, dynamic> raw) async {
    try {
      final goalId = raw['id'] as String;
      final docRef = _userGoals(uid).doc(goalId);

      final payload = Map<String, dynamic>.from(raw);
      payload['id'] = goalId;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (payload['createdAt'] is String) {
        payload['createdAt'] =
            Timestamp.fromDate(DateTime.parse(payload['createdAt'] as String));
      } else if (payload['createdAt'] == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      if (payload['completedAt'] is String) {
        payload['completedAt'] =
            Timestamp.fromDate(DateTime.parse(payload['completedAt'] as String));
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    try {
      await _userGoals(uid).doc(goalId).delete();
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
    if (copy.containsKey('createdAt') && copy['createdAt'] == null) {
      copy['createdAt'] = DateTime.now().toIso8601String();
    }
    return copy;
  }
}
