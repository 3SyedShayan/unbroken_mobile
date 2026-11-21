part of 'cubit.dart';

class GoalsState extends Equatable {
  final List<GoalFolder> folders;
  final List<Goal> goals;
  final String? selectedFolderId;
  final BlocState<List<GoalFolder>> fetch;
  final BlocState<void> action;

  const GoalsState({
    this.folders = const [],
    this.goals = const [],
    this.selectedFolderId,
    required this.fetch,
    required this.action,
  });

  GoalsState copyWith({
    List<GoalFolder>? folders,
    List<Goal>? goals,
    String? selectedFolderId,
    bool clearSelectedFolderId = false,
    BlocState<List<GoalFolder>>? fetch,
    BlocState<void>? action,
  }) {
    return GoalsState(
      folders: folders ?? this.folders,
      goals: goals ?? this.goals,
      selectedFolderId: clearSelectedFolderId
          ? null
          : (selectedFolderId ?? this.selectedFolderId),
      fetch: fetch ?? this.fetch,
      action: action ?? this.action,
    );
  }

  List<GoalFolder> get activeFolders {
    final list = folders.where((f) => !f.isArchived).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  GoalFolder? get selectedFolder {
    if (selectedFolderId != null) {
      for (final f in folders) {
        if (f.id == selectedFolderId && !f.isArchived) return f;
      }
    }
    return activeFolders.firstOrNull;
  }

  List<Goal> goalsForFolder(String folderId) {
    final list = goals.where((g) => g.folderId == folderId).toList();
    list.sort((a, b) {
      // Uncompleted goals first, then by sortOrder, then createdAt
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final sortCmp = a.sortOrder.compareTo(b.sortOrder);
      if (sortCmp != 0) return sortCmp;
      if (a.createdAt != null && b.createdAt != null) {
        return a.createdAt!.compareTo(b.createdAt!);
      }
      return 0;
    });
    return list;
  }

  ({int completed, int total}) folderProgress(String folderId) {
    final items = goals.where((g) => g.folderId == folderId).toList();
    final total = items.length;
    final completed = items.where((g) => g.isCompleted).length;
    return (completed: completed, total: total);
  }

  ({int completed, int total}) get overallProgress {
    final activeIds = activeFolders.map((f) => f.id).toSet();
    final activeGoals = goals.where((g) => activeIds.contains(g.folderId)).toList();
    final total = activeGoals.length;
    final completed = activeGoals.where((g) => g.isCompleted).length;
    return (completed: completed, total: total);
  }

  @override
  List<Object?> get props => [folders, goals, selectedFolderId, fetch, action];
}
