import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_period_helper.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/repositories/goals_repo.dart';
import 'package:unbroken_mobile/services/firebase/sync_status_tracker.dart';
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

  Future<void> _clearOnSignOut() async {
    await _foldersSub?.cancel();
    await _goalsSub?.cancel();
    _foldersSub = null;
    _goalsSub = null;
    _currentUid = null;
    if (!isClosed) {
      emit(GoalsState(
        fetch: BlocState<List<GoalFolder>>(),
        action: BlocState<void>(),
      ));
    }
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
        SyncStatusTracker.ins.reportError();
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
        SyncStatusTracker.ins.reportError();
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

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final folderId = GoalPeriodHelper.generateFolderId(name: trimmedName);
    final cleanEmoji = (emoji ?? '').trim().isNotEmpty
        ? emoji!.trim()
        : cadence.defaultEmoji;
    final cleanColor = (colorHex ?? '').trim().isNotEmpty
        ? colorHex!.trim()
        : HabitPalette.defaultColor;
    final now = DateTime.now();

    final folder = GoalFolder(
      id: folderId,
      name: trimmedName.length > 80 ? trimmedName.substring(0, 80) : trimmedName,
      cadence: cadence,
      emoji: cleanEmoji,
      colorHex: cleanColor,
      sortOrder: state.folders.length,
      periodKey: periodKey ?? GoalPeriodHelper.periodKeyFor(cadence, now),
      createdAt: now,
      updatedAt: now,
    );

    final prevFolders = state.folders;
    final prevSelected = state.selectedFolderId;
    emit(state.copyWith(
      folders: [...prevFolders, folder],
      selectedFolderId: folderId,
      action: state.action.toLoading(),
    ));

    try {
      await _repo.upsertFolder(uid, folder.toJson(), isUpdate: false);
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to create goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        folders: prevFolders,
        selectedFolderId: prevSelected,
        clearSelectedFolderId: prevSelected == null,
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> updateFolder(GoalFolder folder) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevFolders = state.folders;
    final updated = folder.copyWith(updatedAt: DateTime.now());
    final nextFolders = [
      for (final f in prevFolders)
        if (f.id == updated.id) updated else f,
    ];

    emit(state.copyWith(
      folders: nextFolders,
      action: state.action.toLoading(),
    ));

    try {
      await _repo.upsertFolder(uid, updated.toJson(), isUpdate: true);
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to update goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        folders: prevFolders,
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> archiveFolder(GoalFolder folder) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevFolders = state.folders;
    final prevSelected = state.selectedFolderId;
    final updated = folder.copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
    final nextFolders = [
      for (final f in prevFolders)
        if (f.id == updated.id) updated else f,
    ];
    final remainingActive = nextFolders.where((f) => !f.isArchived).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    emit(state.copyWith(
      folders: nextFolders,
      selectedFolderId: remainingActive.firstOrNull?.id,
      clearSelectedFolderId: remainingActive.isEmpty,
      action: state.action.toLoading(),
    ));

    try {
      await _repo.upsertFolder(uid, updated.toJson(), isUpdate: true);
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to archive goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        folders: prevFolders,
        selectedFolderId: prevSelected,
        clearSelectedFolderId: prevSelected == null,
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> unarchiveFolder(GoalFolder folder) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevFolders = state.folders;
    final prevSelected = state.selectedFolderId;
    final updated = folder.copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
    final nextFolders = [
      for (final f in prevFolders)
        if (f.id == updated.id) updated else f,
    ];

    emit(state.copyWith(
      folders: nextFolders,
      selectedFolderId: updated.id,
      action: state.action.toLoading(),
    ));

    try {
      await _repo.upsertFolder(uid, updated.toJson(), isUpdate: true);
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to restore goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        folders: prevFolders,
        selectedFolderId: prevSelected,
        clearSelectedFolderId: prevSelected == null,
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevFolders = state.folders;
    final prevGoals = state.goals;
    final prevSelected = state.selectedFolderId;
    final remainingFolders = prevFolders.where((f) => f.id != folderId).toList();
    final remainingActive = remainingFolders.where((f) => !f.isArchived).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final remainingGoals =
        prevGoals.where((g) => g.folderId != folderId).toList();

    emit(state.copyWith(
      folders: remainingFolders,
      goals: remainingGoals,
      selectedFolderId: remainingActive.firstOrNull?.id,
      clearSelectedFolderId: remainingActive.isEmpty,
      action: state.action.toLoading(),
    ));

    try {
      await _repo.deleteFolder(uid, folderId);
      emit(state.copyWith(action: state.action.toSuccess()));
    } catch (e, s) {
      'Failed to delete goal folder: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        folders: prevFolders,
        goals: prevGoals,
        selectedFolderId: prevSelected,
        clearSelectedFolderId: prevSelected == null,
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
    final trimmedNotes = notes?.trim();
    final safeNotes = (trimmedNotes == null || trimmedNotes.isEmpty)
        ? null
        : (trimmedNotes.length > 1000
            ? trimmedNotes.substring(0, 1000)
            : trimmedNotes);
    final safeTitle = trimmed.length > 200 ? trimmed.substring(0, 200) : trimmed;

    final now = DateTime.now();
    final goal = Goal(
      id: goalId,
      folderId: folderId,
      title: safeTitle,
      notes: safeNotes,
      targetDateKey: targetDateKey,
      sortOrder: existingGoals.length,
      createdAt: now,
      updatedAt: now,
    );

    final prevGoals = state.goals;
    emit(state.copyWith(goals: [...prevGoals, goal]));

    try {
      await _repo.upsertGoal(uid, goal.toJson(), isUpdate: false);
    } catch (e, s) {
      'Failed to add goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        goals: prevGoals,
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
    final now = DateTime.now();
    final updated = goal.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? now : null,
      updatedAt: now,
    );

    final prevGoals = state.goals;
    emit(state.copyWith(
      goals: [
        for (final g in prevGoals)
          if (g.id == updated.id) updated else g,
      ],
    ));

    try {
      await _repo.upsertGoal(uid, updated.toJson(), isUpdate: true);
    } catch (e, s) {
      'Failed to toggle goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(goals: prevGoals));
    }
  }

  Future<void> updateGoal(
    Goal goal, {
    String? title,
    String? notes,
    String? targetDateKey,
    bool clearNotes = false,
    bool clearTargetDate = false,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;

    final rawTitle = title ?? goal.title;
    final trimmedTitle = rawTitle.trim();
    if (trimmedTitle.isEmpty) return;
    final safeTitle =
        trimmedTitle.length > 200 ? trimmedTitle.substring(0, 200) : trimmedTitle;

    String? nextNotes;
    if (clearNotes) {
      nextNotes = null;
    } else if (notes != null) {
      final t = notes.trim();
      nextNotes = t.isEmpty ? null : (t.length > 1000 ? t.substring(0, 1000) : t);
    } else {
      nextNotes = goal.notes;
    }

    final String? nextDate =
        clearTargetDate ? null : (targetDateKey ?? goal.targetDateKey);

    final updated = goal.copyWith(
      title: safeTitle,
      notes: nextNotes,
      targetDateKey: nextDate,
      updatedAt: DateTime.now(),
    );

    final prevGoals = state.goals;
    emit(state.copyWith(
      goals: [
        for (final g in prevGoals)
          if (g.id == updated.id) updated else g,
      ],
    ));

    try {
      await _repo.upsertGoal(uid, updated.toJson(), isUpdate: true);
    } catch (e, s) {
      'Failed to update goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(
        goals: prevGoals,
        action: state.action.toFailed(
          fault: e is Fault ? e : Fault.fromObjectAndStackTrace(e, s),
        ),
      ));
    }
  }

  Future<void> updateGoalTitle(Goal goal, String newTitle) =>
      updateGoal(goal, title: newTitle);

  Future<void> deleteGoal(String goalId) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevGoals = state.goals;
    emit(state.copyWith(
      goals: prevGoals.where((g) => g.id != goalId).toList(),
    ));

    try {
      await _repo.deleteGoal(uid, goalId);
    } catch (e, s) {
      'Failed to delete goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(goals: prevGoals));
    }
  }

  Future<void> restoreGoal(Goal goal) async {
    final uid = _currentUid;
    if (uid == null) return;

    final prevGoals = state.goals;
    if (!prevGoals.any((g) => g.id == goal.id)) {
      emit(state.copyWith(goals: [...prevGoals, goal]));
    }

    try {
      await _repo.upsertGoal(uid, goal.toJson(), isUpdate: false);
    } catch (e, s) {
      'Failed to restore goal: $e'.appLog(
        tag: 'GOALS',
        level: AppLogLevel.error,
        error: e,
        stackTrace: s,
      );
      emit(state.copyWith(goals: prevGoals));
    }
  }

  @override
  Future<void> close() {
    unawaited(_foldersSub?.cancel());
    unawaited(_goalsSub?.cancel());
    return super.close();
  }
}
