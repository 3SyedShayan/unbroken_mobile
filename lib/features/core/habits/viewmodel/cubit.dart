import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/habits/domain/streak_calculator.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/services/cache/cache_service.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/firebase/history_window_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  static HabitsCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<HabitsCubit>(context, listen: listen);

  final HabitsRepo _repo;
  final CacheService _cacheService;
  StreamSubscription<List<Map<String, dynamic>>>? _habitsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _entriesSub;
  String? _currentUid;
  String? _subscribedHotWindowKey;
  int _observedWindowDays = 0;

  List<Entry> _hotEntries = const [];
  final Map<String, List<Entry>> _coldEntriesByMonth = {};
  final Set<String> _loadedColdMonths = {};
  final Set<String> _inFlightColdMonths = {};

  int get observedWindowDays => _observedWindowDays;

  HabitsCubit({HabitsRepo? repo, CacheService? cacheService})
    : _repo = repo ?? HabitsRepo.ins,
      _cacheService = cacheService ?? CacheService.ins,
      super(
        HabitsState(fetch: BlocState<List<Habit>>(), action: BlocState<void>()),
      ) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
  }

  Future<void> _clearOnSignOut() async {
    await _habitsSub?.cancel();
    await _entriesSub?.cancel();
    _habitsSub = null;
    _entriesSub = null;
    _currentUid = null;
    _subscribedHotWindowKey = null;
    _observedWindowDays = 0;
    _hotEntries = const [];
    _coldEntriesByMonth.clear();
    _loadedColdMonths.clear();
    _inFlightColdMonths.clear();
    if (!isClosed) {
      emit(
        HabitsState(fetch: BlocState<List<Habit>>(), action: BlocState<void>()),
      );
    }
  }

  void ensureHistoryWindowDays(int days) {
    if (days > _observedWindowDays) {
      _observedWindowDays = days;
    }
    final uid = _currentUid;
    if (uid == null) return;

    final buckets = HistoryWindowHelper.coldMonthsForWindow(
      DateTime.now(),
      _observedWindowDays,
    );
    for (final bucket in buckets) {
      if (_loadedColdMonths.contains(bucket.monthKey) ||
          _inFlightColdMonths.contains(bucket.monthKey)) {
        continue;
      }
      unawaited(_loadColdMonth(uid, bucket));
    }
  }

  Future<void> _loadColdMonth(String uid, HistoryMonthBucket bucket) async {
    _inFlightColdMonths.add(bucket.monthKey);
    try {
      final syncKey = 'entries_month_${uid}_${bucket.monthKey}';
      final lastSync = await _cacheService.getLastSearchTime(syncKey);
      final preferCache =
          lastSync != null &&
          DateTime.now().difference(lastSync) <
              FirebaseConfig.coldMonthCacheTtl;

      final rawList = await _repo.fetchEntriesRange(
        uid,
        startKey: bucket.startKey,
        endKeyExclusive: bucket.endKeyExclusive,
        preferCache: preferCache,
      );

      final parsed = <Entry>[];
      for (final m in rawList) {
        try {
          parsed.add(Entry.fromJson(m));
        } catch (e, s) {
          final id = m['id'] ?? 'unknown';
          'Failed to parse cold entry ($id): $e'.appLog(
            tag: 'HABITS',
            level: AppLogLevel.error,
            error: e,
            stackTrace: s,
          );
        }
      }

      if (_currentUid != uid || isClosed) return;
      _coldEntriesByMonth[bucket.monthKey] = parsed;
      _loadedColdMonths.add(bucket.monthKey);
      if (!preferCache) {
        await _cacheService.setLastSearchTime(syncKey, DateTime.now());
      }
      _emitMergedEntries();
    } catch (e, s) {
      'Failed to load cold entries month (${bucket.monthKey}): $e'.appLog(
        tag: 'HABITS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    } finally {
      _inFlightColdMonths.remove(bucket.monthKey);
    }
  }

  List<Entry> _buildMergedEntries() {
    final hotKey = _subscribedHotWindowKey;
    final byId = <String, Entry>{};
    for (final list in _coldEntriesByMonth.values) {
      for (final entry in list) {
        if (hotKey == null || entry.logicalDayKey.compareTo(hotKey) < 0) {
          byId[entry.id] = entry;
        }
      }
    }
    for (final entry in _hotEntries) {
      byId[entry.id] = entry;
    }
    return byId.values.toList();
  }

  void _emitMergedEntries() {
    if (isClosed) return;
    emit(state.copyWith(entries: _buildMergedEntries()));
  }

  void _subscribeHotEntries(String uid) {
    final now = DateTime.now();
    final windowKey = HistoryWindowHelper.hotWindowStartKey(now);
    if (_entriesSub != null && _subscribedHotWindowKey == windowKey) return;

    _subscribedHotWindowKey = windowKey;
    final previousSub = _entriesSub;
    if (previousSub != null) {
      unawaited(previousSub.cancel());
    }

    _entriesSub = _repo
        .observeEntries(uid, windowStartKey: windowKey)
        .listen(
          (rawList) {
            final entries = <Entry>[];
            for (final m in rawList) {
              try {
                entries.add(Entry.fromJson(m));
              } catch (e, s) {
                final id = m['id'] ?? 'unknown';
                'Failed to parse entry ($id): $e'.appLog(
                  tag: 'HABITS',
                  level: AppLogLevel.error,
                  error: e,
                  stackTrace: s,
                );
              }
            }
            _hotEntries = entries;
            _emitMergedEntries();
          },
          onError: (Object e, StackTrace s) {
            'Error in observeEntries: $e'.appLog(
              tag: 'HABITS',
              level: AppLogLevel.error,
              error: e,
              stackTrace: s,
            );
            SyncStatusTracker.ins.reportError();
          },
        );
  }

  void onAppResumed() {
    final uid = _currentUid;
    if (uid == null) return;
    final now = DateTime.now();
    final nextHotKey = HistoryWindowHelper.hotWindowStartKey(now);
    if (nextHotKey != _subscribedHotWindowKey) {
      _subscribeHotEntries(uid);
      final hotDays = HistoryWindowHelper.hotWindowCoveredDays(now);
      if (_observedWindowDays > hotDays) {
        ensureHistoryWindowDays(_observedWindowDays);
      }
    }
  }

  void startObserving(String uid) {
    if (_currentUid == uid && _habitsSub != null) return;
    _currentUid = uid;
    unawaited(_habitsSub?.cancel());
    unawaited(_entriesSub?.cancel());
    _entriesSub = null;
    _subscribedHotWindowKey = null;
    _hotEntries = const [];
    _coldEntriesByMonth.clear();
    _loadedColdMonths.clear();
    _inFlightColdMonths.clear();

    final hotDays = HistoryWindowHelper.hotWindowCoveredDays(DateTime.now());
    if (_observedWindowDays < hotDays) {
      _observedWindowDays = hotDays;
    }

    _habitsSub = _repo
        .observeHabits(uid)
        .listen(
          (rawList) {
            final habits = <Habit>[];
            for (final m in rawList) {
              try {
                habits.add(Habit.fromJson(m));
              } catch (e, s) {
                final id = m['id'] ?? 'unknown';
                'Failed to parse habit ($id): $e'.appLog(
                  tag: 'HABITS',
                  level: AppLogLevel.error,
                  error: e,
                  stackTrace: s,
                );
              }
            }
            if (!isClosed) {
              emit(
                state.copyWith(
                  habits: habits,
                  fetch: state.fetch.toSuccess(data: habits),
                ),
              );
            }
          },
          onError: (Object e, StackTrace s) {
            'Error in observeHabits: $e'.appLog(
              tag: 'HABITS',
              level: AppLogLevel.error,
              error: e,
              stackTrace: s,
            );
            SyncStatusTracker.ins.reportError();
          },
        );

    _subscribeHotEntries(uid);
    if (_observedWindowDays > hotDays) {
      ensureHistoryWindowDays(_observedWindowDays);
    }
  }

  /// Toggles check-in for a wall-clock timestamp [asOf] by resolving its logical day.
  Future<void> toggleCheckIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) => toggleCheckInForDay(
    habit: habit,
    day: settings.logicalDay(asOf),
    settings: settings,
  );

  /// Records a check-in for a wall-clock timestamp [asOf] by resolving its logical day.
  Future<void> checkIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) => checkInForDay(
    habit: habit,
    day: settings.logicalDay(asOf),
    settings: settings,
  );

  /// Removes a check-in for a wall-clock timestamp [asOf] by resolving its logical day.
  Future<void> undoCheckIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) => undoCheckInForDay(
    habit: habit,
    day: settings.logicalDay(asOf),
    settings: settings,
  );

  /// Toggles check-in for an already-resolved logical calendar [day] (no `dayEndHour` shift).
  Future<void> toggleCheckInForDay({
    required Habit habit,
    required DateTime day,
    required DaySettings settings,
    DateTime? now,
  }) async {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final done = state.isCompletedForDay(habit: habit, day: normalizedDay);
    if (done) {
      await undoCheckInForDay(
        habit: habit,
        day: normalizedDay,
        settings: settings,
        now: now,
      );
    } else {
      await checkInForDay(
        habit: habit,
        day: normalizedDay,
        settings: settings,
        now: now,
      );
    }
  }

  /// Records a check-in for an already-resolved logical calendar [day] (no `dayEndHour` shift).
  Future<void> checkInForDay({
    required Habit habit,
    required DateTime day,
    required DaySettings settings,
    DateTime? now,
  }) async {
    if (_currentUid == null) return;

    final effectiveNow = now ?? DateTime.now();
    final today = settings.logicalDay(effectiveNow);
    final target = DateTime(day.year, day.month, day.day);
    if (target.isAfter(today)) return; // Future days rejected (matches macOS)

    final dayKey = DaySettings.dayKey(target);

    // Provide haptic feedback and click audio feedback
    if (settings.streakSounds) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
    }

    // Optimistic UI update
    final tempEntry = Entry(
      id: '${habit.id}_$dayKey',
      habitId: habit.id,
      logicalDayKey: dayKey,
      timestamp: effectiveNow,
    );
    _applyOptimisticEntryUpsert(tempEntry);
    final updatedEntries = _buildMergedEntries();

    final computed = StreakCalculator.stats(
      habit: habit,
      entries: updatedEntries,
      asOf: effectiveNow,
      settings: settings,
    );
    final loadedCount = updatedEntries
        .where((e) => e.habitId == habit.id)
        .length;
    final todayKey = DaySettings.dayKey(today);
    final yesterdayKey = DaySettings.dayKey(
      DateTime(today.year, today.month, today.day - 1),
    );

    final nextCurrent =
        (dayKey == todayKey &&
            habit.lastCompletedDayKey == yesterdayKey &&
            habit.currentStreak >= computed.current)
        ? habit.currentStreak + 1
        : computed.current;
    final nextBest = max(habit.bestStreak, max(computed.best, nextCurrent));
    final nextTotal = max(loadedCount, habit.totalCheckIns + 1);
    final nextLastDay =
        (habit.lastCompletedDayKey == null ||
            dayKey.compareTo(habit.lastCompletedDayKey!) > 0)
        ? dayKey
        : habit.lastCompletedDayKey;

    final updatedHabit = habit.copyWith(
      currentStreak: nextCurrent,
      bestStreak: nextBest,
      totalCheckIns: nextTotal,
      lastCompletedDayKey: nextLastDay,
    );
    final nextHabits = [
      for (final h in state.habits)
        if (h.id == habit.id) updatedHabit else h,
    ];
    emit(state.copyWith(habits: nextHabits, entries: updatedEntries));

    final statsUpdate = <String, dynamic>{
      'currentStreak': nextCurrent,
      'bestStreak': nextBest,
      'totalCheckIns': nextTotal,
      'lastCompletedDayKey': ?nextLastDay,
    };

    try {
      await _repo.recordCheckIn(
        _currentUid!,
        habitId: habit.id,
        logicalDayKey: dayKey,
        habitStatsUpdate: statsUpdate,
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          action: state.action.toFailed(
            fault: Fault.fromObjectAndStackTrace(e, s),
          ),
        ),
      );
    }
  }

  /// Removes a check-in for an already-resolved logical calendar [day] (no `dayEndHour` shift).
  Future<void> undoCheckInForDay({
    required Habit habit,
    required DateTime day,
    required DaySettings settings,
    DateTime? now,
  }) async {
    if (_currentUid == null) return;

    final effectiveNow = now ?? DateTime.now();
    final today = settings.logicalDay(effectiveNow);
    final target = DateTime(day.year, day.month, day.day);
    if (target.isAfter(today)) return; // Future days rejected (matches macOS)

    final dayKey = DaySettings.dayKey(target);

    if (settings.streakSounds) {
      HapticFeedback.lightImpact();
    }

    // Optimistic UI update
    _applyOptimisticEntryRemoval(habit.id, dayKey);
    final updatedEntries = _buildMergedEntries();

    final computed = StreakCalculator.stats(
      habit: habit,
      entries: updatedEntries,
      asOf: effectiveNow,
      settings: settings,
    );
    final loadedCount = updatedEntries
        .where((e) => e.habitId == habit.id)
        .length;
    final todayKey = DaySettings.dayKey(today);

    final nextCurrent =
        (dayKey == todayKey && habit.currentStreak > computed.current)
        ? max(0, habit.currentStreak - 1)
        : computed.current;
    final nextBest = max(habit.bestStreak, computed.best);
    final nextTotal = habit.totalCheckIns > loadedCount
        ? max(0, habit.totalCheckIns - 1)
        : loadedCount;
    final String? nextLastDay = computed.lastCompletedDay != null
        ? DaySettings.dayKey(computed.lastCompletedDay!)
        : (nextTotal == 0
              ? null
              : (habit.lastCompletedDayKey == dayKey
                    ? null
                    : habit.lastCompletedDayKey));

    final updatedHabit = habit.copyWith(
      currentStreak: nextCurrent,
      bestStreak: nextBest,
      totalCheckIns: nextTotal,
      lastCompletedDayKey: nextLastDay,
    );
    final nextHabits = [
      for (final h in state.habits)
        if (h.id == habit.id) updatedHabit else h,
    ];
    emit(state.copyWith(habits: nextHabits, entries: updatedEntries));

    final statsUpdate = <String, dynamic>{
      'currentStreak': nextCurrent,
      'bestStreak': nextBest,
      'totalCheckIns': nextTotal,
      'lastCompletedDayKey': nextLastDay,
    };

    try {
      await _repo.removeCheckIn(
        _currentUid!,
        habitId: habit.id,
        logicalDayKey: dayKey,
        habitStatsUpdate: statsUpdate,
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          action: state.action.toFailed(
            fault: Fault.fromObjectAndStackTrace(e, s),
          ),
        ),
      );
    }
  }

  void _applyOptimisticEntryUpsert(Entry entry) {
    final hotKey = _subscribedHotWindowKey;
    if (hotKey == null || entry.logicalDayKey.compareTo(hotKey) >= 0) {
      _hotEntries = List<Entry>.from(_hotEntries)
        ..removeWhere(
          (e) =>
              e.habitId == entry.habitId &&
              e.logicalDayKey == entry.logicalDayKey,
        )
        ..add(entry);
    } else {
      final monthKey = HistoryWindowHelper.monthKeyForDayKey(
        entry.logicalDayKey,
      );
      final list = List<Entry>.from(_coldEntriesByMonth[monthKey] ?? const [])
        ..removeWhere(
          (e) =>
              e.habitId == entry.habitId &&
              e.logicalDayKey == entry.logicalDayKey,
        )
        ..add(entry);
      _coldEntriesByMonth[monthKey] = list;
    }
  }

  void _applyOptimisticEntryRemoval(String habitId, String dayKey) {
    _hotEntries = List<Entry>.from(_hotEntries)
      ..removeWhere((e) => e.habitId == habitId && e.logicalDayKey == dayKey);
    final monthKey = HistoryWindowHelper.monthKeyForDayKey(dayKey);
    final cold = _coldEntriesByMonth[monthKey];
    if (cold != null) {
      _coldEntriesByMonth[monthKey] = List<Entry>.from(cold)
        ..removeWhere((e) => e.habitId == habitId && e.logicalDayKey == dayKey);
    }
  }

  Future<void> createHabit({
    required String name,
    required String emoji,
    required String colorHex,
    List<String>? habitOrder,
  }) async {
    if (_currentUid == null) return;
    emit(state.copyWith(action: state.action.toLoading()));

    final nextSortOrder = state.habits.isEmpty
        ? 0
        : (state.habits
                  .map((h) => h.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1);

    final trimmedName = name.trim();
    final safeName = trimmedName.length > 100
        ? trimmedName.substring(0, 100)
        : trimmedName;
    final habit = Habit(
      id: Habit.generateId(name: safeName),
      name: safeName,
      emoji: emoji,
      colorHex: colorHex,
      sortOrder: nextSortOrder,
      createdAt: DateTime.now(),
    );

    try {
      final updatedOrder = habitOrder != null
          ? (List<String>.from(habitOrder)..add(habit.id))
          : null;
      await _repo.upsertHabit(
        _currentUid!,
        habit.toJson(),
        isUpdate: false,
        appendHabitOrder: updatedOrder,
      );
      emit(state.copyWith(action: state.action.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(
        state.copyWith(
          action: state.action.toFailed(
            fault: Fault.fromObjectAndStackTrace(e, s),
          ),
        ),
      );
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (_currentUid == null) return;
    emit(state.copyWith(action: state.action.toLoading()));

    try {
      await _repo.upsertHabit(_currentUid!, habit.toJson(), isUpdate: true);
      emit(state.copyWith(action: state.action.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(
        state.copyWith(
          action: state.action.toFailed(
            fault: Fault.fromObjectAndStackTrace(e, s),
          ),
        ),
      );
    }
  }

  Future<void> deleteHabit(Habit habit) async {
    if (_currentUid == null) return;
    emit(state.copyWith(action: state.action.toLoading()));

    try {
      await _repo.deleteHabit(_currentUid!, habit.id);
      emit(state.copyWith(action: state.action.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(
        state.copyWith(
          action: state.action.toFailed(
            fault: Fault.fromObjectAndStackTrace(e, s),
          ),
        ),
      );
    }
  }

  Future<void> reorderHabits(List<Habit> reordered) async {
    if (_currentUid == null) return;
    final updated = <Habit>[];
    for (var i = 0; i < reordered.length; i++) {
      updated.add(reordered[i].copyWith(sortOrder: i));
    }
    final archived = state.habits.where((h) => h.isArchived).toList();
    emit(state.copyWith(habits: [...updated, ...archived]));

    try {
      final habitOrder = updated.map((h) => h.id).toList();
      await _repo.reorderHabits(_currentUid!, habitOrder);
    } catch (e, s) {
      'Failed to reorder habits: $e'.appLog(
        tag: 'HABITS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_habitsSub?.cancel());
    unawaited(_entriesSub?.cancel());
    return super.close();
  }
}
