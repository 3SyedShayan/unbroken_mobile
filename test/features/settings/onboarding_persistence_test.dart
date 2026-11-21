import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/splash/views/splash/splash.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/routes.dart';

class _FakeSettingsRepo extends SettingsRepo {
  _FakeSettingsRepo({Map<String, dynamic>? initialLocal}) : super.test() {
    if (initialLocal != null) {
      localStore.addAll(initialLocal);
    }
  }

  Map<String, dynamic> localStore = {
    'hasOnboarded': false,
    'didCheckInOnce': false,
    'sinkCompletedHabits': true,
    'rolloverTasks': false,
    'streakSounds': true,
    'reminders': false,
    'morningReminderEnabled': false,
    'morningReminderTime': '09:00',
    'nightReminderEnabled': false,
    'nightReminderTime': '21:00',
  };

  Map<String, dynamic>? remoteStore;
  final StreamController<Map<String, dynamic>?> _controller =
      StreamController<Map<String, dynamic>?>.broadcast();

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async =>
      Map<String, dynamic>.from(localStore);

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {
    localStore.addAll(prefs);
  }

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) => _controller.stream;

  @override
  Future<Map<String, dynamic>?> getSettings(String uid) async => remoteStore;

  @override
  Future<void> updateSettings(
      String uid, Map<String, dynamic> settingsData) async {
    remoteStore = Map<String, dynamic>.from(settingsData);
    _controller.add(remoteStore);
  }

  @override
  Future<void> clearLocalPreferences() async {
    localStore.remove('hasOnboarded');
    localStore.remove('didCheckInOnce');
  }

  void dispose() {
    _controller.close();
  }
}

class _FakeAuthRepo extends AuthRepo {
  _FakeAuthRepo({Map<String, dynamic>? user})
      : _currentUser = user,
        super.test();

  final Map<String, dynamic>? _currentUser;

  @override
  Map<String, dynamic>? get currentUser => _currentUser;

  @override
  Stream<Map<String, dynamic>?> authStateChanges() =>
      Stream.value(_currentUser);
}

class _FakeHabitsRepo extends HabitsRepo {
  _FakeHabitsRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) =>
      const Stream.empty();
  @override
  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) =>
      const Stream.empty();
}

class _FakeFocusRepo extends FocusRepo {
  _FakeFocusRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) =>
      const Stream.empty();
}

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeFolders(String uid) =>
      const Stream.empty();
  @override
  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) =>
      const Stream.empty();
}

void main() {
  group('SettingsCubit Onboarding State & Persistence', () {
    test('loads hasOnboarded: true from local preferences on startup', () async {
      final repo = _FakeSettingsRepo(initialLocal: {'hasOnboarded': true});
      final cubit = SettingsCubit(repo: repo);

      await cubit.loadLocal();

      expect(cubit.state.settings.hasOnboarded, isTrue);
      cubit.close();
      repo.dispose();
    });

    test('completeOnboarding updates state, remote settings, and local prefs',
        () async {
      final repo = _FakeSettingsRepo();
      final cubit = SettingsCubit(repo: repo);

      expect(cubit.state.settings.hasOnboarded, isFalse);
      expect(repo.localStore['hasOnboarded'], isFalse);

      await cubit.completeOnboarding(enableReminders: true, uid: 'user_123');

      expect(cubit.state.settings.hasOnboarded, isTrue);
      expect(cubit.state.settings.reminders, isTrue);
      expect(cubit.state.settings.morningReminderEnabled, isTrue);
      expect(cubit.state.settings.nightReminderEnabled, isTrue);
      expect(repo.localStore['hasOnboarded'], isTrue);
      expect(repo.localStore['reminders'], isTrue);
      expect(repo.remoteStore?['hasOnboarded'], isTrue);

      cubit.close();
      repo.dispose();
    });

    test('startObserving fetches remote hasOnboarded and syncs to local store',
        () async {
      final repo = _FakeSettingsRepo();
      repo.remoteStore = {
        'dayEndHour': 3,
        'atRiskWindowHours': 4,
        'hasOnboarded': true,
        'didCheckInOnce': true,
        'habitOrder': <String>[],
        'weekStartMonday': false,
      };

      final cubit = SettingsCubit(repo: repo);
      expect(cubit.state.settings.hasOnboarded, isFalse);

      final settings = await cubit.startObserving('user_123');

      expect(settings.hasOnboarded, isTrue);
      expect(cubit.state.settings.hasOnboarded, isTrue);
      expect(repo.localStore['hasOnboarded'], isTrue);

      cubit.close();
      repo.dispose();
    });
  });

  group('SplashScreen Navigation Routing Flow', () {
    late _FakeHabitsRepo habitsRepo;
    late _FakeFocusRepo focusRepo;
    late _FakeGoalsRepo goalsRepo;

    setUp(() {
      habitsRepo = _FakeHabitsRepo();
      focusRepo = _FakeFocusRepo();
      goalsRepo = _FakeGoalsRepo();
    });

    Widget buildTestApp({
      required AuthRepo authRepo,
      required SettingsRepo settingsRepo,
      required NavigatorObserver observer,
    }) {
      return MultiProvider(
        providers: [
          Provider<AuthCubit>(create: (_) => AuthCubit(repo: authRepo)),
          Provider<SettingsCubit>(
              create: (_) => SettingsCubit(repo: settingsRepo)),
          Provider<HabitsCubit>(create: (_) => HabitsCubit(repo: habitsRepo)),
          Provider<FocusCubit>(create: (_) => FocusCubit(repo: focusRepo)),
          Provider<GoalsCubit>(create: (_) => GoalsCubit(repo: goalsRepo)),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
            AppRoutes.onboarding: (_) =>
                const Scaffold(body: Text('Onboarding Screen')),
            AppRoutes.login: (_) =>
                const Scaffold(body: Text('Login Screen')),
          },
          initialRoute: AppRoutes.splash,
        ),
      );
    }

    testWidgets(
        'already onboarded user opens app 2nd/3rd time -> navigates to Home',
        (tester) async {
      final settingsRepo =
          _FakeSettingsRepo(initialLocal: {'hasOnboarded': true});
      final authRepo = _FakeAuthRepo(user: {
        'uid': 'user_test',
        'email': 'user@test.com',
        'displayName': 'Test User',
      });
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(buildTestApp(
        authRepo: authRepo,
        settingsRepo: settingsRepo,
        observer: observer,
      ));

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Onboarding Screen'), findsNothing);

      settingsRepo.dispose();
    });

    testWidgets(
        'authenticated user who has NOT onboarded -> navigates to Onboarding',
        (tester) async {
      final settingsRepo =
          _FakeSettingsRepo(initialLocal: {'hasOnboarded': false});
      final authRepo = _FakeAuthRepo(user: {
        'uid': 'user_new',
        'email': 'new@test.com',
        'displayName': 'New User',
      });
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(buildTestApp(
        authRepo: authRepo,
        settingsRepo: settingsRepo,
        observer: observer,
      ));

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding Screen'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);

      settingsRepo.dispose();
    });

    testWidgets('unauthenticated user -> navigates to Login', (tester) async {
      final settingsRepo = _FakeSettingsRepo();
      final authRepo = _FakeAuthRepo(user: null);
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(buildTestApp(
        authRepo: authRepo,
        settingsRepo: settingsRepo,
        observer: observer,
      ));

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);

      settingsRepo.dispose();
    });
  });
}

class _MockNavigatorObserver extends NavigatorObserver {}
