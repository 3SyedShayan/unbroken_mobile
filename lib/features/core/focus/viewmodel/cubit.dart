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

part 'state.dart';

class FocusCubit extends Cubit<FocusState> {
  static FocusCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<FocusCubit>(context, listen: listen);

  final FocusRepo _repo;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  String? _currentUid;

  FocusCubit({FocusRepo? repo})
      : _repo = repo ?? FocusRepo.ins,
        super(FocusState(
          fetch: BlocState<List<DailyFocus>>(),
          action: BlocState<void>(),
        )) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
  }

  void _clearOnSignOut() {
    _sub?.cancel();
    _sub = null;
    _currentUid = null;
    emit(FocusState(
      fetch: BlocState<List<DailyFocus>>(),
      action: BlocState<void>(),
    ));
  }

  void onAppResumed() {
    if (_currentUid != null) {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      final windowKey = DaySettings.dayKey(ninetyDaysAgo);
      _sub?.cancel();
      _sub = _repo
          .observeFocus(_currentUid!, windowStartKey: windowKey)
          .listen((rawList) {
        final list = rawList.map((m) => DailyFocus.fromJson(m)).toList();
        emit(state.copyWith(
          focusList: list,
          fetch: state.fetch.toSuccess(data: list),
        ));
      });
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
    _sub?.cancel();

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final windowKey = DaySettings.dayKey(thirtyDaysAgo);

    _sub = _repo.observeFocus(uid, windowStartKey: windowKey).listen((rawList) {
      final list = rawList.map((m) => DailyFocus.fromJson(m)).toList();
      emit(state.copyWith(
        focusList: list,
        fetch: state.fetch.toSuccess(data: list),
      ));
    });
  }

  Future<void> toggleSlot({
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final dayKey = settings.logicalDayKey(asOf);
    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (index >= items.length) return;

    final target = items[index];
    if (target.text.trim().isEmpty) return;

    final updatedItem = target.copyWith(done: !target.done);
    items[index] = updatedItem;

    final willBeCleared =
        items.isNotEmpty && items.every((it) => it.done && it.text.trim().isNotEmpty);

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
  }) async {
    final dayKey = settings.logicalDayKey(asOf);
    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);
    if (index >= items.length) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(text: text);
    }

    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> deleteTask({
    required int index,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final dayKey = settings.logicalDayKey(asOf);
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
  }) =>
      deleteTask(index: index, asOf: asOf, settings: settings);

  Future<void> addTask({
    required String text,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final dayKey = settings.logicalDayKey(asOf);
    final current = state.focusForDay(dayKey);
    final items = List<FocusItem>.from(current.itemsList);

    if (items.length >= maxTasks) return;

    items.add(FocusItem(
      id: 's${items.length}_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      done: false,
    ));

    await _commitItems(dayKey: dayKey, items: items);
  }

  Future<void> applyRolloverIfEnabled({
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (!settings.rolloverTasks || _currentUid == null) return;
    final todayKey = settings.logicalDayKey(asOf);
    final currentToday = state.focusForDay(todayKey);

    // If today already has tasks written, do not overwrite
    if (currentToday.itemsList.isNotEmpty) return;

    final yesterday = settings.logicalDay(asOf).subtract(const Duration(days: 1));
    final yesterdayKey = DaySettings.dayKey(yesterday);
    final yesterdayFocus = state.focusForDay(yesterdayKey);
    final unfinished = yesterdayFocus.itemsList
        .where((it) => !it.done && it.text.trim().isNotEmpty)
        .toList();

    if (unfinished.isEmpty) return;

    final newItems = <FocusItem>[];
    for (var i = 0; i < unfinished.length && i < maxTasks; i++) {
      newItems.add(FocusItem(
        id: 's$i',
        text: unfinished[i].text,
        done: false,
      ));
    }

    await _commitItems(dayKey: todayKey, items: newItems);
  }

  Future<void> _commitItems({
    required String dayKey,
    required List<FocusItem> items,
  }) async {
    if (_currentUid == null) return;

    final validItems = items.where((it) => it.text.trim().isNotEmpty).toList();

    if (validItems.isEmpty) {
      // If all items are deleted/blank, delete the daily focus record to match macOS
      final copy = List<DailyFocus>.from(state.focusList)
        ..removeWhere((f) => f.logicalDayKey == dayKey);
      emit(state.copyWith(focusList: copy));

      try {
        await _repo.deleteFocus(_currentUid!, dayKey);
      } on Fault catch (f) {
        emit(state.copyWith(action: state.action.toFailed(fault: f)));
      } catch (e, s) {
        emit(state.copyWith(
          action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
        ));
      }
      return;
    }

    final slotsMap = <String, FocusItem>{};
    for (var i = 0; i < validItems.length && i < maxTasks; i++) {
      slotsMap[i.toString()] = validItems[i].copyWith(
        id: validItems[i].id.isNotEmpty ? validItems[i].id : 's$i',
      );
    }

    final updated = DailyFocus(logicalDayKey: dayKey, slots: slotsMap);

    // Optimistic UI update
    final copy = List<DailyFocus>.from(state.focusList)
      ..removeWhere((f) => f.logicalDayKey == dayKey)
      ..add(updated);
    emit(state.copyWith(focusList: copy));

    try {
      final jsonSlots = <String, dynamic>{};
      slotsMap.forEach((k, v) => jsonSlots[k] = v.toJson());
      await _repo.upsertFocus(_currentUid!, dayKey, {
        'logicalDayKey': dayKey,
        'slots': jsonSlots,
      });
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
