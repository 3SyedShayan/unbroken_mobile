import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/views/detail/detail.dart';
import 'package:unbroken_mobile/features/core/home/views/home/home.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';
import 'package:unbroken_mobile/router/router.dart';

class _FakeAuthRepo extends AuthRepo {
  _FakeAuthRepo() : super.test();

  @override
  Map<String, dynamic>? get currentUser => {
        'uid': 'u1',
        'email': 'u1@example.com',
      };

  @override
  Stream<Map<String, dynamic>?> authStateChanges() =>
      Stream.value({'uid': 'u1', 'email': 'u1@example.com'});
}

class _FakeSettingsRepo extends SettingsRepo {
  _FakeSettingsRepo() : super.test();

  final Map<String, dynamic> localStore = {
    'hasOnboarded': true,
    'didCheckInOnce': true,
    'progressRange': '1m',
  };

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) => Stream.value({
        'dayEndHour': 3,
        'atRiskWindowHours': 4,
        'habitOrder': ['h_read', 'h_run'],
        'weekStartMonday': false,
        'hasOnboarded': true,
        'didCheckInOnce': true,
      });

  @override
  Future<Map<String, dynamic>?> getSettings(String uid) async => {
        'dayEndHour': 3,
        'atRiskWindowHours': 4,
        'habitOrder': ['h_read', 'h_run'],
        'weekStartMonday': false,
        'hasOnboarded': true,
        'didCheckInOnce': true,
      };

  @override
  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async =>
      Map<String, dynamic>.from(localStore);

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {
    localStore.addAll(prefs);
  }

  @override
  Future<void> clearLocalPreferences() async => localStore.clear();
}

class _FakeHabitsRepo extends HabitsRepo {
  _FakeHabitsRepo() : super.test();

  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) => Stream.value([
        {
          'id': 'h_run',
          'name': 'Morning Run',
          'emoji': '🏃',
          'colorHex': '#E2603A',
          'sortOrder': 0,
          'isArchived': false,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        },
        {
          'id': 'h_read',
          'name': 'Read Book',
          'emoji': '📖',
          'colorHex': '#3E7BC4',
          'sortOrder': 1,
          'isArchived': false,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        },
      ]);

  @override
  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) {
    final today = DaySettings().logicalDay(DateTime.now());
    final todayKey = DaySettings.dayKey(today);
    final yesterdayKey = DaySettings.dayKey(
      DateTime(today.year, today.month, today.day - 1),
    );
    return Stream.value([
      {
        'id': 'h_read_$todayKey',
        'habitId': 'h_read',
        'logicalDayKey': todayKey,
        'source': 'mobile',
        'platform': 'ios',
        'timestamp': DateTime.now().toIso8601String(),
      },
      {
        'id': 'h_run_$yesterdayKey',
        'habitId': 'h_run',
        'logicalDayKey': yesterdayKey,
        'source': 'mobile',
        'platform': 'ios',
        'timestamp': DateTime.now().toIso8601String(),
      },
    ]);
  }
}

class _FakeFocusRepo extends FocusRepo {
  _FakeFocusRepo() : super.test();

  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    final today = DaySettings().logicalDay(DateTime.now());
    final todayKey = DaySettings.dayKey(today);
    return Stream.value([
      {
        'logicalDayKey': todayKey,
        'slots': {
          '0': {'id': 's0', 'text': 'SECRET_TASK_TITLE_XYZ', 'done': true},
          '1': {'id': 's1', 'text': 'ANOTHER_SECRET_TASK_123', 'done': false},
        },
      },
    ]);
  }
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
      Stream.value([
        {
          'id': 'g1',
          'folderId': 'f1',
          'title': 'Ship Redesign',
          'isCompleted': true,
          'completedAt': DateTime.now().toIso8601String(),
          'sortOrder': 0,
        },
      ]);
}

void main() {
  testWidgets(
      'Progress tab displays GitHub heatmaps without per-day task titles, switches range, and opens habit detail',
      (tester) async {
    final authRepo = _FakeAuthRepo();
    final settingsRepo = _FakeSettingsRepo();
    final habitsRepo = _FakeHabitsRepo();
    final focusRepo = _FakeFocusRepo();
    final goalsRepo = _FakeGoalsRepo();

    final authCubit = AuthCubit(repo: authRepo);
    final settingsCubit = SettingsCubit(repo: settingsRepo);
    final habitsCubit = HabitsCubit(repo: habitsRepo);
    final focusCubit = FocusCubit(repo: focusRepo);
    final goalsCubit = GoalsCubit(repo: goalsRepo);

    habitsCubit.startObserving('u1');
    focusCubit.startObserving('u1');
    goalsCubit.startObserving('u1');
    await settingsCubit.startObserving('u1');

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<HabitsCubit>.value(value: habitsCubit),
          BlocProvider<FocusCubit>.value(value: focusCubit),
          BlocProvider<GoalsCubit>.value(value: goalsCubit),
        ],
        child: MaterialApp(
          onGenerateRoute: onGenerateRoutes,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Progress tab
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('1M'), findsOneWidget);
    expect(find.text('3M'), findsOneWidget);
    expect(find.text('6M'), findsOneWidget);
    expect(find.text('Consistency'), findsOneWidget);
    expect(find.text('Unbroken days'), findsOneWidget);
    expect(find.text('Best run'), findsOneWidget);

    // Individual daily task names must never appear on Progress
    expect(
      find.textContaining('SECRET_TASK_TITLE_XYZ', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('ANOTHER_SECRET_TASK_123', findRichText: true),
      findsNothing,
    );

    // Switch hero filter to Tasks and tap today's cell number — still no task titles!
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    final today = DaySettings().logicalDay(DateTime.now());
    await tester.tap(find.text('${today.day}').first);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('SECRET_TASK_TITLE_XYZ', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('1/2 tasks', findRichText: true),
      findsOneWidget,
    );

    // Switch to 6M timeframe — expands cubit windows and persists setting locally
    await tester.tap(find.text('6M'));
    await tester.pumpAndSettle();
    expect(settingsCubit.state.settings.progressRange, '6m');
    expect(habitsCubit.observedWindowDays, greaterThanOrEqualTo(195));
    expect(focusCubit.observedWindowDays, greaterThanOrEqualTo(195));

    // Scroll down to habit cards and verify habitOrder places Read Book above Morning Run
    final verticalScrollable = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('Morning Run'),
      200,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();
    final readPos = tester.getTopLeft(find.text('Read Book'));
    final runPos = tester.getTopLeft(find.text('Morning Run'));
    expect(readPos.dy, lessThan(runPos.dy));

    // Tap habit card -> navigates to HabitDetailScreen (FlameHero has a repeating animation)
    await tester.ensureVisible(find.text('Read Book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(HabitDetailScreen), findsOneWidget);

    await authCubit.close();
    await settingsCubit.close();
    await habitsCubit.close();
    await focusCubit.close();
    await goalsCubit.close();
  });
}
