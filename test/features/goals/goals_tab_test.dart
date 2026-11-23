import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/auth/repositories/auth_repo.dart';
import 'package:unbroken_mobile/features/core/auth/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/widgets/goal_tile.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
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
  Stream<Map<String, dynamic>?> observeSettings(String uid) =>
      const Stream.empty();

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

  void dispose() => _ctrl.close();
}

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();

  final List<Map<String, dynamic>> folders = [];
  final List<Map<String, dynamic>> goals = [];
  final _foldersCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _goalsCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();

  @override
  Stream<List<Map<String, dynamic>>> observeFolders(String uid) {
    scheduleMicrotask(() => _foldersCtrl.add(List.from(folders)));
    return _foldersCtrl.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) {
    scheduleMicrotask(() => _goalsCtrl.add(List.from(goals)));
    return _goalsCtrl.stream;
  }

  @override
  Future<void> upsertFolder(
    String uid,
    Map<String, dynamic> folderData, {
    bool isUpdate = false,
  }) async {
    final idx = folders.indexWhere((f) => f['id'] == folderData['id']);
    if (idx >= 0) {
      folders[idx] = Map.from(folderData);
    } else {
      folders.add(Map.from(folderData));
    }
    _foldersCtrl.add(List.from(folders));
  }

  @override
  Future<void> deleteFolder(String uid, String folderId) async {
    folders.removeWhere((f) => f['id'] == folderId);
    goals.removeWhere((g) => g['folderId'] == folderId);
    _foldersCtrl.add(List.from(folders));
    _goalsCtrl.add(List.from(goals));
  }

  @override
  Future<void> upsertGoal(
    String uid,
    Map<String, dynamic> goalData, {
    bool isUpdate = false,
  }) async {
    final idx = goals.indexWhere((g) => g['id'] == goalData['id']);
    if (idx >= 0) {
      goals[idx] = Map.from(goalData);
    } else {
      goals.add(Map.from(goalData));
    }
    _goalsCtrl.add(List.from(goals));
  }

  @override
  Future<void> deleteGoal(String uid, String goalId) async {
    goals.removeWhere((g) => g['id'] == goalId);
    _goalsCtrl.add(List.from(goals));
  }

  void dispose() {
    _foldersCtrl.close();
    _goalsCtrl.close();
  }
}

void main() {
  testWidgets(
      'Goals tab supports quick-start, goal editing, smart Today sync, undo delete, and archiving',
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

    focusCubit.startObserving('u1');
    goalsCubit.startObserving('u1');

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

    // 1. Navigate to Goals tab -> empty state + quick start
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    expect(find.text('No Goal Folders Yet'), findsOneWidget);

    await tester.tap(find.text('📅 This Week'));
    await tester.pumpAndSettle();
    expect(goalsCubit.state.activeFolders.length, 1);
    expect(find.text('This Week'), findsWidgets);

    // 2. Quick-add a goal -> edit via GoalEditSheet
    final input = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText?.startsWith('Add a goal') ?? false),
    );
    await tester.enterText(input, 'Draft Q4 Spec');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Draft Q4 Spec'), findsOneWidget);

    await tester.tap(find.text('Draft Q4 Spec'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Goal'), findsOneWidget);

    final titleField = find.widgetWithText(TextField, 'Draft Q4 Spec');
    await tester.enterText(titleField, 'Ship Q4 Spec');
    final notesField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText == 'Add details, steps, or links...',
    );
    await tester.enterText(notesField, 'Include architecture diagram');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Ship Q4 Spec'), findsOneWidget);
    expect(find.text('Include architecture diagram'), findsOneWidget);

    // 3. Push to Today -> pill updates to In Today ✓
    await tester.tap(
      find.descendant(
        of: find.byType(GoalTile),
        matching: find.text('Today'),
      ).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('In Today ✓'), findsOneWidget);

    // 4. Fill Today's Focus to max 10 tasks and verify warning snackbar
    final settings = settingsCubit.state.settings;
    final now = DateTime.now();
    for (var i = 0; i < FocusCubit.maxTasks - 1; i++) {
      await focusCubit.addTask(text: 'Filler $i', asOf: now, settings: settings);
    }
    await tester.enterText(input, 'Extra Goal');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(GoalTile),
        matching: find.text('Today'),
      ).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text("Today's Focus is full (10/10). Clear a slot first."),
      findsOneWidget,
    );

    // Dismiss snackbar before swipe test
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // 5. Swipe-to-delete Extra Goal -> Undo restores it
    await tester.drag(find.text('Extra Goal'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Extra Goal'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Extra Goal'), findsOneWidget);

    // 6. Complete both goals -> collapsible Completed (2) + Archive Sprint + Restore
    await goalsCubit.toggleGoal(goalsCubit.state.goals[0]);
    await goalsCubit.toggleGoal(goalsCubit.state.goals[1]);
    await tester.pumpAndSettle();

    expect(find.text('Completed (2)'), findsOneWidget);
    expect(find.text('🎉 All goals achieved!'), findsOneWidget);
    expect(find.text('Archive Sprint'), findsOneWidget);

    await tester.tap(find.text('Completed (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Ship Q4 Spec'), findsOneWidget);

    await tester.tap(find.text('Archive Sprint'));
    await tester.pumpAndSettle();
    expect(goalsCubit.state.activeFolders, isEmpty);
    expect(goalsCubit.state.archivedFolders.length, 1);

    // Open Archived Folders sheet and restore
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Archived Folders'), findsOneWidget);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(goalsCubit.state.activeFolders.length, 1);
    expect(goalsCubit.state.archivedFolders, isEmpty);

    // Verify todayKey helper usage remains consistent
    expect(
      focusCubit.state.focusForDay(settings.logicalDayKey(now)).itemsList.length,
      FocusCubit.maxTasks,
    );

    await authCubit.close();
    await settingsCubit.close();
    await habitsCubit.close();
    await focusCubit.close();
    await goalsCubit.close();
    focusRepo.dispose();
    goalsRepo.dispose();
  });
}
