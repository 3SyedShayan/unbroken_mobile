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
      SyncStatusTracker.ins.reportSnapshot(
        isFromCache: snapshot.metadata.isFromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      );
      return snapshot.docs.map((doc) {
        final data = _cleanDoc(doc.data());
        if (!data.containsKey('logicalDayKey') || data['logicalDayKey'] == null) {
          data['logicalDayKey'] = doc.id;
        }
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchFocusRange(
    String uid, {
    required String startKey,
    required String endKeyExclusive,
    bool preferCache = false,
  }) async {
    try {
      final query = _userFocus(uid)
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

      return snapshot.docs.map((doc) {
        final data = _cleanDoc(doc.data());
        if (!data.containsKey('logicalDayKey') || data['logicalDayKey'] == null) {
          data['logicalDayKey'] = doc.id;
        }
        return data;
      }).toList();
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
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

      final rawSlots = payload['slots'];
      if (rawSlots is Map) {
        final sanitizedSlots = <String, dynamic>{};
        rawSlots.forEach((key, value) {
          if (value is Map) {
            final slotId = (value['id'] as String? ?? 's$key');
            final slotText = (value['text'] as String? ?? '');
            sanitizedSlots[key.toString()] = {
              'id': slotId.length > 64 ? slotId.substring(0, 64) : slotId,
              'text': slotText.length > 300 ? slotText.substring(0, 300) : slotText,
              'done': value['done'] as bool? ?? false,
            };
          }
        });
        payload['slots'] = sanitizedSlots;
      }

      await runOptimisticWrite(
        () => docRef.set(payload, SetOptions(merge: false)),
        tag: 'FOCUS',
      );
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> deleteFocus(String uid, String logicalDayKey) async {
    try {
      await runOptimisticWrite(
        () => _userFocus(uid).doc(logicalDayKey).delete(),
        tag: 'FOCUS',
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
    return copy;
  }
}

