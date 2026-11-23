part of '../home.dart';

class _GoalsTab extends StatefulWidget {
  const _GoalsTab();

  @override
  State<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<_GoalsTab> {
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = AuthCubit.c(context).state.user;
      if (user != null) {
        GoalsCubit.c(context).startObserving(user.uid);
      }
    });
  }

  void _openFolderForm(BuildContext context, {GoalFolder? folder}) {
    Navigator.push(
      context,
      SlideUpRoute(
        child: FolderFormScreen(folder: folder),
        settings: const RouteSettings(name: AppRoutes.goalFolderForm),
      ),
    );
  }

  void _pushToToday(
    BuildContext context,
    Goal goal,
    List<FocusItem> todayItems,
    DateTime now,
    DaySettings settings,
  ) {
    final alreadyExists = todayItems.any(
      (it) => it.text.trim().toLowerCase() == goal.title.trim().toLowerCase(),
    );
    if (alreadyExists) {
      SnackbarService.instance.showInfo(
        'Already in Today\'s Focus',
        context: context,
      );
      return;
    }
    if (todayItems.length >= FocusCubit.maxTasks) {
      SnackbarService.instance.showWarning(
        'Today\'s Focus is full (${FocusCubit.maxTasks}/${FocusCubit.maxTasks}). Clear a slot first.',
        context: context,
      );
      return;
    }
    FocusCubit.c(context).addTask(
      text: goal.title,
      asOf: now,
      settings: settings,
    );
    SnackbarService.instance.showSuccess(
      'Pushed "${goal.title}" to Today\'s Focus!',
      context: context,
    );
  }

  void _deleteWithUndo(BuildContext context, Goal goal) {
    GoalsCubit.c(context).deleteGoal(goal.id);
    SnackbarService.instance.showInfo(
      'Deleted "${goal.title}"',
      title: null,
      context: context,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Undo',
        textColor: Colors.white,
        onPressed: () => GoalsCubit.c(context).restoreGoal(goal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final now = DateTime.now();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final today = settings.logicalDay(now);
        final todayKey = settings.logicalDayKey(now);

        return BlocBuilder<FocusCubit, FocusState>(
          builder: (context, focusState) {
            final todayItems = focusState.focusForDay(todayKey).itemsList;
            final todayTitlesLower = todayItems
                .map((it) => it.text.trim().toLowerCase())
                .toSet();

            return BlocBuilder<GoalsCubit, GoalsState>(
              builder: (context, state) {
                if (state.fetch.isLoading) {
                  return AnimatedSwitcher(
                    duration: AppProps.medium,
                    child: const GoalsShimmer(key: ValueKey('goals_shimmer')),
                  );
                }

                final activeFolders = state.activeFolders;
                final archivedFolders = state.archivedFolders;
                final selectedFolder = state.selectedFolder;

                return AnimatedSwitcher(
                  duration: AppProps.medium,
                  child: SafeArea(
                    key: const ValueKey('goals_content'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoalsHeader(
                          overall: state.overallProgress,
                          activeFolderCount: activeFolders.length,
                          archivedCount: archivedFolders.length,
                          onAddFolder: () => _openFolderForm(context),
                          onOpenArchived: () => showArchivedFoldersSheet(
                            context,
                            folders: archivedFolders,
                            progressOf: state.folderProgress,
                            onRestore: (f) =>
                                GoalsCubit.c(context).unarchiveFolder(f),
                            onDelete: (f) =>
                                GoalsCubit.c(context).deleteFolder(f.id),
                          ),
                        ),
                        if (activeFolders.isEmpty)
                          Expanded(
                            child: EmptyFoldersView(
                              onAddFolder: () => _openFolderForm(context),
                              onQuickCreate: (name, cadence, emoji, colorHex) =>
                                  GoalsCubit.c(context).createFolder(
                                name: name,
                                cadence: cadence,
                                emoji: emoji,
                                colorHex: colorHex,
                              ),
                            ),
                          )
                        else ...[
                          FolderCarousel(
                            folders: activeFolders,
                            selectedId: selectedFolder?.id,
                            progressOf: state.folderProgress,
                            onSelect: (id) =>
                                GoalsCubit.c(context).selectFolder(id),
                            onAddFolder: () => _openFolderForm(context),
                            onEditFolder: (f) =>
                                _openFolderForm(context, folder: f),
                          ),
                          if (selectedFolder != null)
                            Expanded(
                              child: _ActiveFolderGoalsView(
                                folder: selectedFolder,
                                activeGoals: state
                                    .activeGoalsForFolder(selectedFolder.id),
                                completedGoals: state
                                    .completedGoalsForFolder(selectedFolder.id),
                                progress:
                                    state.folderProgress(selectedFolder.id),
                                today: today,
                                weekStartsMonday: settings.weekStartMonday,
                                showCompleted: _showCompleted,
                                todayTitlesLower: todayTitlesLower,
                                onToggleCompletedSection: () => setState(
                                  () => _showCompleted = !_showCompleted,
                                ),
                                onEditFolder: () => _openFolderForm(
                                  context,
                                  folder: selectedFolder,
                                ),
                                onArchiveFolder: () => GoalsCubit.c(context)
                                    .archiveFolder(selectedFolder),
                                onAddGoal: (title, targetDateKey) =>
                                    GoalsCubit.c(context).addGoal(
                                  folderId: selectedFolder.id,
                                  title: title,
                                  targetDateKey: targetDateKey,
                                ),
                                onToggleGoal: (g) =>
                                    GoalsCubit.c(context).toggleGoal(g),
                                onPushToToday: (g) => _pushToToday(
                                  context,
                                  g,
                                  todayItems,
                                  now,
                                  settings,
                                ),
                                onDeleteGoal: (g) => _deleteWithUndo(context, g),
                                onTapGoal: (g) => showGoalEditSheet(
                                  context,
                                  goal: g,
                                  isInToday: todayTitlesLower
                                      .contains(g.title.trim().toLowerCase()),
                                  onSave: ({
                                    required title,
                                    notes,
                                    targetDateKey,
                                    required clearNotes,
                                    required clearTargetDate,
                                  }) =>
                                      GoalsCubit.c(context).updateGoal(
                                    g,
                                    title: title,
                                    notes: notes,
                                    targetDateKey: targetDateKey,
                                    clearNotes: clearNotes,
                                    clearTargetDate: clearTargetDate,
                                  ),
                                  onPushToToday: () => _pushToToday(
                                    context,
                                    g,
                                    todayItems,
                                    now,
                                    settings,
                                  ),
                                  onDelete: () => _deleteWithUndo(context, g),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ActiveFolderGoalsView extends StatelessWidget {
  final GoalFolder folder;
  final List<Goal> activeGoals;
  final List<Goal> completedGoals;
  final ({int completed, int total}) progress;
  final DateTime today;
  final bool weekStartsMonday;
  final bool showCompleted;
  final Set<String> todayTitlesLower;
  final VoidCallback onToggleCompletedSection;
  final VoidCallback onEditFolder;
  final VoidCallback onArchiveFolder;
  final void Function(String title, String? targetDateKey) onAddGoal;
  final ValueChanged<Goal> onToggleGoal;
  final ValueChanged<Goal> onPushToToday;
  final ValueChanged<Goal> onDeleteGoal;
  final ValueChanged<Goal> onTapGoal;

  const _ActiveFolderGoalsView({
    required this.folder,
    required this.activeGoals,
    required this.completedGoals,
    required this.progress,
    required this.today,
    required this.weekStartsMonday,
    required this.showCompleted,
    required this.todayTitlesLower,
    required this.onToggleCompletedSection,
    required this.onEditFolder,
    required this.onArchiveFolder,
    required this.onAddGoal,
    required this.onToggleGoal,
    required this.onPushToToday,
    required this.onDeleteGoal,
    required this.onTapGoal,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = HabitPalette.parse(folder.colorHex);
    final isEmpty = activeGoals.isEmpty && completedGoals.isEmpty;

    return Padding(
      padding: Space.h.t20,
      child: Column(
        children: [
          Space.y.t16,
          FolderBannerCard(
            folder: folder,
            progress: progress,
            today: today,
            weekStartsMonday: weekStartsMonday,
            onEditFolder: onEditFolder,
            onArchiveFolder: onArchiveFolder,
          ),
          Space.y.t12,
          QuickAddGoalBar(
            folderName: folder.name,
            onAddGoal: onAddGoal,
          ),
          Space.y.t12,
          Expanded(
            child: isEmpty
                ? Center(
                    child: Padding(
                      padding: Space.v.t24,
                      child: Text(
                        'No goals in this folder yet.\nAdd one above to get started!',
                        style: AppText.b1.cl(AppTheme.c.subText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: Space.b.t24,
                    children: [
                      if (activeGoals.isNotEmpty)
                        AnimatedReorderList<Goal>(
                          items: activeGoals,
                          itemKey: (g) => g.id,
                          separator: Space.y.t08,
                          separatorHeight: 8,
                          itemBuilder: (context, goal, _) => GoalTile(
                            goal: goal,
                            folderColor: color,
                            today: today,
                            isInToday: todayTitlesLower
                                .contains(goal.title.trim().toLowerCase()),
                            onToggle: () => onToggleGoal(goal),
                            onTap: () => onTapGoal(goal),
                            onPushToToday: () => onPushToToday(goal),
                            onDelete: () => onDeleteGoal(goal),
                          ),
                        ),
                      if (completedGoals.isNotEmpty) ...[
                        if (activeGoals.isNotEmpty) Space.y.t16,
                        _CompletedSectionHeader(
                          count: completedGoals.length,
                          expanded: showCompleted,
                          onTap: onToggleCompletedSection,
                        ),
                        AnimatedSize(
                          duration: AppProps.fast,
                          curve: Curves.easeOutCubic,
                          child: showCompleted
                              ? Column(
                                  children: [
                                    Space.y.t08,
                                    for (var i = 0;
                                        i < completedGoals.length;
                                        i++) ...[
                                      if (i > 0) Space.y.t08,
                                      GoalTile(
                                        goal: completedGoals[i],
                                        folderColor: color,
                                        today: today,
                                        isInToday: false,
                                        onToggle: () =>
                                            onToggleGoal(completedGoals[i]),
                                        onTap: () =>
                                            onTapGoal(completedGoals[i]),
                                        onPushToToday: () {},
                                        onDelete: () =>
                                            onDeleteGoal(completedGoals[i]),
                                      ),
                                    ],
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompletedSectionHeader extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  const _CompletedSectionHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: AppTheme.c.subText,
            ),
            Space.x.t04,
            Text(
              'Completed ($count)',
              style: AppText.b2b.cl(AppTheme.c.subText),
            ),
          ],
        ),
      ),
    );
  }
}
