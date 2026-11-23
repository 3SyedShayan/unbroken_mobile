import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/services/notifications/local_notification_service.dart';

part 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static SettingsCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<SettingsCubit>(context, listen: listen);

  final SettingsRepo _repo;
  StreamSubscription<Map<String, dynamic>?>? _sub;
  String? _currentUid;
  Future<DaySettings>? _loadLocalFuture;

  SettingsCubit({SettingsRepo? repo})
      : _repo = repo ?? SettingsRepo.ins,
        super(SettingsState(
          settings: const DaySettings(),
          fetch: BlocState<DaySettings>(),
          update: BlocState<void>(),
        )) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
    loadLocal();
  }

  Future<void> _clearOnSignOut() async {
    _sub?.cancel();
    _sub = null;
    _currentUid = null;
    _loadLocalFuture = null;
    emit(SettingsState(
      settings: const DaySettings(),
      fetch: BlocState<DaySettings>(),
      update: BlocState<void>(),
    ));
    try {
      await _repo.clearLocalPreferences();
    } catch (_) {}
    loadLocal();
  }

  Future<DaySettings> loadLocal() {
    return _loadLocalFuture ??= _loadLocal();
  }

  Future<DaySettings> _loadLocal() async {
    try {
      final local = await _repo.loadLocalPreferences();
      final localHasOnboarded = local['hasOnboarded'] as bool? ?? false;
      final localDidCheckInOnce = local['didCheckInOnce'] as bool? ?? false;

      final updated = state.settings.copyWith(
        hasOnboarded: localHasOnboarded || state.settings.hasOnboarded,
        didCheckInOnce: localDidCheckInOnce || state.settings.didCheckInOnce,
        sinkCompletedHabits: local['sinkCompletedHabits'] as bool? ?? true,
        rolloverTasks: local['rolloverTasks'] as bool? ?? false,
        streakSounds: local['streakSounds'] as bool? ?? true,
        reminders: local['reminders'] as bool? ?? false,
        morningReminderEnabled: local['morningReminderEnabled'] as bool? ?? false,
        morningReminderTime: local['morningReminderTime'] as String? ?? '09:00',
        nightReminderEnabled: local['nightReminderEnabled'] as bool? ?? false,
        nightReminderTime: local['nightReminderTime'] as String? ?? '21:00',
        progressRange: local['progressRange'] as String? ?? '1m',
      );
      emit(state.copyWith(settings: updated));
      await _syncNotifications(updated);
      return updated;
    } catch (_) {
      return state.settings;
    }
  }

  Future<DaySettings> startObserving(String uid) async {
    await loadLocal();
    if (_currentUid == uid && _sub != null) return state.settings;
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
        _repo.updateLocalPreferences({
          'hasOnboarded': parsed.hasOnboarded,
          'didCheckInOnce': parsed.didCheckInOnce,
        });
      }
    });

    try {
      final raw = await _repo.getSettings(uid).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (raw != null) {
        final parsed = DaySettings.fromJson(raw);
        final updated = state.settings.copyWith(
          dayEndHour: parsed.dayEndHour,
          atRiskWindowHours: parsed.atRiskWindowHours,
          habitOrder: parsed.habitOrder,
          weekStartMonday: parsed.weekStartMonday,
          hasOnboarded: parsed.hasOnboarded,
          didCheckInOnce: parsed.didCheckInOnce,
        );
        emit(state.copyWith(
          settings: updated,
          fetch: state.fetch.toSuccess(data: parsed),
        ));
        await _repo.updateLocalPreferences({
          'hasOnboarded': parsed.hasOnboarded,
          'didCheckInOnce': parsed.didCheckInOnce,
        });
        return updated;
      }
    } catch (_) {}

    return state.settings;
  }

  Future<void> updateDaySettings(DaySettings newSettings, [String? uid]) async {
    await loadLocal();
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
        'hasOnboarded': newSettings.hasOnboarded,
        'didCheckInOnce': newSettings.didCheckInOnce,
        'sinkCompletedHabits': newSettings.sinkCompletedHabits,
        'rolloverTasks': newSettings.rolloverTasks,
        'streakSounds': newSettings.streakSounds,
        'reminders': newSettings.reminders,
        'morningReminderEnabled': newSettings.morningReminderEnabled,
        'morningReminderTime': newSettings.morningReminderTime,
        'nightReminderEnabled': newSettings.nightReminderEnabled,
        'nightReminderTime': newSettings.nightReminderTime,
        'progressRange': newSettings.progressRange,
      });
      await _syncNotifications(newSettings);
      emit(state.copyWith(update: state.update.toSuccess()));
    } on Fault catch (f) {
      emit(state.copyWith(update: state.update.toFailed(fault: f)));
    } catch (e, s) {
      emit(state.copyWith(
        update: state.update.toFailed(fault: Fault.fromObjectAndStackTrace(e, s)),
      ));
    }
  }

  Future<void> setDayEndHour(int hour, [String? uid]) async {
    final updated = state.settings.copyWith(dayEndHour: hour.clamp(0, 23));
    await updateDaySettings(updated, uid);
  }

  Future<void> setAtRiskWindowHours(int hours, [String? uid]) async {
    final updated = state.settings.copyWith(atRiskWindowHours: hours.clamp(1, 8));
    await updateDaySettings(updated, uid);
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

  Future<void> toggleMorningReminder(bool val) async {
    final updated = state.settings.copyWith(morningReminderEnabled: val);
    await updateDaySettings(updated);
  }

  Future<void> setMorningReminderTime(String timeStr) async {
    final updated = state.settings.copyWith(morningReminderTime: timeStr);
    await updateDaySettings(updated);
  }

  Future<void> toggleNightReminder(bool val) async {
    final updated = state.settings.copyWith(nightReminderEnabled: val);
    await updateDaySettings(updated);
  }

  Future<void> setNightReminderTime(String timeStr) async {
    final updated = state.settings.copyWith(nightReminderTime: timeStr);
    await updateDaySettings(updated);
  }

  Future<void> setProgressRange(String rangeKey) async {
    final updated = state.settings.copyWith(progressRange: rangeKey);
    await updateDaySettings(updated);
  }

  Future<void> _syncNotifications(DaySettings settings) async {
    try {
      await LocalNotificationService.ins.rescheduleDailyReminders(
        morningEnabled: settings.morningReminderEnabled,
        morningTime: settings.morningReminderTime,
        nightEnabled: settings.nightReminderEnabled,
        nightTime: settings.nightReminderTime,
      );
    } catch (_) {}
  }

  Future<void> completeOnboarding({
    bool enableReminders = false,
    String? uid,
  }) async {
    final updated = state.settings.copyWith(
      hasOnboarded: true,
      reminders: enableReminders ? true : state.settings.reminders,
      morningReminderEnabled:
          enableReminders ? true : state.settings.morningReminderEnabled,
      nightReminderEnabled:
          enableReminders ? true : state.settings.nightReminderEnabled,
    );
    await updateDaySettings(updated, uid);
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
