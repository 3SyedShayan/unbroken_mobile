import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/repositories/habits_repo.dart';
import 'package:unbroken_mobile/features/core/habits/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/habits/views/detail/detail.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/month_heatmap.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/features/support/settings/repositories/settings_repo.dart';
import 'package:unbroken_mobile/features/support/settings/viewmodel/cubit.dart';

class _FakeHabitsRepo extends HabitsRepo {
  final List<Map<String, dynamic>> initialHabits;
  final List<String> recordedKeys = [];
  final List<String> removedKeys = [];

  _FakeHabitsRepo({
    this.initialHabits = const [],
  }) : super.test();

  @override
  Stream<List<Map<String, dynamic>>> observeHabits(String uid) =>
      Stream.value(initialHabits);

  @override
  Stream<List<Map<String, dynamic>>> observeEntries(
    String uid, {
    String? windowStartKey,
  }) =>
      Stream.value(const []);

  @override
  Future<void> recordCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    recordedKeys.add(logicalDayKey);
  }

  @override
  Future<void> removeCheckIn(
    String uid, {
    required String habitId,
    required String logicalDayKey,
    Map<String, dynamic>? habitStatsUpdate,
  }) async {
    removedKeys.add(logicalDayKey);
  }
}

class _FakeSettingsRepo extends SettingsRepo {
  final DaySettings settings;

  _FakeSettingsRepo(this.settings) : super.test();

  @override
  Stream<Map<String, dynamic>?> observeSettings(String uid) =>
      Stream.value(settings.toJson());

  @override
  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>> loadLocalPreferences() async => {
        'hasOnboarded': true,
        'didCheckInOnce': true,
        'streakSounds': settings.streakSounds,
      };

