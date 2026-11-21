import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  static GoalsCubit c(BuildContext context, [bool listen = false]) =>
      BlocProvider.of<GoalsCubit>(context, listen: listen);

  final GoalsRepo _repo;
  StreamSubscription<List<Map<String, dynamic>>>? _foldersSub;
  StreamSubscription<List<Map<String, dynamic>>>? _goalsSub;
  String? _currentUid;

  GoalsCubit({GoalsRepo? repo})
      : _repo = repo ?? GoalsRepo.ins,
        super(GoalsState(
          fetch: BlocState<List<GoalFolder>>(),
          action: BlocState<void>(),
        )) {
    SignOutCleanupRegistry.ins.register(_clearOnSignOut);
  }

  void _clearOnSignOut() {
    _foldersSub?.cancel();
    _goalsSub?.cancel();
    _foldersSub = null;
    _goalsSub = null;
    _currentUid = null;
    emit(GoalsState(
      fetch: BlocState<List<GoalFolder>>(),
      action: BlocState<void>(),
    ));
  }

  void onAppResumed() {
    if (_currentUid != null) {
      startObserving(_currentUid!);
    }
  }

  void selectFolder(String folderId) {
    emit(state.copyWith(selectedFolderId: folderId));
  }

  void startObserving(String uid) {
    if (_currentUid == uid && _foldersSub != null) return;
    _currentUid = uid;

    _foldersSub?.cancel();
    _goalsSub?.cancel();

    emit(state.copyWith(fetch: state.fetch.toLoading()));

    _foldersSub = _repo.observeFolders(uid).listen(
      (rawList) {
        final folders = <GoalFolder>[];
        for (final m in rawList) {
          try {
            folders.add(GoalFolder.fromJson(m));
          } catch (e, s) {
            'Failed to parse goal folder (${m['id']}): $e'.appLog(
              tag: 'GOALS',
              level: AppLogLevel.error,
              error: e,
              stackTrace: s,
            );
          }
        }
        emit(state.copyWith(
          folders: folders,
          fetch: state.fetch.toSuccess(data: folders),
        ));
      },
      onError: (Object e, StackTrace s) {
        'Error in observeFolders: $e'.appLog(
          tag: 'GOALS',
          level: AppLogLevel.error,
          error: e,
          stackTrace: s,
        );
        emit(state.copyWith(
          fetch: state.fetch.toFailed(
            fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
          ),
        ));
      },
    );

    _goalsSub = _repo.observeGoals(uid).listen(
      (rawList) {
        final goals = <Goal>[];
        for (final m in rawList) {
          try {
            goals.add(Goal.fromJson(m));
          } catch (e, s) {
            'Failed to parse goal (${m['id']}): $e'.appLog(
              tag: 'GOALS',
              level: AppLogLevel.error,
              error: e,
              stackTrace: s,
            );
          }
        }
        emit(state.copyWith(goals: goals));
      },
      onError: (Object e, StackTrace s) {
        'Error in observeGoals: $e'.appLog(
          tag: 'GOALS',
          level: AppLogLevel.error,
          error: e,
          stackTrace: s,
        );
      },
    );
  }

  Future<void> createFolder({
    required String name,
    required GoalCadence cadence,
    String? emoji,
    String? colorHex,
    String? periodKey,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;

    final folderId =
        'gf_${DateTime.now().microsecondsSinceEpoch}_${name.replaceAll(RegExp(r'\s+'), '_').toLowerCase()}';
    final cleanEmoji = (emoji ?? '').trim().isNotEmpty
        ? emoji!.trim()
        : cadence.defaultEmoji;
    final cleanColor = (colorHex ?? '').trim().isNotEmpty
        ? colorHex!.trim()
        : '#E07A5F';

    final folder = GoalFolder(
      id: folderId,
      name: name.trim(),
      cadence: cadence,
      emoji: cleanEmoji,
      colorHex: cleanColor,
      sortOrder: state.folders.length,
      periodKey: periodKey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(action: state.action.toLoading()));
    try {
      await _repo.upsertFolder(uid, folder.toJson());
      emit(state.copyWith(
        selectedFolderId: folderId,
        action: state.action.toSuccess(),
      ));
    } catch (e, s) {
      'Failed to create goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> updateFolder(GoalFolder folder) async {
    final uid = _currentUid;
    if (uid == null) return;

    emit(state.copyWith(action: state.action.toLoading()));
    try {
      final updated = folder.copyWith(updatedAt: DateTime.now());
      await _repo.upsertFolder(uid, updated.toJson());
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to update goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final uid = _currentUid;
    if (uid == null) return;

    emit(state.copyWith(action: state.action.toLoading()));
    try {
      await _repo.deleteFolder(uid, folderId);
      final remaining = state.folders.where((f) => f.id != folderId).toList();
      emit(state.copyWith(
        selectedFolderId: remaining.firstOrNull?.id,
        action: state.action.toSuccess(),
      ));
    } catch (e, s) {
      'Failed to delete goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> addGoal({
    required String folderId,
    required String title,
    String? notes,
    String? targetDateKey,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;

    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final goalId = 'g_${DateTime.now().microsecondsSinceEpoch}';
    final existingGoals = state.goalsForFolder(folderId);

    final goal = Goal(
      id: goalId,
      folderId: folderId,
      title: trimmed,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      targetDateKey: targetDateKey,
      sortOrder: existingGoals.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _repo.upsertGoal(uid, goal.toJson());
    } catch (e, s) {
      'Failed to add goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> toggleGoal(Goal goal) async {
    final uid = _currentUid;
    if (uid == null) return;

    final newStatus = !goal.isCompleted;
    final updated = goal.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    try {
      await _repo.upsertGoal(uid, updated.toJson());
    } catch (e, s) {
      'Failed to toggle goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> updateGoalTitle(Goal goal, String newTitle) async {
    final uid = _currentUid;
    if (uid == null) return;

    final trimmed = newTitle.trim();
    if (trimmed.isEmpty || trimmed == goal.title) return;

    final updated = goal.copyWith(
      title: trimmed,
      updatedAt: DateTime.now(),
    );

    try {
      await _repo.upsertGoal(uid, updated.toJson());
    } catch (e, s) {
      'Failed to update goal title: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      await _repo.deleteGoal(uid, goalId);
    } catch (e, s) {
      'Failed to delete goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> close() {
    _foldersSub?.cancel();
    _goalsSub?.cancel();
    return super.close();
  }
}
