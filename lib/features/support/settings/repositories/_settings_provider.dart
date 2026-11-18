part of 'settings_repo.dart';

class _SettingsProvider {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(Collections.users).doc(uid);

  Stream<Map<String, dynamic>?> observeSettings(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return _cleanDoc(snapshot.data()!);
    });
  }

  Future<Map<String, dynamic>?> getSettings(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return _cleanDoc(snapshot.data()!);
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> raw) async {
    try {
      // In firestore.rules, users doc permits ONLY these 8 fields:
      const allowedKeys = {
        'dayEndHour',
        'atRiskWindowHours',
        'habitOrder',
        'weekStartMonday',
        'hasOnboarded',
        'didCheckInOnce',
        'schemaVersion',
        'updatedAt',
      };

      final payload = <String, dynamic>{};
      for (final entry in raw.entries) {
        if (allowedKeys.contains(entry.key)) {
          payload[entry.key] = entry.value;
        }
      }
      payload['schemaVersion'] = 1;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await _userDoc(uid).set(payload, SetOptions(merge: true));
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {
    try {
      final sp = await SharedPreferences.getInstance();
      if (prefs.containsKey('hasOnboarded')) {
        await sp.setBool('hasOnboarded', prefs['hasOnboarded'] as bool);
      }
      if (prefs.containsKey('didCheckInOnce')) {
        await sp.setBool('didCheckInOnce', prefs['didCheckInOnce'] as bool);
      }
      if (prefs.containsKey('sinkCompletedHabits')) {
        await sp.setBool(
          'sinkCompletedHabits',
          prefs['sinkCompletedHabits'] as bool,
        );
      }
      if (prefs.containsKey('rolloverTasks')) {
        await sp.setBool('rolloverTasks', prefs['rolloverTasks'] as bool);
      }
      if (prefs.containsKey('streakSounds')) {
        await sp.setBool('streakSounds', prefs['streakSounds'] as bool);
      }
      if (prefs.containsKey('reminders')) {
        await sp.setBool('reminders', prefs['reminders'] as bool);
      }
      if (prefs.containsKey('morningReminderEnabled')) {
        await sp.setBool(
          'morningReminderEnabled',
          prefs['morningReminderEnabled'] as bool,
        );
      }
      if (prefs.containsKey('morningReminderTime')) {
        await sp.setString(
          'morningReminderTime',
          prefs['morningReminderTime'] as String,
        );
      }
      if (prefs.containsKey('nightReminderEnabled')) {
        await sp.setBool(
          'nightReminderEnabled',
          prefs['nightReminderEnabled'] as bool,
        );
      }
      if (prefs.containsKey('nightReminderTime')) {
        await sp.setString(
          'nightReminderTime',
          prefs['nightReminderTime'] as String,
        );
      }
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<Map<String, dynamic>> loadLocalPreferences() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return {
        'hasOnboarded': sp.getBool('hasOnboarded') ?? false,
        'didCheckInOnce': sp.getBool('didCheckInOnce') ?? false,
        'sinkCompletedHabits': sp.getBool('sinkCompletedHabits') ?? true,
        'rolloverTasks': sp.getBool('rolloverTasks') ?? false,
        'streakSounds': sp.getBool('streakSounds') ?? true,
        'reminders': sp.getBool('reminders') ?? false,
        'morningReminderEnabled': sp.getBool('morningReminderEnabled') ?? false,
        'morningReminderTime': sp.getString('morningReminderTime') ?? '09:00',
        'nightReminderEnabled': sp.getBool('nightReminderEnabled') ?? false,
        'nightReminderTime': sp.getString('nightReminderTime') ?? '21:00',
      };
    } catch (e, s) {
      throw Fault.fromObjectAndStackTrace(e, s);
    }
  }

  Future<void> clearLocalPreferences() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('hasOnboarded');
      await sp.remove('didCheckInOnce');
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

