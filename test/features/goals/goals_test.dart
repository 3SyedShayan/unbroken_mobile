import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_period_helper.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();

  final List<Map<String, dynamic>> folders = [];
  final List<Map<String, dynamic>> goals = [];
  bool? lastFolderIsUpdate;
  bool? lastGoalIsUpdate;

  final _foldersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _goalsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  @override
  Stream<List<Map<String, dynamic>>> observeFolders(String uid) {
    scheduleMicrotask(() => _foldersController.add(List.from(folders)));
    return _foldersController.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> observeGoals(
    String uid, {
    String? folderId,
  }) {
    scheduleMicrotask(() {
      if (folderId != null) {
        _goalsController.add(
            goals.where((g) => g['folderId'] == folderId).toList());
      } else {
        _goalsController.add(List.from(goals));
      }
    });
    return _goalsController.stream;
  }

  @override
  Future<void> upsertFolder(
    String uid,
    Map<String, dynamic> folderData, {
    bool isUpdate = false,
  }) async {
    lastFolderIsUpdate = isUpdate;
    final idx = folders.indexWhere((f) => f['id'] == folderData['id']);
    if (idx >= 0) {
      folders[idx] = Map.from(folderData);
    } else {
      folders.add(Map.from(folderData));
    }
    _foldersController.add(List.from(folders));
  }

  @override
  Future<void> deleteFolder(String uid, String folderId) async {
    folders.removeWhere((f) => f['id'] == folderId);
    goals.removeWhere((g) => g['folderId'] == folderId);
    _foldersController.add(List.from(folders));
    _goalsController.add(List.from(goals));
  }

  @override
  Future<void> upsertGoal(
    String uid,
    Map<String, dynamic> goalData, {
    bool isUpdate = false,
  }) async {
    lastGoalIsUpdate = isUpdate;
    final idx = goals.indexWhere((g) => g['id'] == goalData['id']);
    if (idx >= 0) {
      goals[idx] = Map.from(goalData);
    } else {
      goals.add(Map.from(goalData));
    }
    _goalsController.add(List.from(goals));
  }

  @override
  Future<void> deleteGoal(String uid, String goalId) async {
    goals.removeWhere((g) => g['id'] == goalId);
    _goalsController.add(List.from(goals));
  }

  void dispose() {
    _foldersController.close();
    _goalsController.close();
  }
}

