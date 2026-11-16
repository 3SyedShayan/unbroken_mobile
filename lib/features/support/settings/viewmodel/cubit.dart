import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';

part 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static SettingsCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<SettingsCubit>(context, listen: listen);

  final SettingsRepo _repo;
  StreamSubscription<Map<String, dynamic>?>? _sub;
  String? _currentUid;

  SettingsCubit({SettingsRepo? repo})
      : _repo = repo ?? SettingsRepo.ins,
        super(SettingsState(
          settings: const DaySettings(),
          fetch: BlocState<DaySettings>(),
          update: BlocState<void>(),
        )) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
    _loadLocal();
  }

  void _clearOnSignOut() {
    _sub?.cancel();
    _sub = null;
    _currentUid = null;
    emit(SettingsState(
      settings: const DaySettings(),
      fetch: BlocState<DaySettings>(),
      update: BlocState<void>(),
    ));
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    try {
      final local = await _repo.loadLocalPreferences();
      emit(state.copyWith(
        settings: state.settings.copyWith(
          sinkCompletedHabits: local['sinkCompletedHabits'] as bool? ?? true,
          rolloverTasks: local['rolloverTasks'] as bool? ?? false,
          streakSounds: local['streakSounds'] as bool? ?? true,
          reminders: local['reminders'] as bool? ?? false,
        ),
      ));
    } catch (_) {}
  }

  void startObserving(String uid) {
    if (_currentUid == uid && _sub != null) return;
    _currentUid = uid;
    _sub?.cancel();

    _sub = _repo.observeSettings(uid).listen((remoteData) {
      if (remoteData != null) {
        final parsed = DaySettings.fromJson(remoteData);
        emit(state.copyWith(
          settings: state.settings.copyWith(
            dayEndHour: parsed.dayEndHour,
            atRiskWindowHours: parsed.atRiskWindowHours,
            habitOrder: parsed.habitOrder,
            weekStartMonday: parsed.weekStartMonday,
            hasOnboarded: parsed.hasOnboarded,
            didCheckInOnce: parsed.didCheckInOnce,
          ),
          fetch: state.fetch.toSuccess(data: parsed),
        ));
      }
    });
  }

  Future<void> updateDaySettings(DaySettings newSettings, [String? uid]) async {
    emit(state.copyWith(
      settings: newSettings,
      update: state.update.toLoading(),
    ));

    try {
      final targetUid = uid ?? _currentUid;
      if (targetUid != null) {
        await _repo.updateSettings(targetUid, newSettings.toJson());
      }
      await _repo.updateLocalPreferences({
        'sinkCompletedHabits': newSettings.sinkCompletedHabits,
        'rolloverTasks': newSettings.rolloverTasks,
        'streakSounds': newSettings.streakSounds,
        'reminders': newSettings.reminders,
      });
      emit(state.copyWith(update: state.update.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(update: state.update.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        update: state.update.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  Future<void> toggleWeekStartMonday(bool val, [String? uid]) async {
    final updated = state.settings.copyWith(weekStartMonday: val);
    await updateDaySettings(updated, uid);
  }

  Future<void> toggleSinkCompletedHabits(bool val) async {
    final updated = state.settings.copyWith(sinkCompletedHabits: val);
    await updateDaySettings(updated);
  }

  Future<void> toggleRolloverTasks(bool val) async {
    final updated = state.settings.copyWith(rolloverTasks: val);
    await updateDaySettings(updated);
  }

  Future<void> toggleStreakSounds(bool val) async {
    final updated = state.settings.copyWith(streakSounds: val);
    await updateDaySettings(updated);
  }

  Future<void> toggleReminders(bool val) async {
    final updated = state.settings.copyWith(reminders: val);
    await updateDaySettings(updated);
  }

  Future<void> setOnboarded(bool val, [String? uid]) async {
    final updated = state.settings.copyWith(hasOnboarded: val);
    await updateDaySettings(updated, uid);
  }

  Future<void> setDidCheckInOnce(bool val, [String? uid]) async {
    final updated = state.settings.copyWith(didCheckInOnce: val);
    await updateDaySettings(updated, uid);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
