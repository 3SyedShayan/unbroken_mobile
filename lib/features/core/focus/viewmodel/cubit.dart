import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/focus/domain/focus_streak_calculator.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_focus.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_task_result.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/services/cache/cache_service.dart';
import 'package:unbroken_mobile/services/firebase/firebase_config.dart';
import 'package:unbroken_mobile/services/firebase/history_window_helper.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'state.dart';

class FocusCubit extends Cubit<FocusState> {
  static FocusCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<FocusCubit>(context, listen: listen);

  final FocusRepo _repo;
  final CacheService _cacheService;
  final Duration _textDebounceDuration;

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  String? _currentUid;
  String? _subscribedHotWindowKey;
  int _observedWindowDays = 0;

  List<DailyFocus> _hotFocus = const [];
  final Map<String, List<DailyFocus>> _coldFocusByMonth = {};
  final Set<String> _loadedColdMonths = {};
  final Set<String> _inFlightColdMonths = {};

  Timer? _textDebounceTimer;
  ({String dayKey, List<FocusItem> items})? _pendingTextCommit;
  bool _hasInitialSnapshot = false;
  String? _lastRolloverDayKey;
  ({DateTime asOf, DaySettings settings})? _pendingRollover;

  int get observedWindowDays => _observedWindowDays;