  @override
  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) async {}

  @override
  Future<void> clearLocalPreferences() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testHabit = Habit(
    id: 'h_meditate',
    name: 'Meditate',
    emoji: '🧘',
    colorHex: '#E2603A',
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
  );

  group('HabitsState.isCompletedForDay', () {
    test(
      'matches exact logical calendar day without shifting by dayEndHour',
      () {
        final state = HabitsState(
          habits: [testHabit],
          entries: [
            Entry(
              id: 'h_meditate_2026-11-23',
              habitId: testHabit.id,
              logicalDayKey: '2026-11-23',
              timestamp: DateTime(2026, 11, 23, 22, 38),
            ),
          ],
          fetch: BlocState<List<Habit>>(),
          action: BlocState<void>(),
        );

        expect(
          state.isCompletedForDay(
            habit: testHabit,
            day: DateTime(2026, 11, 23),
          ),
          isTrue,
        );
        expect(
          state.isCompletedForDay(
            habit: testHabit,
            day: DateTime(2026, 11, 24),
          ),
          isFalse,
        );
        expect(
          state.isCompletedForDay(
            habit: testHabit,
            day: DateTime(2026, 11, 22),
          ),
          isFalse,
        );
      },
    );
  });

  group('HabitsCubit.toggleCheckInForDay', () {
    const settings = DaySettings(dayEndHour: 3, streakSounds: false);

    test(
      'records and removes exact logical calendar day without shifting backward',
      () async {
        final repo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
        final cubit = HabitsCubit(repo: repo);
        cubit.startObserving('u1');
        await Future<void>.delayed(Duration.zero);

        final now = DateTime(2026, 11, 23, 22, 38);
        final today = DateTime(2026, 11, 23);

        await cubit.toggleCheckInForDay(
          habit: testHabit,
          day: today,
          settings: settings,
          now: now,
        );

        expect(repo.recordedKeys, ['2026-11-23']);
        expect(
          cubit.state.isCompletedForDay(habit: testHabit, day: today),
          isTrue,
        );
        expect(
          cubit.state.isCompletedForDay(
            habit: testHabit,
            day: DateTime(2026, 11, 24),
          ),
          isFalse,
        );

        await cubit.toggleCheckInForDay(
          habit: testHabit,
          day: today,
          settings: settings,
          now: now,
        );

        expect(repo.removedKeys, ['2026-11-23']);
        expect(
          cubit.state.isCompletedForDay(habit: testHabit, day: today),
          isFalse,
        );

        await cubit.close();
      },
    );

    test('records exact past day when backfilling', () async {
      final repo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
      final cubit = HabitsCubit(repo: repo);
      cubit.startObserving('u1');
      await Future<void>.delayed(Duration.zero);

      final now = DateTime(2026, 11, 23, 22, 38);
      final pastDay = DateTime(2026, 11, 20);

      await cubit.toggleCheckInForDay(
        habit: testHabit,
        day: pastDay,
        settings: settings,
        now: now,
      );

      expect(repo.recordedKeys, ['2026-11-20']);
      expect(
        cubit.state.isCompletedForDay(habit: testHabit, day: pastDay),
        isTrue,
      );

      await cubit.close();
    });

    test('rejects future logical days relative to now', () async {
      final repo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
      final cubit = HabitsCubit(repo: repo);
      cubit.startObserving('u1');
      await Future<void>.delayed(Duration.zero);

      final now = DateTime(2026, 11, 23, 22, 38);
      final tomorrow = DateTime(2026, 11, 24);

      await cubit.toggleCheckInForDay(
        habit: testHabit,
        day: tomorrow,
        settings: settings,
        now: now,
      );

      expect(repo.recordedKeys, isEmpty);

      await cubit.close();
    });

    test(
      'after midnight before dayEndHour (01:30 AM), accepts logical today and rejects calendar today',
      () async {
        final repo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
        final cubit = HabitsCubit(repo: repo);
        cubit.startObserving('u1');
        await Future<void>.delayed(Duration.zero);

        final now = DateTime(2026, 11, 24, 1, 30);
        final logicalToday = DateTime(2026, 11, 23);
        final calendarTomorrow = DateTime(2026, 11, 24);

        await cubit.toggleCheckInForDay(
          habit: testHabit,
          day: logicalToday,
          settings: settings,
          now: now,
        );
        await cubit.toggleCheckInForDay(
          habit: testHabit,
          day: calendarTomorrow,
          settings: settings,
          now: now,
        );

        expect(repo.recordedKeys, ['2026-11-23']);
        expect(
          cubit.state.isCompletedForDay(habit: testHabit, day: logicalToday),
          isTrue,
        );
        expect(
          cubit.state.isCompletedForDay(
            habit: testHabit,
            day: calendarTomorrow,
          ),
          isFalse,
        );

        await cubit.close();
      },
    );
  });

  group('HabitDetailScreen Check-in Regression Widget Tests', () {
    Future<({HabitsCubit habitsCubit, SettingsCubit settingsCubit})>
        pumpDetailScreen(
      WidgetTester tester, {
      required _FakeHabitsRepo habitsRepo,
      required DaySettings settings,
    }) async {
      final settingsCubit = SettingsCubit(repo: _FakeSettingsRepo(settings));
      final habitsCubit = HabitsCubit(repo: habitsRepo);

      habitsCubit.startObserving('u1');
      await settingsCubit.startObserving('u1');

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<HabitsCubit>.value(value: habitsCubit),
          ],
          child: MaterialApp(home: HabitDetailScreen(habit: testHabit)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      return (habitsCubit: habitsCubit, settingsCubit: settingsCubit);
    }

    testWidgets(
      'tapping "Mark done today" checks today and NOT the next day in week row and month heatmap',
      (tester) async {
        const baseSettings = DaySettings(dayEndHour: 3, streakSounds: false);
        final today = baseSettings.logicalDay(DateTime.now());
        final tomorrow = DateTime(today.year, today.month, today.day + 1);
        final weekStartsMonday = today.weekday == DateTime.saturday;
        final settings = baseSettings.copyWith(
          weekStartMonday: weekStartsMonday,
        );

        final firstWeekday =
            weekStartsMonday ? DateTime.monday : DateTime.sunday;
        final rowOfToday = (today.weekday - firstWeekday + 7) % 7;

        final habitsRepo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
        final cubits = await pumpDetailScreen(
          tester,
          habitsRepo: habitsRepo,
          settings: settings,
        );

        expect(find.text('Mark done today'), findsOneWidget);

        final thisWeekColumn = find
            .ancestor(
              of: find.text('THIS WEEK'),
              matching: find.byType(Column),
            )
            .first;
        final weekRow = find
            .descendant(of: thisWeekColumn, matching: find.byType(Row))
            .first;
        final daySlots = find.descendant(
          of: weekRow,
          matching: find.byType(GestureDetector),
        );
        expect(daySlots, findsNWidgets(7));
        expect(
          find.descendant(of: weekRow, matching: find.byIcon(Icons.check)),
          findsNothing,
        );

        await tester.tap(find.text('Mark done today'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('✓ Done today'), findsOneWidget);
        expect(habitsRepo.recordedKeys, [DaySettings.dayKey(today)]);

        expect(
          find.descendant(of: weekRow, matching: find.byIcon(Icons.check)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: daySlots.at(rowOfToday),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: daySlots.at(rowOfToday + 1),
            matching: find.byIcon(Icons.check),
          ),
          findsNothing,
        );

        final verticalScrollable = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        );
        await tester.scrollUntilVisible(
          find.byType(MonthHeatmap),
          200,
          scrollable: verticalScrollable,
        );
        await tester.pump();

        final todayCellText = find.descendant(
          of: find.byType(MonthHeatmap),
          matching: find.text('${today.day}'),
        );
        final todayCellContainer = tester.widget<Container>(
          find
              .ancestor(of: todayCellText, matching: find.byType(Container))
              .first,
        );
        final todayDecoration =
            todayCellContainer.decoration! as BoxDecoration;
        expect(todayDecoration.color, testHabit.color);

        if (tomorrow.month == today.month) {
          final tomorrowCellText = find.descendant(
            of: find.byType(MonthHeatmap),
            matching: find.text('${tomorrow.day}'),
          );
          final tomorrowCellContainer = tester.widget<Container>(
            find
                .ancestor(
                  of: tomorrowCellText,
                  matching: find.byType(Container),
                )
                .first,
          );
          final tomorrowDecoration =
              tomorrowCellContainer.decoration! as BoxDecoration;
          expect(tomorrowDecoration.color, isNot(testHabit.color));
        }

        await cubits.habitsCubit.close();
        await cubits.settingsCubit.close();
      },
    );

    testWidgets(
      'tapping yesterday in THIS WEEK opens single confirmation dialog and backfills exact yesterday',
      (tester) async {
        const baseSettings = DaySettings(dayEndHour: 3, streakSounds: false);
        final today = baseSettings.logicalDay(DateTime.now());
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final weekStartsMonday = today.weekday != DateTime.monday;
        final settings = baseSettings.copyWith(
          weekStartMonday: weekStartsMonday,
        );

        final firstWeekday =
            weekStartsMonday ? DateTime.monday : DateTime.sunday;
        final rowOfToday = (today.weekday - firstWeekday + 7) % 7;

        final habitsRepo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
        final cubits = await pumpDetailScreen(
          tester,
          habitsRepo: habitsRepo,
          settings: settings,
        );

        final thisWeekColumn = find
            .ancestor(
              of: find.text('THIS WEEK'),
              matching: find.byType(Column),
            )
            .first;
        final weekRow = find
            .descendant(of: thisWeekColumn, matching: find.byType(Row))
            .first;
        final daySlots = find.descendant(
          of: weekRow,
          matching: find.byType(GestureDetector),
        );

        final verticalScrollable = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        );
        await tester.scrollUntilVisible(
          daySlots.at(rowOfToday - 1),
          100,
          scrollable: verticalScrollable,
        );
        await tester.pump();

        await tester.tap(daySlots.at(rowOfToday - 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Backfill Check-in?'), findsOneWidget);

        await tester.tap(find.text('Confirm'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(AlertDialog), findsNothing);
        expect(habitsRepo.recordedKeys, [DaySettings.dayKey(yesterday)]);
        expect(
          find.descendant(
            of: daySlots.at(rowOfToday - 1),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: daySlots.at(rowOfToday),
            matching: find.byIcon(Icons.check),
          ),
          findsNothing,
        );

        await cubits.habitsCubit.close();
        await cubits.settingsCubit.close();
      },
    );

    testWidgets(
      'tapping historical or today cell in MonthHeatmap shows at most one dialog and updates exact day',
      (tester) async {
        const settings = DaySettings(dayEndHour: 3, streakSounds: false);
        final today = settings.logicalDay(DateTime.now());
        final targetDay = today.day > 1
            ? DateTime(today.year, today.month, today.day - 1)
            : today;
        final isHistorical = today.day > 1;

        final habitsRepo = _FakeHabitsRepo(initialHabits: [testHabit.toJson()]);
        final cubits = await pumpDetailScreen(
          tester,
          habitsRepo: habitsRepo,
          settings: settings,
        );

        final verticalScrollable = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        );
        await tester.scrollUntilVisible(
          find.byType(MonthHeatmap),
          200,
          scrollable: verticalScrollable,
        );
        await tester.pump();

        final targetCellText = find.descendant(
          of: find.byType(MonthHeatmap),
          matching: find.text('${targetDay.day}'),
        );
        await tester.tap(targetCellText);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        if (isHistorical) {
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text('Backfill Check-in?'), findsOneWidget);

          await tester.tap(find.text('Confirm'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
        }

        expect(find.byType(AlertDialog), findsNothing);
        expect(habitsRepo.recordedKeys, [DaySettings.dayKey(targetDay)]);

        final targetCellContainer = tester.widget<Container>(
          find
              .ancestor(of: targetCellText, matching: find.byType(Container))
              .first,
        );
        final targetDecoration =
            targetCellContainer.decoration! as BoxDecoration;
        expect(targetDecoration.color, testHabit.color);

        await cubits.habitsCubit.close();
        await cubits.settingsCubit.close();
      },
    );
  });
}
