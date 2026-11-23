import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/design/modals/app_modal_base.dart';

Future<void> showHabitReorderSheet(
  BuildContext context, {
  required List<Habit> habits,
  required ValueChanged<List<Habit>> onSave,
}) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => HabitReorderSheet(
      habits: habits,
      onSave: onSave,
    ),
  );
}

class HabitReorderSheet extends StatefulWidget {
  final List<Habit> habits;
  final ValueChanged<List<Habit>> onSave;

  const HabitReorderSheet({
    super.key,
    required this.habits,
    required this.onSave,
  });

  @override
  State<HabitReorderSheet> createState() => _HabitReorderSheetState();
}

class _HabitReorderSheetState extends State<HabitReorderSheet> {
  late List<Habit> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Habit>.from(widget.habits);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final moved = _items.removeAt(oldIndex);
      _items.insert(newIndex, moved);
    });
  }

  void _save() {
    widget.onSave(List<Habit>.from(_items));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final listHeight = (_items.length * 60.0).clamp(120.0, 340.0);

    return AppModalBase(
      icon: Icon(Icons.swap_vert_rounded, color: AppTheme.c.accent),
      title: 'Reorder Habits',
      subtitle: 'Drag handles to set your daily priority order',
      actions: [
        AppButton(
          label: 'Save Order',
          style: .primary,
          size: .medium,
          mainAxisSize: .max,
          onTap: _save,
        ),
      ],
      child: SizedBox(
        height: listHeight,
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: _items.length,
          onReorderItem: _onReorderItem,
          itemBuilder: (context, index) {
            final habit = _items[index];
            final emoji = habit.emoji.isEmpty ? '🔥' : habit.emoji;

            return Container(
              key: ValueKey(habit.id),
              margin: const EdgeInsets.only(bottom: 8),
              padding: Space.sym(12, 10),
              decoration: BoxDecoration(
                color: AppTheme.c.specBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.c.border, width: 1),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  Space.x.t12,
                  Expanded(
                    child: Text(
                      habit.name,
                      style: AppText.b1b.cl(AppTheme.c.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: AppTheme.c.subText,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
