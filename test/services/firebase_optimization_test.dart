import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/services/cache/cache_service.dart';
import 'package:unbroken_mobile/services/firebase/history_window_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';

class _TrackingHabitsRepo extends HabitsRepo {
  _TrackingHabitsRepo() : super.test();

  int observeHabitsCalls = 0;
  int observeEntriesCalls = 0;
  String? lastObservedWindowStartKey;
  final List<({String startKey, String endKeyExclusive, bool preferCache})>
      coldFetchRequests = [];
  final List<List<String>> reorderCalls = [];
  Map<String, dynamic>? lastCheckInStatsUpdate;
  Map<String, dynamic>? lastUndoStatsUpdate;
  List<Map<String, dynamic>> seededColdEntries = const [];

  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) {
    observeHabitsCalls++;
    return const Stream.empty();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) {
    observeEntriesCalls++;
    lastObservedWindowStartKey = windowStartKey;
    return const Stream.empty();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEntriesRange(
    String uid, {
    required String startKey,
    required String endKeyExclusive,
    bool preferCache = false,
  }) async {
    coldFetchRequests.add((
      startKey: startKey,
      endKeyExclusive: endKeyExclusive,
      preferCache: preferCache,
    ));
    return seededColdEntries
        .where((e) {
          final dayKey = e['logicalDayKey'] as String;
          return dayKey.compareTo(startKey) >= 0 &&
              dayKey.compareTo(endKeyExclusive) < 0;
        })
        .toList();
  }

  @override
  Future<void> reorderHabits(String uid, List<String> habitOrder) async {
    reorderCalls.add(List<String>.from(habitOrder));
  }

  @override
  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    lastCheckInStatsUpdate = habitStatsUpdate;
  }

  @override
  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    lastUndoStatsUpdate = habitStatsUpdate;
  }
}

class _TrackingFocusRepo extends FocusRepo {
  _TrackingFocusRepo() : super.test();

  int observeFocusCalls = 0;
  int upsertFocusCalls = 0;
  Map<String, dynamic>? lastUpsertedPayload;
  final StreamController<List<Map<String, dynamic>>> _ctrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    observeFocusCalls++;
    return _ctrl.stream;
  }

  void emitSnapshot(List<Map<String, dynamic>> docs) {
    _ctrl.add(docs);
  }

  @override
  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) async {
    upsertFocusCalls++;
    lastUpsertedPayload = Map<String, dynamic>.from(focusData);
  }

  @override
  Future<void> deleteFocus(String uid, String logicalDayKey) async {}

  void dispose() {
    _ctrl.close();
  }
}

class _TrackingSettingsRepo extends SettingsRepo {
  _TrackingSettingsRepo() : super.test();