  FocusCubit({
    FocusRepo? repo,
    CacheService? cacheService,
    Duration textDebounceDuration = const Duration(milliseconds: 750),
  })  : _repo = repo ?? FocusRepo.ins,
        _cacheService = cacheService ?? CacheService.ins,
        _textDebounceDuration = textDebounceDuration,
        super(
          FocusState(
            fetch: BlocState<List<DailyFocus>>(),
            action: BlocState<void>(),
          ),
        ) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
  }

  Future<void> _clearOnSignOut() async {
    await flushPendingCommits();
    _textDebounceTimer?.cancel();
    _textDebounceTimer = null;
    _pendingTextCommit = null;
    await _sub?.cancel();
    _sub = null;
    _currentUid = null;
    _subscribedHotWindowKey = null;
    _observedWindowDays = 0;
    _hotFocus = const [];
    _coldFocusByMonth.clear();
    _loadedColdMonths.clear();
    _inFlightColdMonths.clear();
    _hasInitialSnapshot = false;
    _lastRolloverDayKey = null;
    _pendingRollover = null;
    if (!isClosed) {
      emit(
        FocusState(
          fetch: BlocState<List<DailyFocus>>(),
          action: BlocState<void>(),
        ),
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
      final syncKey = 'focus_month_${uid}_${bucket.monthKey}';
      final lastSync = await _cacheService.getLastSearchTime(syncKey);
      final preferCache =
          lastSync != null &&
          DateTime.now().difference(lastSync) < FirebaseConfig.coldMonthCacheTtl;

      final rawList = await _repo.fetchFocusRange(
        uid,
        startKey: bucket.startKey,
        endKeyExclusive: bucket.endKeyExclusive,
        preferCache: preferCache,
      );

      final parsed = <DailyFocus>[];
      for (final m in rawList) {
        try {
          parsed.add(DailyFocus.fromJson(m));
        } catch (e, s) {
          final key = m['logicalDayKey'] ?? 'unknown';
          'Failed to parse cold daily focus ($key): $e'.appLog(
            tag: 'FOCUS',
            level: AppLogLevel.error,
            error: e,
            stackTrace: s,
          );
        }
      }

      if (_currentUid != uid || isClosed) return;
      _coldFocusByMonth[bucket.monthKey] = parsed;
      _loadedColdMonths.add(bucket.monthKey);
      if (!preferCache) {
        await _cacheService.setLastSearchTime(syncKey, DateTime.now());
      }
      _emitMergedFocus(markFetchSuccess: true);
    } catch (e, s) {
      'Failed to load cold focus month (${bucket.monthKey}): $e'.appLog(
        tag: 'FOCUS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    } finally {
      _inFlightColdMonths.remove(bucket.monthKey);
    }
  }

  List<DailyFocus> _buildMergedFocus() {
    final hotKey = _subscribedHotWindowKey;
    final byDay = <String, DailyFocus>{};
    for (final list in _coldFocusByMonth.values) {
      for (final focus in list) {
        if (hotKey == null || focus.logicalDayKey.compareTo(hotKey) < 0) {
          byDay[focus.logicalDayKey] = focus;
        }
      }
    }
    for (final focus in _hotFocus) {
      byDay[focus.logicalDayKey] = focus;
    }
    return byDay.values.toList();
  }

  void _emitMergedFocus({bool markFetchSuccess = false}) {
    if (isClosed) return;
    final merged = _buildMergedFocus();
    emit(
      state.copyWith(
        focusList: merged,
        fetch: markFetchSuccess ? state.fetch.toSuccess(data: merged) : null,
      ),
    );
  }

  void _subscribeFocus(String uid) {
    final now = DateTime.now();
    final windowKey = HistoryWindowHelper.hotWindowStartKey(now);
    if (_sub != null && _subscribedHotWindowKey == windowKey) return;

    _subscribedHotWindowKey = windowKey;
    final previousSub = _sub;
    if (previousSub != null) {
      unawaited(previousSub.cancel());
    }

    _sub = _repo
        .observeFocus(uid, windowStartKey: windowKey)
        .listen(
          (rawList) {
            final list = <DailyFocus>[];
            for (final m in rawList) {
              try {
                list.add(DailyFocus.fromJson(m));
              } catch (e, s) {
                final key = m['logicalDayKey'] ?? 'unknown';
                'Failed to parse daily focus ($key): $e'.appLog(
                  tag: 'FOCUS',
                  level: AppLogLevel.error,
                  error: e,
                  stackTrace: s,
                );
              }
            }
            _hotFocus = list;
            _hasInitialSnapshot = true;
            _emitMergedFocus(markFetchSuccess: true);

            final pendingRollover = _pendingRollover;
            if (pendingRollover != null) {
              _pendingRollover = null;
              unawaited(
                _executeRollover(
                  asOf: pendingRollover.asOf,
                  settings: pendingRollover.settings,
                ),
              );
            }
          },
          onError: (Object e, StackTrace s) {
            'Error in observeFocus: $e'.appLog(
              tag: 'FOCUS',
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
      _subscribeFocus(uid);
      final hotDays = HistoryWindowHelper.hotWindowCoveredDays(now);
      if (_observedWindowDays > hotDays) {
        ensureHistoryWindowDays(_observedWindowDays);
      }
    }
  }

  static const int maxTasks = 10;

  static List<FocusItem> get emptyThree => [
    const FocusItem(id: 's0', text: '', done: false),
    const FocusItem(id: 's1', text: '', done: false),
    const FocusItem(id: 's2', text: '', done: false),
  ];

  void startObserving(String uid) {
    if (_currentUid == uid && _sub != null) return;
    _currentUid = uid;
    unawaited(_sub?.cancel());
    _sub = null;
    _subscribedHotWindowKey = null;
    _hotFocus = const [];
    _coldFocusByMonth.clear();
    _loadedColdMonths.clear();
    _inFlightColdMonths.clear();
    _hasInitialSnapshot = false;
    _lastRolloverDayKey = null;
    _pendingRollover = null;

    final hotDays = HistoryWindowHelper.hotWindowCoveredDays(DateTime.now());
    if (_observedWindowDays < hotDays) {
      _observedWindowDays = hotDays;
    }

    _subscribeFocus(uid);
    if (_observedWindowDays > hotDays) {
      ensureHistoryWindowDays(_observedWindowDays);
    }
  }

  Future<void> toggleSlot({
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final dayKey = settings.logicalDayKey(asOf);
    await _preparePendingForDay(dayKey);

    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (index >= items.length) return;

    final target = items[index];
    if (target.text.trim().isEmpty) return;

    final updatedItem = target.copyWith(done: !target.done);
    items[index] = updatedItem;

    final willBeCleared =
        items.isNotEmpty &&
        items.every((it) => it.done && it.text.trim().isNotEmpty);

    if (settings.streakSounds) {
      if (willBeCleared && !current.isCleared) {
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
      } else {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
      }
    }

    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> updateSlotText({
    required int index,
    required String text,
    required DateTime asOf,
    required DaySettings settings,
    bool pruneEmpty = true,
  }) async {
    if (_currentUid == null) return;
    final dayKey = settings.logicalDayKey(asOf);
    if (_pendingTextCommit != null && _pendingTextCommit!.dayKey != dayKey) {
      await flushPendingCommits();
    }

    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (index >= items.length) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      if (!pruneEmpty) return;
      items.removeAt(index);
    } else {
      final safeText = text.length > 300 ? text.substring(0, 300) : text;
      items[index] = items[index].copyWith(text: safeText);
    }

    _applyOptimisticFocus(dayKey: dayKey, items: items);
    _pendingTextCommit = (dayKey: dayKey, items: items);
    _textDebounceTimer?.cancel();
    _textDebounceTimer = Timer(_textDebounceDuration, () {
      unawaited(flushPendingCommits());
    });
  }

  Future<void> restoreTask({
    required FocusItem item,
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (item.text.trim().isEmpty) return;
    final dayKey = settings.logicalDayKey(asOf);
    await _preparePendingForDay(dayKey);

    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (items.length >= maxTasks) return;

    items.insert(index.clamp(0, items.length), item);
    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> flushPendingCommits() async {
    _textDebounceTimer?.cancel();
    _textDebounceTimer = null;
    final pending = _pendingTextCommit;
    _pendingTextCommit = null;
    if (pending == null || _currentUid == null) return;
    await _commitRemote(dayKey: pending.dayKey, items: pending.items);
  }

  Future<void> _preparePendingForDay(String dayKey) async {
    final pending = _pendingTextCommit;
    if (pending == null) return;
    if (pending.dayKey == dayKey) {
      _textDebounceTimer?.cancel();
      _textDebounceTimer = null;
      _pendingTextCommit = null;
    } else {
      await flushPendingCommits();
    }
  }

  Future<void> deleteTask({
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final dayKey = settings.logicalDayKey(asOf);
    await _preparePendingForDay(dayKey);

    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (index < 0 || index >= items.length) return;

    items.removeAt(index);
    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> deleteSlot({
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) => deleteTask(index: index, asOf: asOf, settings: settings);

  Future<void> addTask({
    required String text,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final dayKey = settings.logicalDayKey(asOf);
    await _preparePendingForDay(dayKey);

    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);

    if (items.length >= maxTasks) return;

    final safeText = trimmed.length > 300 ? trimmed.substring(0, 300) : trimmed;
    items.add(
      FocusItem(
        id: 's${items.length}_${DateTime.now().millisecondsSinceEpoch}',
        text: safeText,
        done: false,
      ),
    );

    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> applyRolloverIfEnabled({
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (!settings.rolloverTasks || _currentUid == null) return;
    if (!_hasInitialSnapshot) {
      _pendingRollover = (asOf: asOf, settings: settings);
      return;
    }
    await _executeRollover(asOf: asOf, settings: settings);
  }

  Future<void> _executeRollover({
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (!settings.rolloverTasks || _currentUid == null) return;
    final todayKey = settings.logicalDayKey(asOf);
    if (_lastRolloverDayKey == todayKey) return;
    _lastRolloverDayKey = todayKey;

    final currentToday = state.focusForDay(todayKey);

    // If today already has tasks written, do not overwrite
    if (currentToday.itemsList.isNotEmpty) return;

    final todayLogical = settings.logicalDay(asOf);
    final yesterday = DateTime(
      todayLogical.year,
      todayLogical.month,
      todayLogical.day - 1,
    );
    final yesterdayKey = DaySettings.dayKey(yesterday);
    final yesterdayFocus = state.focusForDay(yesterdayKey);
    final unfinished = yesterdayFocus.itemsList
        .where((it) => !it.done && it.text.trim().isNotEmpty)
        .toList();

    if (unfinished.isEmpty) return;

    final newItems = <FocusItem>[];
    for (var i = 0; i < unfinished.length && i < maxTasks; i++) {
      newItems.add(FocusItem(id: 's$i', text: unfinished[i].text, done: false));
    }

    await _commitItems(dayKey: todayKey, items: newItems);
  }

  void _applyOptimisticFocus({
    required String dayKey,
    required List<FocusItem> items,
  }) {
    final validItems = items.where((it) => it.text.trim().isNotEmpty).toList();
    final hotKey = _subscribedHotWindowKey;
    final isHot = hotKey == null || dayKey.compareTo(hotKey) >= 0;

    if (validItems.isEmpty) {
      if (isHot) {
        _hotFocus = List<DailyFocus>.from(_hotFocus)
          ..removeWhere((f) => f.logicalDayKey == dayKey);
      } else {
        final monthKey = HistoryWindowHelper.monthKeyForDayKey(dayKey);
        final cold = _coldFocusByMonth[monthKey];
        if (cold != null) {
          _coldFocusByMonth[monthKey] = List<DailyFocus>.from(cold)
            ..removeWhere((f) => f.logicalDayKey == dayKey);
        }
      }
      _emitMergedFocus();
      return;
    }

    final slotsMap = <String, FocusItem>{};
    for (var i = 0; i < validItems.length && i < maxTasks; i++) {
      slotsMap[i.toString()] = validItems[i].copyWith(
        id: validItems[i].id.isNotEmpty ? validItems[i].id : 's$i',
      );
    }

    final updated = DailyFocus(logicalDayKey: dayKey, slots: slotsMap);
    if (isHot) {
      _hotFocus = List<DailyFocus>.from(_hotFocus)
        ..removeWhere((f) => f.logicalDayKey == dayKey)
        ..add(updated);
    } else {
      final monthKey = HistoryWindowHelper.monthKeyForDayKey(dayKey);
      _coldFocusByMonth[monthKey] = List<DailyFocus>.from(
        _coldFocusByMonth[monthKey] ?? const [],
      )
        ..removeWhere((f) => f.logicalDayKey == dayKey)
        ..add(updated);
    }
    _emitMergedFocus();
  }

  Future<void> _commitItems({
    required String dayKey,
    required List<FocusItem> items,
  }) async {
    if (_currentUid == null) return;
    _applyOptimisticFocus(dayKey: dayKey, items: items);
    await _commitRemote(dayKey: dayKey, items: items);
  }

  Future<void> _commitRemote({
    required String dayKey,
    required List<FocusItem> items,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;

    final validItems = items.where((it) => it.text.trim().isNotEmpty).toList();

    if (validItems.isEmpty) {
      try {
        await _repo.deleteFocus(uid, dayKey);
      } on Fault catch (f) {
        if (!isClosed) {
          emit(state.copyWith(action: state.action.toFailed(fault: f)));
        }
      } catch (e, s) {
        if (!isClosed) {
          emit(
            state.copyWith(
              action: state.action.toFailed(
                fault: Fault.fromObjectAndStackTrace(e, s),
              ),
            ),
          );
        }
      }
      return;
    }

    final slotsMap = <String, FocusItem>{};
    for (var i = 0; i < validItems.length && i < maxTasks; i++) {
      slotsMap[i.toString()] = validItems[i].copyWith(
        id: validItems[i].id.isNotEmpty ? validItems[i].id : 's$i',
      );
    }

    try {
      final jsonSlots = <String, dynamic>{};
      slotsMap.forEach((k, v) => jsonSlots[k] = v.toJson());
      await _repo.upsertFocus(uid, dayKey, {
        'logicalDayKey': dayKey,
        'slots': jsonSlots,
      });
    } on Fault catch (f) {
      if (!isClosed) {
        emit(state.copyWith(action: state.action.toFailed(fault: f)));
      }
    } catch (e, s) {
      if (!isClosed) {
        emit(
          state.copyWith(
            action: state.action.toFailed(
              fault: Fault.fromObjectAndStackTrace(e, s),
            ),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _textDebounceTimer?.cancel();
    _textDebounceTimer = null;
    unawaited(flushPendingCommits());
    unawaited(_sub?.cancel());
    return super.close();
  }
}
