import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/focus/domain/focus_streak_calculator.dart';
import 'package:unbroken_mobile/features/core/focus/models/daily_focus.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/repositories/focus_repo.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class _MockFocusRepo extends FocusRepo {
  _MockFocusRepo() : super.test();

  final Map<String, Map<String, dynamic>> savedData = {};
  final Set<String> deletedKeys = {};

  @override
  Stream<List<Map<String, dynamic>>> observeFocus(
    String uid, {
    String? windowStartKey,
  }) {
    return Stream.value(savedData.values.toList());
  }

  @override
  Future<void> upsertFocus(
    String uid,
    String logicalDayKey,
    Map<String, dynamic> focusData,
  ) async {
    savedData[logicalDayKey] = Map<String, dynamic>.from(focusData);
    deletedKeys.remove(logicalDayKey);
  }

  @override
  Future<void> deleteFocus(String uid, String logicalDayKey) async {
    savedData.remove(logicalDayKey);
    deletedKeys.add(logicalDayKey);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyFocus Model', () {
    test('itemsList returns empty list when slots are empty (no dummy items)', () {
      const focus = DailyFocus(logicalDayKey: '2026-11-17');
      expect(focus.itemsList, isEmpty);
      expect(focus.isCleared, isFalse);
    });

    test('itemsList returns only non-empty tasks sorted by numeric slot key', () {
      const focus = DailyFocus(
        logicalDayKey: '2026-11-17',
        slots: {
          '2': FocusItem(id: 's2', text: 'Task 3', done: true),
          '0': FocusItem(id: 's0', text: 'Task 1', done: false),
          '1': FocusItem(id: 's1', text: '   ', done: false), // blank, ignored
          '3': FocusItem(id: 's3', text: 'Task 4', done: true),
        },
      );

      final items = focus.itemsList;
      expect(items.length, 3);
      expect(items[0].text, 'Task 1');
      expect(items[1].text, 'Task 3');
      expect(items[2].text, 'Task 4');
    });

    test('isCleared is true only when all non-empty tasks are done', () {
      const incompleteFocus = DailyFocus(
        logicalDayKey: '2026-11-17',
        slots: {
          '0': FocusItem(id: 's0', text: 'Task 1', done: true),
          '1': FocusItem(id: 's1', text: 'Task 2', done: false),
        },
      );
      expect(incompleteFocus.isCleared, isFalse);

      const completedFocus = DailyFocus(
        logicalDayKey: '2026-11-17',
        slots: {
          '0': FocusItem(id: 's0', text: 'Task 1', done: true),
          '1': FocusItem(id: 's1', text: 'Task 2', done: true),
        },
      );
      expect(completedFocus.isCleared, isTrue);
    });
  });

  group('FocusStreakCalculator', () {
    const settings = DaySettings(dayEndHour: 3);
    final now = DateTime(2026, 11, 17, 12, 0);

    test('calculates streak over consecutive cleared days', () {
      final list = [
        const DailyFocus(
          logicalDayKey: '2026-11-15',
          slots: {'0': FocusItem(id: 's0', text: 'Task', done: true)},
        ),
        const DailyFocus(
          logicalDayKey: '2026-11-16',
          slots: {'0': FocusItem(id: 's0', text: 'Task', done: true)},
        ),
        const DailyFocus(
          logicalDayKey: '2026-11-17',
          slots: {'0': FocusItem(id: 's0', text: 'Task', done: true)},
        ),
      ];

      final stats = FocusStreakCalculator.stats(
        focusList: list,
        asOf: now,
        settings: settings,
      );

      expect(stats.current, 3);
      expect(stats.best, 3);
    });

    test('retains grace when today is in progress but yesterday was cleared', () {
      final list = [
        const DailyFocus(
          logicalDayKey: '2026-11-16',
          slots: {'0': FocusItem(id: 's0', text: 'Task', done: true)},
        ),
        const DailyFocus(
          logicalDayKey: '2026-11-17',
          slots: {'0': FocusItem(id: 's0', text: 'Task', done: false)}, // in progress
        ),
      ];

      final stats = FocusStreakCalculator.stats(
        focusList: list,
        asOf: now,
        settings: settings,
      );

      expect(stats.current, 1); // Anchored on yesterday
    });
  });

  group('FocusCubit Operations', () {
    const settings = DaySettings(dayEndHour: 3);
    final asOf = DateTime(2026, 11, 17, 12, 0);
    late _MockFocusRepo repo;
    late FocusCubit cubit;

    setUp(() {
      repo = _MockFocusRepo();
      cubit = FocusCubit(repo: repo);
      cubit.startObserving('test_uid');
    });

    tearDown(() {
      cubit.close();
    });

    test('addTask adds tasks dynamically without overwriting slot 2', () async {
      await cubit.addTask(text: 'Task 1', asOf: asOf, settings: settings);
      await cubit.addTask(text: 'Task 2', asOf: asOf, settings: settings);
      await cubit.addTask(text: 'Task 3', asOf: asOf, settings: settings);
      await cubit.addTask(text: 'Task 4', asOf: asOf, settings: settings);

      final focus = cubit.state.focusForDay('2026-11-17');
      final items = focus.itemsList;

      expect(items.length, 4);
      expect(items[0].text, 'Task 1');
      expect(items[1].text, 'Task 2');
      expect(items[2].text, 'Task 3');
      expect(items[3].text, 'Task 4');
      expect(repo.savedData['2026-11-17'], isNotNull);
    });

    test('deleteTask removes task and shifts remaining items', () async {
      await cubit.addTask(text: 'Task A', asOf: asOf, settings: settings);
      await cubit.addTask(text: 'Task B', asOf: asOf, settings: settings);
      await cubit.addTask(text: 'Task C', asOf: asOf, settings: settings);

      // Delete Task B (index 1)
      await cubit.deleteTask(index: 1, asOf: asOf, settings: settings);

      final focus = cubit.state.focusForDay('2026-11-17');
      final items = focus.itemsList;

      expect(items.length, 2);
      expect(items[0].text, 'Task A');
      expect(items[1].text, 'Task C');
    });

    test('deleting all tasks deletes the Firestore document to avoid dummy empty history', () async {
      await cubit.addTask(text: 'Task A', asOf: asOf, settings: settings);
      expect(repo.savedData['2026-11-17'], isNotNull);

      await cubit.deleteTask(index: 0, asOf: asOf, settings: settings);

      final focus = cubit.state.focusForDay('2026-11-17');
      expect(focus.itemsList, isEmpty);
      expect(repo.savedData['2026-11-17'], isNull);
      expect(repo.deletedKeys.contains('2026-11-17'), isTrue);
    });

    test('toggleSlot updates task done status', () async {
      await cubit.addTask(text: 'Task 1', asOf: asOf, settings: settings);
      expect(cubit.state.focusForDay('2026-11-17').itemsList[0].done, isFalse);

      await cubit.toggleSlot(index: 0, asOf: asOf, settings: settings);
      expect(cubit.state.focusForDay('2026-11-17').itemsList[0].done, isTrue);

      await cubit.toggleSlot(index: 0, asOf: asOf, settings: settings);
      expect(cubit.state.focusForDay('2026-11-17').itemsList[0].done, isFalse);
    });

    test('dailyTaskResults excludes days with 0 tasks', () async {
      // Add a task for today
      await cubit.addTask(text: 'Task Today', asOf: asOf, settings: settings);

      // Daily task results should only include today
      final results = cubit.state.dailyTaskResults;
      expect(results.length, 1);
      expect(results.first.totalCount, 1);
      expect(results.first.dayKey, '2026-11-17');
    });
  });
}
