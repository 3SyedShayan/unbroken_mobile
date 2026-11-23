import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/shared/widgets/design/modals/app_modal_base.dart';

Future<void> showPullGoalSheet(
  BuildContext context, {
  required Set<String> todayTitlesLower,
  required int currentTaskCount,
  required ValueChanged<Goal> onPullGoal,
}) {
  final goalsCubit = GoalsCubit.c(context);
  return showAppModalSheet<void>(
    context,
    builder: (_) => BlocProvider.value(
      value: goalsCubit,
      child: PullGoalSheet(
        todayTitlesLower: todayTitlesLower,
        currentTaskCount: currentTaskCount,
        onPullGoal: onPullGoal,
      ),
    ),
  );
}

class PullGoalSheet extends StatefulWidget {
  final Set<String> todayTitlesLower;
  final int currentTaskCount;
  final ValueChanged<Goal> onPullGoal;

  const PullGoalSheet({
    super.key,
    required this.todayTitlesLower,
    required this.currentTaskCount,
    required this.onPullGoal,
  });

  @override
  State<PullGoalSheet> createState() => _PullGoalSheetState();
}

class _PullGoalSheetState extends State<PullGoalSheet> {
  final Set<String> _addedTitles = {};
  late int _taskCount;

  @override
  void initState() {
    super.initState();
    _taskCount = widget.currentTaskCount;
  }

  void _pull(Goal goal) {
    if (_taskCount >= FocusCubit.maxTasks) return;
    final lower = goal.title.trim().toLowerCase();
    if (widget.todayTitlesLower.contains(lower) ||
        _addedTitles.contains(lower)) {
      return;
    }
    setState(() {
      _addedTitles.add(lower);
      _taskCount += 1;
    });
    widget.onPullGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final isFull = _taskCount >= FocusCubit.maxTasks;

    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, goalsState) {
        final populated = <({GoalFolder folder, List<Goal> goals})>[];
        for (final folder in goalsState.activeFolders) {
          final list = goalsState.activeGoalsForFolder(folder.id);
          if (list.isNotEmpty) {
            populated.add((folder: folder, goals: list));
          }
        }

        final isLoading =
            goalsState.fetch.isLoading && goalsState.folders.isEmpty;

        return AppModalBase(
          icon: Icon(Icons.track_changes_rounded, color: AppTheme.c.accent),
          title: 'Pull from Goals',
          subtitle: isFull
              ? 'Today\'s Focus is full (${FocusCubit.maxTasks}/${FocusCubit.maxTasks})'
              : 'Add active goals to Today\'s Focus ($_taskCount/${FocusCubit.maxTasks})',
          scrollable: true,
          child: isLoading
              ? Center(
                  child: Padding(
                    padding: Space.v.t24,
                    child: const CircularProgressIndicator.adaptive(),
                  ),
                )
              : populated.isEmpty
                  ? Padding(
                      padding: Space.v.t16,
                      child: Text(
                        'No active goals yet. Create goals in the Goals tab first!',
                        style: AppText.b2.cl(AppTheme.c.subText),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < populated.length; i++) ...[
                          if (i > 0) Space.y.t16,
                          _FolderGroupSection(
                            folder: populated[i].folder,
                            goals: populated[i].goals,
                            todayTitlesLower: widget.todayTitlesLower,
                            addedTitles: _addedTitles,
                            isFull: isFull,
                            onPull: _pull,
                          ),
                        ],
                      ],
                    ),
        );
      },
    );
  }
}

class _FolderGroupSection extends StatelessWidget {
  final GoalFolder folder;
  final List<Goal> goals;
  final Set<String> todayTitlesLower;
  final Set<String> addedTitles;
  final bool isFull;
  final ValueChanged<Goal> onPull;

  const _FolderGroupSection({
    required this.folder,
    required this.goals,
    required this.todayTitlesLower,
    required this.addedTitles,
    required this.isFull,
    required this.onPull,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final emoji =
        folder.emoji.isNotEmpty ? folder.emoji : folder.cadence.defaultEmoji;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji  ${folder.name}',
          style: AppText.b2b.cl(AppTheme.c.subText),
        ),
        Space.y.t08,
        for (var i = 0; i < goals.length; i++) ...[
          if (i > 0) Space.y.t08,
          _PullGoalRow(
            goal: goals[i],
            inToday: todayTitlesLower
                    .contains(goals[i].title.trim().toLowerCase()) ||
                addedTitles.contains(goals[i].title.trim().toLowerCase()),
            isFull: isFull,
            onTap: () => onPull(goals[i]),
          ),
        ],
      ],
    );
  }
}

class _PullGoalRow extends StatelessWidget {
  final Goal goal;
  final bool inToday;
  final bool isFull;
  final VoidCallback onTap;

  const _PullGoalRow({
    required this.goal,
    required this.inToday,
    required this.isFull,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final disabled = inToday || isFull;
    final pillColor = inToday ? AppTheme.c.success : AppTheme.c.accent;

    return Container(
      padding: Space.sym(12, 10),
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              goal.title,
              style: AppText.b1.cl(AppTheme.c.text),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Space.x.t08,
          GestureDetector(
            onTap: disabled ? null : onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isFull && !inToday
                    ? AppTheme.c.subBackground
                    : pillColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inToday ? 'In Today ✓' : '+ Add',
                style: AppText.l1b.cl(
                  isFull && !inToday ? AppTheme.c.subText : pillColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
