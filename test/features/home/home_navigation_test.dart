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
import 'package:unbroken_mobile/features/core/home/views/home/home.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';

class _FakeAuthRepo extends AuthRepo {
  _FakeAuthRepo() : super.test();
  @override
  Map<String, dynamic>? get currentUser => {
        'uid': 'test_user',
        'email': 'test@example.com',
      };
  @override
  Stream<Map<String, dynamic>?> authStateChanges() =>
      Stream.value({'uid': 'test_user', 'email': 'test@example.com'});
}

class _FakeSettingsRepo extends SettingsRepo {
  _FakeSettingsRepo() : super.test();
  @override
  Stream<Map<String, dynamic>> observeSettings(String uid) =>
      const Stream.empty();
}

class _FakeHabitsRepo extends HabitsRepo {
  _FakeHabitsRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) =>
      const Stream.empty();
  @override
  Stream<List<Map<String, dynamic>>> observeEntries(String uid,
          {String? windowStartKey}) =>
      const Stream.empty();
}

class _FakeFocusRepo extends FocusRepo {
  _FakeFocusRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeFocus(String uid,
          {String? windowStartKey}) =>
      const Stream.empty();
}

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();
  @override
  Stream<List<Map<String, dynamic>>> observeFolders(String uid) =>
      const Stream.empty();
  @override
  Stream<List<Map<String, dynamic>>> observeGoals(String uid,
          {String? folderId}) =>
      const Stream.empty();
}

void main() {
  testWidgets('Tapping Goals tab switches IndexedStack to GoalsTab',
      (tester) async {
    final authRepo = _FakeAuthRepo();
    final settingsRepo = _FakeSettingsRepo();
    final habitsRepo = _FakeHabitsRepo();
    final focusRepo = _FakeFocusRepo();
    final goalsRepo = _FakeGoalsRepo();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(repo: authRepo)),
          BlocProvider<SettingsCubit>(
              create: (_) => SettingsCubit(repo: settingsRepo)),
          BlocProvider<HabitsCubit>(
              create: (_) => HabitsCubit(repo: habitsRepo)),
          BlocProvider<FocusCubit>(create: (_) => FocusCubit(repo: focusRepo)),
          BlocProvider<GoalsCubit>(create: (_) => GoalsCubit(repo: goalsRepo)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initially on Today (Dashboard)
    expect(find.text('No Goal Folders Yet'), findsNothing);

    // Tap on Goals tab
    final goalsTabFinder = find.text('Goals');
    expect(goalsTabFinder, findsOneWidget);

    await tester.tap(goalsTabFinder);
    await tester.pumpAndSettle();

    // Verify Goals tab is now visible
    expect(find.text('No Goal Folders Yet'), findsOneWidget);

    // Tap on Progress tab
    final progressTabFinder = find.text('Progress');
    expect(progressTabFinder, findsOneWidget);

    await tester.tap(progressTabFinder);
    await tester.pumpAndSettle();

    // Verify Progress tab is now visible
    expect(find.text('Your Progress Starts Today'), findsOneWidget);
  });
}
