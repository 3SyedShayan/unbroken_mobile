import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';

class _FakeGoalsRepo extends GoalsRepo {
  _FakeGoalsRepo() : super.test();

  final List<Map<String, dynamic>> folders = [];
  final List<Map<String, dynamic>> goals = [];

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
  Future<void> upsertFolder(String uid, Map<String, dynamic> folderData) async {
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
  Future<void> upsertGoal(String uid, Map<String, dynamic> goalData) async {
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
    });
  });
}
