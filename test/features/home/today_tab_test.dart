import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/widgets/focus_list_card.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_check_button.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_reorder_sheet.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_row_card.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/today_hero_card.dart';
import 'package:unbroken_mobile/features/core/home/views/home/home.dart';
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

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) => Stream.value({
        'dayEndHour': 3,
        'atRiskWindowHours': 4,
        'habitOrder': ['h_1', 'h_2'],
        'weekStartMonday': false,
        'hasOnboarded': true,
        'didCheckInOnce': true,
      });

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async => {
        'hasOnboarded': true,
        'didCheckInOnce': true,
      };

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {}
}

class _FakeHabitsRepo extends HabitsRepo {
  _FakeHabitsRepo() : super.test();

  final List<Map<String, dynamic>> habits = [
    {
      'id': 'h_1',
      'name': 'Meditate',
      'emoji': '🧘',
      'colorHex': '#E2603A',
      'sortOrder': 0,
      'isArchived': false,
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    },
    {
      'id': 'h_2',
      'name': 'Workout',
      'emoji': '🏋️',
      'colorHex': '#4FA96A',
      'sortOrder': 1,
      'isArchived': false,
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    },
  ];
  final List<Map<String, dynamic>> entries = [];
  List<String>? lastReorderedIds;
  final _habitsCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _entriesCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();

  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) {
    scheduleMicrotask(() => _habitsCtrl.add(List.from(habits)));
    return _habitsCtrl.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) {
    scheduleMicrotask(() => _entriesCtrl.add(List.from(entries)));
    return _entriesCtrl.stream;
  }

  @override
  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    entries.add({
      'id': '${habitId}_$logicalDayKey',
      'habitId': habitId,
      'logicalDayKey': logicalDayKey,
      'source': 'mobile',
      'platform': 'ios',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _entriesCtrl.add(List.from(entries));
  }

  @override
  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    entries.removeWhere(
      (e) => e['habitId'] == habitId && e['logicalDayKey'] == logicalDayKey,
    );
    _entriesCtrl.add(List.from(entries));
  }

  @override
  Future<void> reorderHabits(String uid, List<String> habitOrder) async {
    lastReorderedIds = List.from(habitOrder);
  }

  void dispose() {
    _habitsCtrl.close();
    _entriesCtrl.close();
  }
}

class _FakeFocusRepo extends FocusRepo {
  _FakeFocusRepo() : super.test();

  final List<Map<String, dynamic>> docs = [];
  final _ctrl = StreamController<List<Map<String, dynamic>>>.broadcast();

  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    scheduleMicrotask(() => _ctrl.add(List.from(docs)));
    return _ctrl.stream;
  }

  @override
  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) async {
    docs.removeWhere((d) => d['logicalDayKey'] == logicalDayKey);
    docs.add(Map.from(focusData));
    _ctrl.add(List.from(docs));
  }

  @override
  Future<void> deleteFocus(String uid, String logicalDayKey) async {
    docs.removeWhere((d) => d['logicalDayKey'] == logicalDayKey);
    _ctrl.add(List.from(docs));
  }

  void dispose() => _ctrl.close();
}

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();

  @override
  Stream<List<Map<String, dynamic>>> observeFolders(String uid) => Stream.value([
        {
          'id': 'gf_1',
          'name': 'This Week',
          'cadence': 'weekly',
          'emoji': '📅',
          'colorHex': '#E2603A',
          'sortOrder': 0,
          'isArchived': false,
          'createdAt': DateTime(2026, 11, 20).toIso8601String(),
        },
      ]);

  @override
  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) =>
      Stream.value([
        {
          'id': 'g_1',
          'folderId': 'gf_1',
          'title': 'Ship Today Screen',
          'isCompleted': false,
          'sortOrder': 0,
          'createdAt': DateTime(2026, 11, 20).toIso8601String(),
        },
      ]);
}

void main() {
  testWidgets(
      'Today tab displays unified momentum hero, Focus submit & undo, From Goals pull, and habit reorder',
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
          scaffoldMessengerKey: scaffoldMessengerKey,
          onGenerateRoute: onGenerateRoutes,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Logical date header + TodayHeroCard 0%
    final logicalToday = settingsCubit.state.settings.logicalDay(DateTime.now());
    final expectedDate =
        DateFormat('EEEE, MMM d').format(logicalToday).toUpperCase();
    expect(find.text(expectedDate), findsOneWidget);
    expect(find.byType(TodayHeroCard), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('🔥 0/2 habits'), findsOneWidget);

    // 2. Add task via visible submit arrow, delete, and Undo restore
    final addField = find.widgetWithText(TextField, 'Add a task…');
    await tester.enterText(addField, 'Temporary Task');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Temporary Task'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('Temporary Task'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Temporary Task'), findsOneWidget);
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // Delete Temporary Task cleanly before From Goals test
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // 3. Pull goal into Today's Focus via From Goals sheet
    await tester.tap(find.text('From Goals'));
    await tester.pumpAndSettle();
    expect(find.text('Pull from Goals'), findsOneWidget);

    await tester.tap(find.text('+ Add'));
    await tester.pumpAndSettle();
    expect(find.text('In Today ✓'), findsOneWidget);

    Navigator.of(tester.element(find.text('Pull from Goals'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Ship Today Screen'), findsOneWidget);
    expect(find.text('✓ 0/1 tasks'), findsOneWidget);

    // 4. Complete task + both habits => 100% Unbroken day
    final focusCheckbox = find
        .descendant(
          of: find.byType(FocusListCard),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    await tester.tap(focusCheckbox);
    await tester.pumpAndSettle();
    expect(find.text('✨ Unbroken day locked in!'), findsNothing);

    final verticalScrollable = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    for (final name in ['Meditate', 'Workout']) {
      await tester.scrollUntilVisible(
        find.text(name),
        150,
        scrollable: verticalScrollable,
      );
      await tester.pumpAndSettle();
      final checkBtn = find.descendant(
        of: find.ancestor(
          of: find.text(name),
          matching: find.byType(HabitRowCard),
        ),
        matching: find.byType(FlameCheckButton),
      );
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(
      find.text(expectedDate),
      -150,
      scrollable: verticalScrollable,
    );
    await tester.ensureVisible(find.text(expectedDate));
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('✨ Unbroken day locked in!'), findsOneWidget);
    expect(find.text("You're unbroken today"), findsOneWidget);

    // 5. Open HabitReorderSheet & save order
    await tester.scrollUntilVisible(
      find.text('Order'),
      150,
      scrollable: verticalScrollable,
    );
    await tester.ensureVisible(find.text('Order'));
    await tester.tap(find.text('Order'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitReorderSheet), findsOneWidget);

    await tester.tap(find.text('Save Order'));
    await tester.pumpAndSettle();
    expect(habitsRepo.lastReorderedIds, ['h_1', 'h_2']);

    await authCubit.close();
    await settingsCubit.close();
    await habitsCubit.close();
    await focusCubit.close();
    await goalsCubit.close();
    habitsRepo.dispose();
    focusRepo.dispose();
  });
}