void main() {
  group('Goal Models & Cadence Serialization', () {
    test('GoalCadence provides expected labels and default emojis', () {
      expect(GoalCadence.weekly.label, 'Weekly');
      expect(GoalCadence.weekly.defaultEmoji, '📅');

      expect(GoalCadence.monthly.label, 'Monthly');
      expect(GoalCadence.monthly.defaultEmoji, '🗓️');

      expect(GoalCadence.weekend.label, 'Weekend');
      expect(GoalCadence.weekend.defaultEmoji, '🏖️');

      expect(GoalCadence.custom.label, 'Custom');
      expect(GoalCadence.custom.defaultEmoji, '🎯');
    });

    test('GoalFolder serializes and deserializes correctly', () {
      final folder = GoalFolder(
        id: 'gf_123',
        name: 'This Week',
        cadence: GoalCadence.weekly,
        emoji: '📅',
        colorHex: '#E2603A',
        sortOrder: 0,
        createdAt: DateTime(2026, 11, 21),
      );

      final json = folder.toJson();
      expect(json['id'], 'gf_123');
      expect(json['name'], 'This Week');
      expect(json['cadence'], 'weekly');

      final reconstructed = GoalFolder.fromJson(json);
      expect(reconstructed.id, folder.id);
      expect(reconstructed.name, folder.name);
      expect(reconstructed.cadence, GoalCadence.weekly);
    });

    test('Goal serializes and deserializes correctly', () {
      final goal = Goal(
        id: 'g_456',
        folderId: 'gf_123',
        title: 'Ship Goals Feature',
        isCompleted: false,
        createdAt: DateTime(2026, 11, 21),
      );

      final json = goal.toJson();
      expect(json['id'], 'g_456');
      expect(json['folderId'], 'gf_123');
      expect(json['title'], 'Ship Goals Feature');
      expect(json['isCompleted'], false);

      final reconstructed = Goal.fromJson(json);
      expect(reconstructed.id, goal.id);
      expect(reconstructed.title, goal.title);
      expect(reconstructed.isCompleted, isFalse);
    });
  });

  group('GoalsCubit Operations & Progress Calculation', () {
    late _FakeGoalsRepo repo;
    late GoalsCubit cubit;

    setUp(() {
      repo = _FakeGoalsRepo();
      cubit = GoalsCubit(repo: repo);
    });

    tearDown(() {
      cubit.close();
      repo.dispose();
    });

    test('starts observing and loads empty state initially', () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      expect(cubit.state.folders, isEmpty);
      expect(cubit.state.goals, isEmpty);
      expect(cubit.state.selectedFolder, isNull);
    });

    test('creates a folder and automatically selects it', () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(
        name: 'Weekly Sprint',
        cadence: GoalCadence.weekly,
        emoji: '📅',
        colorHex: '#E2603A',
      );
      await pumpEventQueue();

      expect(cubit.state.folders.length, 1);
      final folder = cubit.state.folders.first;
      expect(folder.name, 'Weekly Sprint');
      expect(folder.cadence, GoalCadence.weekly);
      expect(cubit.state.selectedFolder?.id, folder.id);
    });

    test('adds goals and computes folder & overall progress accurately', () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(
        name: 'Weekend Goals',
        cadence: GoalCadence.weekend,
      );
      await pumpEventQueue();
      final folderId = cubit.state.folders.first.id;

      await cubit.addGoal(
        folderId: folderId,
        title: 'Run 10km',
      );
      await cubit.addGoal(
        folderId: folderId,
        title: 'Read chapter 4',
      );
      await pumpEventQueue();

      expect(cubit.state.goals.length, 2);
      final initialProgress = cubit.state.folderProgress(folderId);
      expect(initialProgress.total, 2);
      expect(initialProgress.completed, 0);

      // Toggle first goal completed
      final firstGoal = cubit.state.goals.first;
      await cubit.toggleGoal(firstGoal);
      await pumpEventQueue();

      final updatedProgress = cubit.state.folderProgress(folderId);
      expect(updatedProgress.total, 2);
      expect(updatedProgress.completed, 1);

      final overall = cubit.state.overallProgress;
      expect(overall.total, 2);
      expect(overall.completed, 1);
    });

    test('deleting a folder cascades and deletes all contained goals', () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(
        name: 'Temp Folder',
        cadence: GoalCadence.custom,
      );
      await pumpEventQueue();
      final folderId = cubit.state.folders.first.id;

      await cubit.addGoal(
        folderId: folderId,
        title: 'Temp Goal 1',
      );
      await pumpEventQueue();
      expect(cubit.state.goals.length, 1);

      await cubit.deleteFolder(folderId);
      await pumpEventQueue();

      expect(cubit.state.folders, isEmpty);
      expect(cubit.state.goals, isEmpty);
      expect(cubit.state.selectedFolder, isNull);
      expect(cubit.state.selectedFolderId, isNull);
    });

    test('updateGoal modifies title, notes, targetDateKey and supports clearing',
        () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(
        name: 'Sprint',
        cadence: GoalCadence.weekly,
      );
      await pumpEventQueue();
      final folderId = cubit.state.folders.first.id;
      expect(repo.lastFolderIsUpdate, isFalse);

      await cubit.addGoal(folderId: folderId, title: 'Initial Title');
      await pumpEventQueue();
      final goal = cubit.state.goals.first;

      await cubit.updateGoal(
        goal,
        title: 'Updated Title',
        notes: 'Important note',
        targetDateKey: '2026-11-30',
      );
      await pumpEventQueue();

      expect(repo.lastGoalIsUpdate, isTrue);
      final updated = cubit.state.goals.first;
      expect(updated.title, 'Updated Title');
      expect(updated.notes, 'Important note');
      expect(updated.targetDateKey, '2026-11-30');

      await cubit.updateGoal(
        updated,
        clearNotes: true,
        clearTargetDate: true,
      );
      await pumpEventQueue();
      final cleared = cubit.state.goals.first;
      expect(cleared.notes, isNull);
      expect(cleared.targetDateKey, isNull);
    });

    test('archiveFolder and unarchiveFolder update lists and selectedFolder',
        () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(name: 'F1', cadence: GoalCadence.weekly);
      await cubit.createFolder(name: 'F2', cadence: GoalCadence.monthly);
      await pumpEventQueue();

      final f2 = cubit.state.folders.last;
      expect(cubit.state.selectedFolder?.id, f2.id);

      await cubit.archiveFolder(f2);
      await pumpEventQueue();
      expect(repo.lastFolderIsUpdate, isTrue);
      expect(cubit.state.activeFolders.length, 1);
      expect(cubit.state.archivedFolders.length, 1);
      expect(cubit.state.selectedFolder?.name, 'F1');

      await cubit.unarchiveFolder(cubit.state.archivedFolders.first);
      await pumpEventQueue();
      expect(cubit.state.activeFolders.length, 2);
      expect(cubit.state.archivedFolders, isEmpty);
      expect(cubit.state.selectedFolder?.name, 'F2');
    });

    test('deleteGoal and restoreGoal support undo workflow', () async {
      cubit.startObserving('user_1');
      await pumpEventQueue();

      await cubit.createFolder(name: 'F1', cadence: GoalCadence.custom);
      await pumpEventQueue();
      final folderId = cubit.state.folders.first.id;

      await cubit.addGoal(folderId: folderId, title: 'Undoable Goal');
      await pumpEventQueue();
      final goal = cubit.state.goals.first;

      await cubit.deleteGoal(goal.id);
      await pumpEventQueue();
      expect(cubit.state.goals, isEmpty);

      await cubit.restoreGoal(goal);
      await pumpEventQueue();
      expect(cubit.state.goals.length, 1);
      expect(cubit.state.goals.first.title, 'Undoable Goal');
    });
  });

  group('GoalPeriodHelper', () {
    test('generateFolderId clamps long names strictly under 64 characters', () {
      final longName = 'A very long folder name ' * 4;
      final id = GoalPeriodHelper.generateFolderId(
        name: '$longName !!! ###',
        now: DateTime(2026, 11, 23, 12, 0),
      );
      expect(id.length, lessThanOrEqualTo(64));
      expect(id.startsWith('gf_'), isTrue);
    });

    test('periodKeyFor formats weekly, monthly, weekend, and custom', () {
      final monday = DateTime(2026, 11, 23); // ISO W48
      expect(GoalPeriodHelper.periodKeyFor(GoalCadence.weekly, monday), '2026-W48');
      expect(GoalPeriodHelper.periodKeyFor(GoalCadence.monthly, monday), '2026-11');
      expect(
        GoalPeriodHelper.periodKeyFor(GoalCadence.weekend, monday),
        '2026-W48-WE',
      );
      expect(GoalPeriodHelper.periodKeyFor(GoalCadence.custom, monday), isNull);
    });

    test('cadenceCountdownLabel handles weekly, monthly, weekend, and custom', () {
      final monday = DateTime(2026, 11, 23);
      expect(
        GoalPeriodHelper.cadenceCountdownLabel(
          GoalCadence.weekly,
          monday,
          weekStartsMonday: true,
        ),
        '7d left this week',
      );
      expect(
        GoalPeriodHelper.cadenceCountdownLabel(
          GoalCadence.monthly,
          DateTime(2026, 11, 30),
        ),
        'Last day of Nov',
      );
      expect(
        GoalPeriodHelper.cadenceCountdownLabel(
          GoalCadence.weekend,
          DateTime(2026, 11, 28), // Saturday
        ),
        'This weekend',
      );
      expect(
        GoalPeriodHelper.cadenceCountdownLabel(GoalCadence.custom, monday),
        isNull,
      );
    });

    test('targetDateBadge computes urgency levels accurately', () {
      final today = DateTime(2026, 11, 23);

      final overdue = GoalPeriodHelper.targetDateBadge('2026-11-21', today)!;
      expect(overdue.label, 'Overdue 2d');
      expect(overdue.urgency, GoalDateUrgency.overdue);

      final dueToday = GoalPeriodHelper.targetDateBadge('2026-11-23', today)!;
      expect(dueToday.label, 'Due today');
      expect(dueToday.urgency, GoalDateUrgency.dueSoon);

      final tomorrow = GoalPeriodHelper.targetDateBadge('2026-11-24', today)!;
      expect(tomorrow.label, 'Tomorrow');
      expect(tomorrow.urgency, GoalDateUrgency.dueSoon);

      final soon = GoalPeriodHelper.targetDateBadge('2026-11-28', today)!;
      expect(soon.label, 'In 5d');
      expect(soon.urgency, GoalDateUrgency.normal);

      final later = GoalPeriodHelper.targetDateBadge('2026-12-15', today)!;
      expect(later.label, 'Dec 15');
      expect(later.urgency, GoalDateUrgency.normal);
    });
  });
}
