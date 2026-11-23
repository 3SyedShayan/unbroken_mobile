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
      SyncStatusTracker.ins.reportSnapshot(
        isFromCache: snapshot.metadata.isFromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      );
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
      SyncStatusTracker.ins.reportSnapshot(
        isFromCache: snapshot.metadata.isFromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      );
      return snapshot.docs.map((doc) => _cleanDoc(doc.data())).toList();
    });
  }

  Future<void> upsertFolder(
    String uid,
    Map<String, dynamic> raw, {
    bool isUpdate = false,
  }) async {
    try {
      final folderId = raw['id'] as String;
      final docRef = _userGoalFolders(uid).doc(folderId);

      final payload = Map<String, dynamic>.from(raw);
      final rawName = (payload['name'] as String? ?? '').trim();
      payload['name'] = rawName.isEmpty
          ? 'Folder'
          : (rawName.length > 80 ? rawName.substring(0, 80) : rawName);
      final rawEmoji = payload['emoji'] as String? ?? '';
      payload['emoji'] =
          rawEmoji.length > 16 ? rawEmoji.substring(0, 16) : rawEmoji;
      payload['sortOrder'] =
          ((payload['sortOrder'] as num?)?.toInt() ?? 0).clamp(0, 10000);
      final rawPeriod = payload['periodKey'] as String?;
      if (rawPeriod != null && rawPeriod.length > 32) {
        payload['periodKey'] = rawPeriod.substring(0, 32);
      }
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (isUpdate) {
        payload.remove('id');
        payload.remove('createdAt');
        await runOptimisticWrite(
          () => docRef.update(payload),
          tag: 'GOALS',
        );
      } else {
        payload['id'] = folderId;
        if (payload['createdAt'] is String) {
          payload['createdAt'] = Timestamp.fromDate(
            DateTime.parse(payload['createdAt'] as String),
          );
        } else if (payload['createdAt'] == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
        }
        await runOptimisticWrite(
          () => docRef.set(payload, SetOptions(merge: false)),
          tag: 'GOALS',
        );
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteFolder(String uid, String folderId) async {
    try {
      final folderRef = _userGoalFolders(uid).doc(folderId);
      final goalsSnap = await _userGoals(uid)
          .where('folderId', isEqualTo: folderId)
          .get()
          .timeout(FirebaseConfig.queryTimeout);

      final refs = <DocumentReference<Map<String, dynamic>>>[
        folderRef,
        ...goalsSnap.docs.map((doc) => doc.reference),
      ];
      await commitChunkedDeletes(_firestore, refs, tag: 'GOALS');
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> upsertGoal(
    String uid,
    Map<String, dynamic> raw, {
    bool isUpdate = false,
  }) async {
    try {
      final goalId = raw['id'] as String;
      final docRef = _userGoals(uid).doc(goalId);

      final payload = Map<String, dynamic>.from(raw);
      final rawTitle = (payload['title'] as String? ?? '').trim();
      payload['title'] = rawTitle.isEmpty
          ? 'Goal'
          : (rawTitle.length > 200 ? rawTitle.substring(0, 200) : rawTitle);
      final rawNotes = payload['notes'] as String?;
      if (rawNotes != null && rawNotes.length > 1000) {
        payload['notes'] = rawNotes.substring(0, 1000);
      }
      payload['sortOrder'] =
          ((payload['sortOrder'] as num?)?.toInt() ?? 0).clamp(0, 10000);
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (payload['completedAt'] is String) {
        payload['completedAt'] =
            Timestamp.fromDate(DateTime.parse(payload['completedAt'] as String));
      }

      if (isUpdate) {
        payload.remove('id');
        payload.remove('createdAt');
        payload.remove('folderId');
        await runOptimisticWrite(
          () => docRef.update(payload),
          tag: 'GOALS',
        );
      } else {
        payload['id'] = goalId;
        if (payload['createdAt'] is String) {
          payload['createdAt'] = Timestamp.fromDate(
            DateTime.parse(payload['createdAt'] as String),
          );
        } else if (payload['createdAt'] == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
        }
        await runOptimisticWrite(
          () => docRef.set(payload, SetOptions(merge: false)),
          tag: 'GOALS',
        );
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    try {
      await runOptimisticWrite(
        () => _userGoals(uid).doc(goalId).delete(),
        tag: 'GOALS',
      );
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