  int observeCalls = 0;
  int updateRemoteCalls = 0;
  int updateLocalCalls = 0;
  final Map<String, dynamic> localStore = {};

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) {
    observeCalls++;
    return Stream.value({
      'dayEndHour': 3,
      'atRiskWindowHours': 4,
      'habitOrder': <String>[],
      'weekStartMonday': false,
      'hasOnboarded': true,
      'didCheckInOnce': true,
    });
  }

  @override
  Future<void> updateSettings(
    String uid,
    Map<String, dynamic> settingsData,
  ) async {
    updateRemoteCalls++;
  }

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {
    updateLocalCalls++;
    localStore.addAll(prefs);
  }

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async =>
      Map<String, dynamic>.from(localStore);

  @override
  Future<void> clearLocalPreferences() async => localStore.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SyncStatusTracker.ins.reset();
  });

  group('HistoryWindowHelper', () {
    test('anchors hot window to 1st of previous calendar month across boundaries', () {
      expect(
        HistoryWindowHelper.hotWindowStartDate(DateTime(2026, 1, 15)),
        DateTime(2025, 12, 1),
      );
      expect(
        HistoryWindowHelper.hotWindowStartDate(DateTime(2026, 3, 20)),
        DateTime(2026, 2, 1),
      );
      expect(
        HistoryWindowHelper.hotWindowStartKey(DateTime(2026, 11, 23)),
        '2026-10-01',
      );
      expect(HistoryWindowHelper.hotWindowCoveredDays(DateTime(2026, 11, 23)), 54);
    });

    test('computes contiguous non-overlapping cold months only outside hot window', () {
      final now = DateTime(2026, 11, 23);
      expect(
        HistoryWindowHelper.coldMonthsForWindow(
          now,
          HistoryWindowHelper.hotWindowCoveredDays(now),
        ),
        isEmpty,
      );

      final buckets = HistoryWindowHelper.coldMonthsForWindow(now, 195);
      expect(
        buckets.map((b) => b.monthKey).toList(),
        ['2026-05', '2026-06', '2026-07', '2026-08', '2026-09'],
      );
      expect(buckets.first.startKey, '2026-05-01');
      expect(buckets.first.endKeyExclusive, '2026-06-01');
      expect(buckets.last.endKeyExclusive, '2026-10-01');
    });
  });

  group('HabitsCubit Call Reduction & Materialized Streaks', () {
    test('onAppResumed in same month does not re-subscribe entries listener', () async {
      final repo = _TrackingHabitsRepo();
      final cubit = HabitsCubit(repo: repo);

      cubit.startObserving('u1');
      expect(repo.observeEntriesCalls, 1);
      expect(
        repo.lastObservedWindowStartKey,
        HistoryWindowHelper.hotWindowStartKey(DateTime.now()),
      );

      cubit.onAppResumed();
      cubit.onAppResumed();
      expect(repo.observeEntriesCalls, 1);

      await cubit.close();
    });

    test('ensureHistoryWindowDays fetches cold months cache-first without re-subscribing', () async {
      final now = DateTime.now();
      final coldBuckets = HistoryWindowHelper.coldMonthsForWindow(now, 195);
      final oldestBucket = coldBuckets.first;
      final sampleDayKey = oldestBucket.startKey;

      final repo1 = _TrackingHabitsRepo()
        ..seededColdEntries = [
          {
            'id': 'h1_$sampleDayKey',
            'habitId': 'h1',
            'logicalDayKey': sampleDayKey,
            'source': 'mobile',
            'platform': 'ios',
            'timestamp': DateTime.now().toIso8601String(),
          },
        ];

      final cubit1 = HabitsCubit(repo: repo1, cacheService: CacheService.ins);
      cubit1.startObserving('u1');
      cubit1.ensureHistoryWindowDays(195);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo1.observeEntriesCalls, 1);
      expect(repo1.coldFetchRequests.length, coldBuckets.length);
      expect(
        repo1.coldFetchRequests.every((r) => r.preferCache == false),
        isTrue,
      );
      expect(
        cubit1.state.entries.any((e) => e.logicalDayKey == sampleDayKey),
        isTrue,
      );
      await cubit1.close();

      // Second session within TTL must prefer local cache instead of hitting server
      final repo2 = _TrackingHabitsRepo();
      final cubit2 = HabitsCubit(repo: repo2, cacheService: CacheService.ins);
      cubit2.startObserving('u1');
      cubit2.ensureHistoryWindowDays(195);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo2.coldFetchRequests.length, coldBuckets.length);
      expect(
        repo2.coldFetchRequests.every((r) => r.preferCache == true),
        isTrue,
      );
      await cubit2.close();
    });

    test('reorderHabits performs a single habitOrder update call', () async {
      final repo = _TrackingHabitsRepo();
      final cubit = HabitsCubit(repo: repo);
      cubit.startObserving('u1');

      final habits = [
        Habit(id: 'h_b', name: 'B', createdAt: DateTime(2026, 1, 1)),
        Habit(id: 'h_a', name: 'A', createdAt: DateTime(2026, 1, 1)),
      ];

      await cubit.reorderHabits(habits);
      expect(repo.reorderCalls, [
        ['h_b', 'h_a'],
      ]);

      await cubit.close();
    });

    test('materialized habit streak counters preserve >95d streaks and update on check-in', () async {
      final repo = _TrackingHabitsRepo();
      final cubit = HabitsCubit(repo: repo);
      cubit.startObserving('u1');

      const settings = DaySettings(dayEndHour: 3, streakSounds: false);
      final now = DateTime(2026, 11, 23, 12, 0);
      final yesterdayKey = '2026-11-22';

      final habit = Habit(
        id: 'h_meditate',
        name: 'Meditate',
        currentStreak: 120,
        bestStreak: 120,
        totalCheckIns: 120,
        lastCompletedDayKey: yesterdayKey,
        createdAt: DateTime(2026, 1, 1),
      );

      // Seed yesterday's entry in state so streak is active
      cubit.emit(
        cubit.state.copyWith(
          habits: [habit],
          entries: [
            Entry(
              id: 'h_meditate_$yesterdayKey',
              habitId: 'h_meditate',
              logicalDayKey: yesterdayKey,
              timestamp: DateTime(2026, 11, 22, 12, 0),
            ),
          ],
        ),
      );

      final beforeStats = cubit.state.streakStats(
        habit: habit,
        asOf: now,
        settings: settings,
      );
      expect(beforeStats.current, 120);
      expect(beforeStats.best, 120);

      await cubit.checkInForDay(
        habit: habit,
        day: DateTime(2026, 11, 23),
        settings: settings,
        now: now,
      );

      expect(repo.lastCheckInStatsUpdate?['currentStreak'], 121);
      expect(repo.lastCheckInStatsUpdate?['bestStreak'], 121);
      expect(repo.lastCheckInStatsUpdate?['totalCheckIns'], 121);
      expect(repo.lastCheckInStatsUpdate?['lastCompletedDayKey'], '2026-11-23');

      await cubit.close();
    });

    test('Habit.generateId generates distinct bounded IDs for duplicate or emoji names', () {
      final t1 = DateTime(2026, 11, 23, 10, 0, 0, 0, 1);
      final t2 = DateTime(2026, 11, 23, 10, 0, 0, 0, 2);

      final id1 = Habit.generateId(name: '💧💧💧', createdAt: t1);
      final id2 = Habit.generateId(name: '💧💧💧', createdAt: t2);

      expect(id1, isNot(equals(id2)));
      expect(id1.length, lessThanOrEqualTo(64));
      expect(id2.length, lessThanOrEqualTo(64));
    });
  });

  group('FocusCubit Debounce, Resume & Rollover', () {
    test('debounces rapid updateSlotText edits into a single remote write', () async {
      final repo = _TrackingFocusRepo();
      final cubit = FocusCubit(
        repo: repo,
        textDebounceDuration: const Duration(milliseconds: 50),
      );
      cubit.startObserving('u1');
      const settings = DaySettings(dayEndHour: 3, streakSounds: false);
      final asOf = DateTime(2026, 11, 23, 12, 0);

      await cubit.addTask(text: 'Draft', asOf: asOf, settings: settings);
      expect(repo.upsertFocusCalls, 1);

      await cubit.updateSlotText(index: 0, text: 'D', asOf: asOf, settings: settings);
      await cubit.updateSlotText(index: 0, text: 'Dr', asOf: asOf, settings: settings);
      await cubit.updateSlotText(index: 0, text: 'Dra', asOf: asOf, settings: settings);
      await cubit.updateSlotText(index: 0, text: 'Draft final', asOf: asOf, settings: settings);

      // Optimistic state is immediate while remote write is still debounced
      expect(cubit.state.focusForDay('2026-11-23').itemsList.first.text, 'Draft final');
      expect(repo.upsertFocusCalls, 1);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(repo.upsertFocusCalls, 2);
      expect(
        (repo.lastUpsertedPayload?['slots'] as Map)['0']['text'],
        'Draft final',
      );

      await cubit.close();
      repo.dispose();
    });

    test('onAppResumed in same month does not re-subscribe focus stream', () async {
      final repo = _TrackingFocusRepo();
      final cubit = FocusCubit(repo: repo);
      cubit.startObserving('u1');
      expect(repo.observeFocusCalls, 1);

      cubit.onAppResumed();
      expect(repo.observeFocusCalls, 1);

      await cubit.close();
      repo.dispose();
    });

    test('applyRolloverIfEnabled waits for initial snapshot before rolling over unfinished tasks', () async {
      final repo = _TrackingFocusRepo();
      final cubit = FocusCubit(repo: repo);
      cubit.startObserving('u1');

      const settings = DaySettings(
        dayEndHour: 3,
        rolloverTasks: true,
        streakSounds: false,
      );
      final now = DateTime(2026, 11, 23, 12, 0);

      // Called before initial snapshot arrives -> queued, 0 writes
      await cubit.applyRolloverIfEnabled(asOf: now, settings: settings);
      expect(repo.upsertFocusCalls, 0);

      // Emit snapshot containing yesterday's unfinished task
      repo.emitSnapshot([
        {
          'logicalDayKey': '2026-11-22',
          'slots': {
            '0': const FocusItem(id: 's0', text: 'Carry over me', done: false).toJson(),
            '1': const FocusItem(id: 's1', text: 'Already done', done: true).toJson(),
          },
        },
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.upsertFocusCalls, 1);
      final rolled = cubit.state.focusForDay('2026-11-23').itemsList;
      expect(rolled.length, 1);
      expect(rolled.first.text, 'Carry over me');
      expect(rolled.first.done, isFalse);

      await cubit.close();
      repo.dispose();
    });
  });

  group('SettingsCubit Zero Wasted Firestore Writes', () {
    test('local-only toggles do not trigger remote Firestore writes', () async {
      final repo = _TrackingSettingsRepo();
      final cubit = SettingsCubit(repo: repo);

      await cubit.startObserving('u1');
      expect(repo.observeCalls, 1);
      expect(repo.updateRemoteCalls, 0);

      await cubit.setProgressRange('6m');
      await cubit.toggleSinkCompletedHabits(false);
      await cubit.toggleRolloverTasks(true);
      await cubit.toggleStreakSounds(false);
      await cubit.toggleMorningReminder(true);
      await cubit.setMorningReminderTime('08:15');
      await cubit.toggleNightReminder(true);
      await cubit.setNightReminderTime('22:00');

      expect(repo.updateRemoteCalls, 0);
      expect(repo.localStore['progressRange'], '6m');
      expect(repo.localStore['rolloverTasks'], isTrue);

      await cubit.setDayEndHour(2);
      expect(repo.updateRemoteCalls, 1);

      await cubit.close();
    });
  });

  group('SyncStatusTracker', () {
    test('tracks snapshot metadata and resets cleanly', () {
      final tracker = SyncStatusTracker.ins;
      expect(tracker.current, FirestoreSyncStatus.connecting);

      tracker.reportSnapshot(isFromCache: true, hasPendingWrites: false);
      expect(tracker.current, FirestoreSyncStatus.offline);

      tracker.reportSnapshot(isFromCache: false, hasPendingWrites: true);
      expect(tracker.current, FirestoreSyncStatus.connecting);

      tracker.reportSnapshot(isFromCache: false, hasPendingWrites: false);
      expect(tracker.current, FirestoreSyncStatus.synced);

      tracker.reportError();
      expect(tracker.current, FirestoreSyncStatus.offline);

      tracker.reset();
      expect(tracker.current, FirestoreSyncStatus.connecting);
    });
  });
}
