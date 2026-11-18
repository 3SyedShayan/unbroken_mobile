import 'dart:async';

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
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  static HabitsCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<HabitsCubit>(context, listen: listen);

  final HabitsRepo _repo;
  StreamSubscription<List<Map<String, dynamic>>>? _habitsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _entriesSub;
  String? _currentUid;

  HabitsCubit({HabitsRepo? repo})
      : _repo = repo ?? HabitsRepo.ins,
        super(HabitsState(
          fetch: BlocState<List<Habit>>(),
          action: BlocState<void>(),
        )) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
  }

  void _clearOnSignOut() {
    _habitsSub?.cancel();
    _entriesSub?.cancel();
    _habitsSub = null;
    _entriesSub = null;
    _currentUid = null;
    emit(HabitsState(
      fetch: BlocState<List<Habit>>(),
      action: BlocState<void>(),
    ));
  }

  void onAppResumed() {
    if (_currentUid != null) {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      final windowKey = DaySettings.dayKey(ninetyDaysAgo);
      _entriesSub?.cancel();
      _entriesSub = _repo
          .observeEntries(_currentUid!, windowStartKey: windowKey)
          .listen((rawList) {
        final entries = <Entry>[];
        for (final m in rawList) {
          try {
            entries.add(Entry.fromJson(m));
          } catch (e) {
            'Failed to parse entry: $m, error: $e'.appLog(level: AppLogLevel.warning);
          }
        }
        emit(state.copyWith(entries: entries));
      }, onError: (Object e, StackTrace s) {
        'Error in observeEntries: $e'.appLog(level: AppLogLevel.error);
      });
    }
  }

  void startObserving(String uid) {
    if (_currentUid == uid && _habitsSub != null) return;
    _currentUid = uid;
    _habitsSub?.cancel();
    _entriesSub?.cancel();

    _habitsSub = _repo.observeHabits(uid).listen((rawList) {
      final habits = <Habit>[];
      for (final m in rawList) {
        try {
          habits.add(Habit.fromJson(m));
        } catch (e) {
          'Failed to parse habit: $m, error: $e'.appLog(level: AppLogLevel.warning);
        }
      }
      emit(state.copyWith(
        habits: habits,
        fetch: state.fetch.toSuccess(data: habits),
      ));
    }, onError: (Object e, StackTrace s) {
      'Error in observeHabits: $e'.appLog(level: AppLogLevel.error);
    });

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final windowKey = DaySettings.dayKey(thirtyDaysAgo);

    _entriesSub = _repo.observeEntries(uid, windowStartKey: windowKey).listen((rawList) {
      final entries = <Entry>[];
      for (final m in rawList) {
        try {
          entries.add(Entry.fromJson(m));
        } catch (e) {
          'Failed to parse entry: $m, error: $e'.appLog(level: AppLogLevel.warning);
        }
      }
      emit(state.copyWith(entries: entries));
    }, onError: (Object e, StackTrace s) {
      'Error in observeEntries: $e'.appLog(level: AppLogLevel.error);
    });
  }

  Future<void> toggleCheckIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    final done = state.isCompleted(
      habit: habit,
      asOf: asOf,
      settings: settings,
    );
    if (done) {
      await undoCheckIn(habit: habit, asOf: asOf, settings: settings);
    } else {
      await checkIn(habit: habit, asOf: asOf, settings: settings);
    }
  }

  Future<void> checkIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (_currentUid == null) return;

    final today = settings.logicalDay(DateTime.now());
    final target = settings.logicalDay(asOf);
    if (target.isAfter(today)) return; // Future days rejected (matches macOS)

    final dayKey = settings.logicalDayKey(asOf);

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
      timestamp: DateTime.now(),
    );
    final updatedEntries = List<Entry>.from(state.entries)
      ..removeWhere((e) => e.habitId == habit.id && e.logicalDayKey == dayKey)
      ..add(tempEntry);
    emit(state.copyWith(entries: updatedEntries));

    try {
      await _repo.recordCheckIn(
        _currentUid!,
        habitId: habit.id,
        logicalDayKey: dayKey,
      );
    } catch (e, s) {
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  Future<void> undoCheckIn({
    required Habit habit,
    required DateTime asOf,
    required DaySettings settings,
  }) async {
    if (_currentUid == null) return;

    final today = settings.logicalDay(DateTime.now());
    final target = settings.logicalDay(asOf);
    if (target.isAfter(today)) return; // Future days rejected (matches macOS)

    final dayKey = settings.logicalDayKey(asOf);

    if (settings.streakSounds) {
      HapticFeedback.lightImpact();
    }

    // Optimistic UI update
    final updatedEntries = List<Entry>.from(state.entries)
      ..removeWhere((e) => e.habitId == habit.id && e.logicalDayKey == dayKey);
    emit(state.copyWith(entries: updatedEntries));

    try {
      await _repo.removeCheckIn(
        _currentUid!,
        habitId: habit.id,
        logicalDayKey: dayKey,
      );
    } catch (e, s) {
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
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
        : (state.habits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b) + 1);

    final habit = Habit(
      id: Habit.generateId(name: name),
      name: name,
      emoji: emoji,
      colorHex: colorHex,
      sortOrder: nextSortOrder,
      createdAt: DateTime.now(),
    );

    try {
      await _repo.upsertHabit(_currentUid!, habit.toJson());
      if (habitOrder != null) {
        final updatedOrder = List<String>.from(habitOrder)..add(habit.id);
        await _repo.reorderHabits(_currentUid!, [], updatedOrder);
      }
      emit(state.copyWith(action: state.action.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (_currentUid == null) return;
    emit(state.copyWith(action: state.action.toLoading()));

    try {
      await _repo.upsertHabit(_currentUid!, habit.toJson());
      emit(state.copyWith(action: state.action.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(action: state.action.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
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
      emit(state.copyWith(
        action: state.action.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  Future<void> reorderHabits(List<Habit> reordered) async {
    if (_currentUid == null) return;
    final updated = <Habit>[];
    for (var i = 0; i < reordered.length; i++) {
      updated.add(reordered[i].copyWith(sortOrder: i));
    }
    emit(state.copyWith(habits: updated));

    try {
      final habitOrder = updated.map((h) => h.id).toList();
      await _repo.reorderHabits(
        _currentUid!,
        updated.map((h) => h.toJson()).toList(),
        habitOrder,
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _habitsSub?.cancel();
    _entriesSub?.cancel();
    return super.close();
  }
}
