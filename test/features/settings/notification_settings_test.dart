import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';

class _FakeSettingsRepo extends SettingsRepo {
  _FakeSettingsRepo() : super.test();

  Map<String, dynamic> localStore = {
    'morningReminderEnabled': false,
    'morningReminderTime': '09:00',
    'nightReminderEnabled': false,
    'nightReminderTime': '21:00',
  };

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async => Map.from(localStore);

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {
    localStore.addAll(prefs);
  }

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) => const Stream.empty();

  @override
  Future<void> updateSettings(String uid, Map<String, dynamic> settingsData) async {}
}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('DaySettings Notification Fields', () {
    test('defaults to disabled reminders at 09:00 and 21:00', () {
      const settings = DaySettings();
      expect(settings.morningReminderEnabled, isFalse);
      expect(settings.morningReminderTime, equals('09:00'));
      expect(settings.nightReminderEnabled, isFalse);
      expect(settings.nightReminderTime, equals('21:00'));
    });

    test('serializes and deserializes notification settings correctly', () {
      const original = DaySettings(
        morningReminderEnabled: true,
        morningReminderTime: '08:30',
        nightReminderEnabled: true,
        nightReminderTime: '22:15',
      );

      final json = original.toJson();
      final recovered = DaySettings.fromJson(json);

      expect(recovered.morningReminderEnabled, isTrue);
      expect(recovered.morningReminderTime, equals('08:30'));
      expect(recovered.nightReminderEnabled, isTrue);
      expect(recovered.nightReminderTime, equals('22:15'));
    });
  });

  group('SettingsCubit Notification Operations', () {
    late _FakeSettingsRepo repo;
    late SettingsCubit cubit;

    setUp(() {
      repo = _FakeSettingsRepo();
      cubit = SettingsCubit(repo: repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('toggleMorningReminder updates state and persistence', () async {
      await cubit.toggleMorningReminder(true);
      expect(cubit.state.settings.morningReminderEnabled, isTrue);
      expect(repo.localStore['morningReminderEnabled'], isTrue);

      await cubit.toggleMorningReminder(false);
      expect(cubit.state.settings.morningReminderEnabled, isFalse);
      expect(repo.localStore['morningReminderEnabled'], isFalse);
    });

    test('setMorningReminderTime updates time in state and persistence', () async {
      await cubit.setMorningReminderTime('07:45');
      expect(cubit.state.settings.morningReminderTime, equals('07:45'));
      expect(repo.localStore['morningReminderTime'], equals('07:45'));
    });

    test('toggleNightReminder updates state and persistence', () async {
      await cubit.toggleNightReminder(true);
      expect(cubit.state.settings.nightReminderEnabled, isTrue);
      expect(repo.localStore['nightReminderEnabled'], isTrue);

      await cubit.toggleNightReminder(false);
      expect(cubit.state.settings.nightReminderEnabled, isFalse);
      expect(repo.localStore['nightReminderEnabled'], isFalse);
    });

    test('setNightReminderTime updates time in state and persistence', () async {
      await cubit.setNightReminderTime('20:30');
      expect(cubit.state.settings.nightReminderTime, equals('20:30'));
      expect(repo.localStore['nightReminderTime'], equals('20:30'));
    });
  });
}
