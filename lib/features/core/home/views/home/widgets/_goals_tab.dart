part of '../home.dart';

class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        final activeFolders = state.activeFolders;
        final selectedFolder = state.selectedFolder;
        final overall = state.overallProgress;

        return Screen(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFCF6EC), Color(0xFFF5E7D3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoalsHeader(
                    overall: overall,
                    onAddFolder: () {
                      Navigator.push(
                        context,
                        SlideUpRoute(
                          child: const FolderFormScreen(),
                          settings: const RouteSettings(
                            name: AppRoutes.goalFolderForm,
                          ),
                        ),
                      );
                    },
                  ),
                  if (activeFolders.isEmpty)
                    Expanded(
                      child: _EmptyFoldersView(
                        onAddFolder: () {
                          Navigator.push(
                            context,
                            SlideUpRoute(
                              child: const FolderFormScreen(),
                              settings: const RouteSettings(
                                name: AppRoutes.goalFolderForm,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else ...[
                    _FolderCarousel(
                      folders: activeFolders,
                      selectedId: selectedFolder?.id,
                      onSelect: (id) => GoalsCubit.c(context).selectFolder(id),
                      onAddFolder: () {
                        Navigator.push(
                          context,
                          SlideUpRoute(
                            child: const FolderFormScreen(),
                            settings: const RouteSettings(
                              name: AppRoutes.goalFolderForm,
                            ),
                          ),
                        );
                      },
                      onEditFolder: (folder) {
                        Navigator.push(
                          context,
                          SlideUpRoute(
                            child: FolderFormScreen(folder: folder),
                            settings: const RouteSettings(
                              name: AppRoutes.goalFolderForm,
                            ),
                          ),
                        );
                      },
                    ),
                    if (selectedFolder != null)
                      Expanded(
                        child: _ActiveFolderContent(
                          folder: selectedFolder,
                          goals: state.goalsForFolder(selectedFolder.id),
                          progress: state.folderProgress(selectedFolder.id),
                          onEditFolder: () {
                            Navigator.push(
                              context,
                              SlideUpRoute(
                                child: FolderFormScreen(folder: selectedFolder),
                                settings: const RouteSettings(
                                  name: AppRoutes.goalFolderForm,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GoalsHeader extends StatelessWidget {
  final ({int completed, int total}) overall;
  final VoidCallback onAddFolder;

  const _GoalsHeader({
    required this.overall,
    required this.onAddFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Space.sym(20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Goals', style: AppText.h1b.cl(AppColors.text)),
              Space.y.t04,
              Text(
                overall.total > 0
                    ? '${overall.completed} of ${overall.total} completed'
                    : 'Time-horizon target folders',
                style: AppText.b2.cl(AppColors.subText),
              ),
            ],
          ),
          GestureDetector(
            onTap: onAddFolder,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: Space.sym(12, 8),
              decoration: BoxDecoration(
                color: AppColors.specBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.fieldBorder, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.create_new_folder_outlined,
                      size: 18, color: AppColors.accent),
                  Space.x.t08,
                  Text(
                    '+ Folder',
                    style: TextStyle(
                      fontFamily: FontFamily.hanken,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFoldersView extends StatelessWidget {
  final VoidCallback onAddFolder;

  const _EmptyFoldersView({required this.onAddFolder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Space.h.t32,
        child: Container(
          padding: Space.a.t28,
          decoration: BoxDecoration(
            color: AppColors.specBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.fieldBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 32)),
              ),
              Space.y.t16,
              Text(
                'No Goal Folders Yet',
                style: AppText.h2b.cl(AppColors.text),
                textAlign: TextAlign.center,
              ),
              Space.y.t08,
              Text(
                'Create a Weekly, Monthly, or Weekend folder to organize and track your goals across time horizons.',
                style: AppText.b1.cl(AppColors.subText),
                textAlign: TextAlign.center,
              ),
              Space.y.t24,
              AppButton(
                label: 'Create First Folder',
                icon: Icons.add_rounded,
                style: .primary,
                size: .medium,
                onTap: onAddFolder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderCarousel extends StatelessWidget {
  final List<GoalFolder> folders;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddFolder;
  final ValueChanged<GoalFolder> onEditFolder;

  const _FolderCarousel({
    required this.folders,
    required this.selectedId,
    required this.onSelect,
    required this.onAddFolder,
    required this.onEditFolder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        padding: Space.h.t20,
        scrollDirection: Axis.horizontal,
        itemCount: folders.length + 1,
        separatorBuilder: (_, _) => Space.x.t12,
        itemBuilder: (context, index) {
          if (index == folders.length) {
            return GestureDetector(
              onTap: onAddFolder,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.specBackground.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.fieldBorder,
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 22, color: AppColors.subText),
                    Space.y.t04,
                    Text(
                      'New',
                      style: TextStyle(
                        fontFamily: FontFamily.hanken,
                        fontSize: 11,
                        color: AppColors.subText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final folder = folders[index];
          final isSelected = folder.id == selectedId;
          final color = HabitPalette.parse(folder.colorHex);
          final progress =
              GoalsCubit.c(context, true).state.folderProgress(folder.id);

          return GestureDetector(
            onTap: () => onSelect(folder.id),
            onLongPress: () => onEditFolder(folder),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: Space.sym(14, 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.specBackground
                    : AppColors.specBackground.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : AppColors.fieldBorder,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      folder.emoji.isNotEmpty
                          ? folder.emoji
                          : folder.cadence.defaultEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Space.x.t12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        folder.name,
                        style: TextStyle(
                          fontFamily: FontFamily.hanken,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Space.y.t04,
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              folder.cadence.label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: FontFamily.hanken,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Space.x.t08,
                          Text(
                            '${progress.completed}/${progress.total}',
                            style: TextStyle(
                              fontFamily: FontFamily.hanken,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: progress.total > 0 &&
                                      progress.completed == progress.total
                                  ? AppColors.success
                                  : AppColors.subText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActiveFolderContent extends StatelessWidget {
  final GoalFolder folder;
  final List<Goal> goals;
  final ({int completed, int total}) progress;
  final VoidCallback onEditFolder;

  const _ActiveFolderContent({
    required this.folder,
    required this.goals,
    required this.progress,
    required this.onEditFolder,
  });

  @override
  Widget build(BuildContext context) {
    final color = HabitPalette.parse(folder.colorHex);
    final ratio =
        progress.total > 0 ? progress.completed / progress.total : 0.0;

    return Padding(
      padding: Space.h.t20,
      child: Column(
        children: [
          Space.y.t16,
          // Folder Banner Card
          Container(
            padding: Space.sym(16, 12),
            decoration: BoxDecoration(
              color: AppColors.specBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fieldBorder, width: 1.2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          folder.emoji.isNotEmpty
                              ? folder.emoji
                              : folder.cadence.defaultEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Space.x.t08,
                        Text(folder.name, style: AppText.h3b.cl(AppColors.text)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz_rounded,
                          size: 20, color: AppColors.subText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onEditFolder,
                    ),
                  ],
                ),
                Space.y.t08,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.fieldBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Space.y.t04,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(ratio * 100).toInt()}% Done',
                      style: TextStyle(
                        fontFamily: FontFamily.hanken,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      '${progress.completed} of ${progress.total} goals completed',
                      style: AppText.l1.cl(AppColors.subText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Space.y.t12,
          _QuickAddGoalBar(folderId: folder.id),
          Space.y.t12,
          Expanded(
            child: goals.isEmpty
                ? Center(
                    child: Padding(
                      padding: Space.v.t32,
                      child: Text(
                        'No goals in this folder yet.\nAdd one above to get started!',
                        style: AppText.b1.cl(AppColors.subText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: Space.b.t24,
                    itemCount: goals.length,
                    separatorBuilder: (_, _) => Space.y.t08,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return _GoalTile(
                        goal: goal,
                        folderColor: color,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddGoalBar extends StatefulWidget {
  final String folderId;

  const _QuickAddGoalBar({required this.folderId});

  @override
  State<_QuickAddGoalBar> createState() => _QuickAddGoalBarState();
}

class _QuickAddGoalBarState extends State<_QuickAddGoalBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    GoalsCubit.c(context).addGoal(
      folderId: widget.folderId,
      title: text,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.fieldBorder, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_task_rounded, size: 20, color: AppColors.subText),
          Space.x.t08,
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppText.b1.cl(AppColors.text),
              decoration: InputDecoration(
                hintText: 'Add a goal to this folder...',
                hintStyle: AppText.b1.cl(AppColors.hint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded,
                size: 20, color: AppColors.accent),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final Goal goal;
  final Color folderColor;

  const _GoalTile({
    required this.goal,
    required this.folderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Space.sym(14, 10),
      decoration: BoxDecoration(
        color: goal.isCompleted
            ? AppColors.specBackground.withValues(alpha: 0.5)
            : AppColors.specBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.fieldBorder.withValues(alpha: 0.5)
              : AppColors.fieldBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              GoalsCubit.c(context).toggleGoal(goal);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: goal.isCompleted ? folderColor : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: goal.isCompleted ? folderColor : AppColors.subText,
                  width: 1.8,
                ),
              ),
              child: goal.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          Space.x.t12,
          // Goal Title
          Expanded(
            child: Text(
              goal.title,
              style: TextStyle(
                fontFamily: FontFamily.hanken,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: goal.isCompleted ? AppColors.subText : AppColors.text,
                decoration:
                    goal.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.subText,
              ),
            ),
          ),
          Space.x.t08,
          // Push to Today's Focus Synergy Button (User decision 3)
          if (!goal.isCompleted)
            GestureDetector(
              onTap: () {
                final settings = SettingsCubit.c(context).state.settings;
                FocusCubit.c(context).addTask(
                  text: goal.title,
                  asOf: DateTime.now(),
                  settings: settings,
                );
                AppSnackbars.success(
                  'Pushed "${goal.title}" to Today\'s Focus!',
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 14, color: AppColors.accent),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: FontFamily.hanken,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Space.x.t04,
          // Delete Button
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.hint),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: () {
              GoalsCubit.c(context).deleteGoal(goal.id);
            },
          ),
        ],
      ),
    );
  }
}
