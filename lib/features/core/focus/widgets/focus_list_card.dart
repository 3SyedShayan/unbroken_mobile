import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/focus/models/focus_item.dart';
import 'package:unbroken_mobile/features/core/focus/viewmodel/cubit.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class FocusListCard extends StatefulWidget {
  final DateTime today;
  final DateTime now;
  final DaySettings settings;

  const FocusListCard({
    super.key,
    required this.today,
    required this.now,
    required this.settings,
  });

  @override
  State<FocusListCard> createState() => _FocusListCardState();
}

class _FocusListCardState extends State<FocusListCard> {
  final _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        final done = items.where((it) => it.done && it.text.trim().isNotEmpty).length;
        final cleared = filled > 0 && done == filled;

        final statusLine = filled == 0
            ? 'add your tasks for today'
            : (cleared
                ? (streakStats.current > 1
                    ? 'all done — ${streakStats.current} days in a row 🔥'
                    : 'all done for today 🔥')
                : '$done of $filled done today');

        return Container(
          padding: Space.a.t16,
          decoration: BoxDecoration(
            color: AppColors.specBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FocusHeader(
                streak: streakStats.current,
                cleared: cleared,
                statusLine: statusLine,
              ),
              Space.y.t12,
              for (var i = 0; i < items.length; i++) ...[
                _FocusRow(
                  index: i,
                  item: items[i],
                  placeholder: _placeholderForIndex(i),
                  onToggle: () {
                    FocusCubit.c(context).toggleSlot(
                      index: i,
                      asOf: widget.now,
                      settings: widget.settings,
                    );
                  },
                  onTextChanged: (text) {
                    FocusCubit.c(context).updateSlotText(
                      index: i,
                      text: text,
                      asOf: widget.now,
                      settings: widget.settings,
                    );
                  },
                  onDelete: () {
                    FocusCubit.c(context).deleteSlot(
                      index: i,
                      asOf: widget.now,
                      settings: widget.settings,
                    );
                  },
                ),
                if (i < items.length - 1) Space.y.t08,
              ],
              Space.y.t08,
              _AddTaskRow(
                controller: _addController,
                onSubmitted: (text) {
                  FocusCubit.c(context).addTask(
                    text: text,
                    asOf: widget.now,
                    settings: widget.settings,
                  );
                  _addController.clear();
                },
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

class _FocusHeader extends StatelessWidget {
  final int streak;
  final bool cleared;
  final String statusLine;

  const _FocusHeader({
    required this.streak,
    required this.cleared,
    required this.statusLine,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily Tasks', style: AppText.h3b.cl(AppColors.text)),
            if (streak > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  Space.x.t04,
                  Text(
                    '$streak',
                    style: AppText.h3b.cl(
                      cleared ? AppColors.accent : AppColors.subText,
                    ),
                  ),
                ],
              ),
          ],
        ),
        Space.y.t04,
        Text(
          statusLine,
          style: AppText.b2.cl(
            cleared ? AppColors.accent : AppColors.hint,
          ),
        ),
      ],
    );
  }
}

class _FocusRow extends StatefulWidget {
  final int index;
  final FocusItem item;
  final String placeholder;
  final VoidCallback onToggle;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onDelete;

  const _FocusRow({
    required this.index,
    required this.item,
    required this.placeholder,
    required this.onToggle,
    required this.onTextChanged,
    required this.onDelete,
  });

  @override
  State<_FocusRow> createState() => _FocusRowState();
}

class _FocusRowState extends State<_FocusRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }

  @override
  void didUpdateWidget(_FocusRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.text != widget.item.text &&
        _controller.text != widget.item.text) {
      _controller.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final hasText = widget.item.text.trim().isNotEmpty;
    final checked = widget.item.done && hasText;

    return Row(
      children: [
        GestureDetector(
          onTap: hasText ? widget.onToggle : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked ? AppColors.accent : AppColors.specBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: checked ? Colors.transparent : AppColors.dashedBorder,
                width: 1.5,
              ),
            ),
            child: checked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        Space.x.t12,
        Expanded(
          child: TextField(
            controller: _controller,
            style: TextStyle(
              fontFamily: FontFamily.hanken,
              fontSize: 14,
              color: checked ? AppColors.hint : AppColors.text,
              decoration: checked ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.hint,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontFamily: FontFamily.hanken,
                fontSize: 14,
                color: AppColors.hint.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: widget.onTextChanged,
          ),
        ),
        if (hasText)
          GestureDetector(
            onTap: () {
              _controller.clear();
              widget.onDelete();
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: AppColors.hint),
            ),
          ),
      ],
    );
  }
}

class _AddTaskRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _AddTaskRow({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: Icon(Icons.add, size: 14, color: AppColors.hint),
        ),
        Space.x.t12,
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: FontFamily.hanken,
              fontSize: 14,
              color: AppColors.text,
            ),
            decoration: InputDecoration(
              hintText: 'Add a task…',
              hintStyle: TextStyle(
                fontFamily: FontFamily.hanken,
                fontSize: 14,
                color: AppColors.hint.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: (text) {
              if (text.trim().isNotEmpty) {
                onSubmitted(text);
              }
            },
          ),
        ),
      ],
    );
  }
}

