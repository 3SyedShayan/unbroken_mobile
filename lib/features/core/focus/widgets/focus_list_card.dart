import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_checkmark.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';

part '_focus_controls.dart';
part '_focus_header.dart';
part '_focus_row.dart';

class FocusListCard extends StatefulWidget {
  final DateTime today;
  final DateTime now;
  final DaySettings settings;
  final bool showPullFromGoals;
  final VoidCallback? onPullFromGoals;
  final void Function(FocusItem item, int index)? onTaskDeleted;

  const FocusListCard({
    super.key,
    required this.today,
    required this.now,
    required this.settings,
    this.showPullFromGoals = false,
    this.onPullFromGoals,
    this.onTaskDeleted,
  });

  @override
  State<FocusListCard> createState() => _FocusListCardState();
}

class _FocusListCardState extends State<FocusListCard> {
  final _addController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusCubit.c(context).applyRolloverIfEnabled(
        asOf: widget.now,
        settings: widget.settings,
      );
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final dayKey = widget.settings.logicalDayKey(widget.now);

    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        final focus = state.focusForDay(dayKey);
        final items = focus.itemsList;
        final streakStats = state.streakStats(
          asOf: widget.now,
          settings: widget.settings,
        );

        final filled = items.where((it) => it.text.trim().isNotEmpty).length;
        final done =
            items.where((it) => it.done && it.text.trim().isNotEmpty).length;
        final cleared = filled > 0 && done == filled;

        final statusLine = filled == 0
            ? 'add your tasks for today'
            : (cleared
                ? (streakStats.current > 1
                    ? 'all done — ${streakStats.current} days in a row 🔥'
                    : 'all done for today 🔥')
                : '$done of $filled done today');

        final coreItems = items.take(3).toList();
        final overflowItems =
            items.length > 3 ? items.sublist(3) : <FocusItem>[];
        final isAtMax = items.length >= FocusCubit.maxTasks;

        return Container(
          padding: Space.a.t16,
          decoration: BoxDecoration(
            color: AppTheme.c.specBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.c.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FocusHeader(
                streak: streakStats.current,
                cleared: cleared,
                statusLine: statusLine,
                done: done,
                total: filled,
                showPullFromGoals: widget.showPullFromGoals && !isAtMax,
                onPullFromGoals: widget.onPullFromGoals,
              ),
              Space.y.t12,
              for (var i = 0; i < coreItems.length; i++) ...[
                _FocusRow(
                  key: ValueKey(coreItems[i].id),
                  index: i,
                  item: coreItems[i],
                  placeholder: _placeholderForIndex(i),
                  onToggle: () => FocusCubit.c(context).toggleSlot(
                    index: i,
                    asOf: widget.now,
                    settings: widget.settings,
                  ),
                  onTextChanged: (text, pruneEmpty) =>
                      FocusCubit.c(context).updateSlotText(
                    index: i,
                    text: text,
                    asOf: widget.now,
                    settings: widget.settings,
                    pruneEmpty: pruneEmpty,
                  ),
                  onCommit: () => FocusCubit.c(context).flushPendingCommits(),
                  onDelete: () {
                    final removed = coreItems[i];
                    FocusCubit.c(context).deleteSlot(
                      index: i,
                      asOf: widget.now,
                      settings: widget.settings,
                    );
                    widget.onTaskDeleted?.call(removed, i);
                  },
                ),
                if (i < coreItems.length - 1 || overflowItems.isNotEmpty)
                  Space.y.t08,
              ],
              if (overflowItems.isNotEmpty) ...[
                _OverflowToggle(
                  isExpanded: _isExpanded,
                  overflowCount: overflowItems.length,
                  completedCount: overflowItems
                      .where((it) => it.done && it.text.trim().isNotEmpty)
                      .length,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Space.y.t08,
                      for (var i = 0; i < overflowItems.length; i++) ...[
                        _FocusRow(
                          key: ValueKey(overflowItems[i].id),
                          index: i + 3,
                          item: overflowItems[i],
                          placeholder: _placeholderForIndex(i + 3),
                          onToggle: () => FocusCubit.c(context).toggleSlot(
                            index: i + 3,
                            asOf: widget.now,
                            settings: widget.settings,
                          ),
                          onTextChanged: (text, pruneEmpty) =>
                              FocusCubit.c(context).updateSlotText(
                            index: i + 3,
                            text: text,
                            asOf: widget.now,
                            settings: widget.settings,
                            pruneEmpty: pruneEmpty,
                          ),
                          onCommit: () => FocusCubit.c(context).flushPendingCommits(),
                          onDelete: () {
                            final removed = overflowItems[i];
                            FocusCubit.c(context).deleteSlot(
                              index: i + 3,
                              asOf: widget.now,
                              settings: widget.settings,
                            );
                            widget.onTaskDeleted?.call(removed, i + 3);
                          },
                        ),
                        if (i < overflowItems.length - 1) Space.y.t08,
                      ],
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: AppProps.medium,
                  sizeCurve: Curves.easeInOutCubic,
                ),
              ],
              Space.y.t08,
              AnimatedSwitcher(
                duration: AppProps.medium,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isAtMax
                    ? const _MaxTasksReachedRow(key: ValueKey('max_reached'))
                    : _AddTaskRow(
                        key: const ValueKey('add_task_row'),
                        controller: _addController,
                        onSubmitted: (text) {
                          FocusCubit.c(context).addTask(
                            text: text,
                            asOf: widget.now,
                            settings: widget.settings,
                          );
                          _addController.clear();
                          setState(() => _isExpanded = true);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _placeholderForIndex(int index) {
    return switch (index) {
      0 => 'The one thing that matters most',
      1 => 'Second most important',
      2 => 'Third most important',
      _ => 'Another task',
    };
  }
}
