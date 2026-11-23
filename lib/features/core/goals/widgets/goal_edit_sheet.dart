import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/design/modals/app_modal_base.dart';

Future<void> showGoalEditSheet(
  BuildContext context, {
  required Goal goal,
  required bool isInToday,
  required void Function({
    required String title,
    String? notes,
    String? targetDateKey,
    required bool clearNotes,
    required bool clearTargetDate,
  }) onSave,
  required VoidCallback onPushToToday,
  required VoidCallback onDelete,
}) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => GoalEditSheet(
      goal: goal,
      isInToday: isInToday,
      onSave: onSave,
      onPushToToday: onPushToToday,
      onDelete: onDelete,
    ),
  );
}

class GoalEditSheet extends StatefulWidget {
  final Goal goal;
  final bool isInToday;
  final void Function({
    required String title,
    String? notes,
    String? targetDateKey,
    required bool clearNotes,
    required bool clearTargetDate,
  }) onSave;
  final VoidCallback onPushToToday;
  final VoidCallback onDelete;

  const GoalEditSheet({
    super.key,
    required this.goal,
    required this.isInToday,
    required this.onSave,
    required this.onPushToToday,
    required this.onDelete,
  });

  @override
  State<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<GoalEditSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _notesController = TextEditingController(text: widget.goal.notes ?? '');
    final key = widget.goal.targetDateKey;
    _targetDate = key == null ? null : DaySettings.startOfDay(key);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _targetDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final notes = _notesController.text.trim();

    widget.onSave(
      title: title,
      notes: notes.isEmpty ? null : notes,
      targetDateKey:
          _targetDate == null ? null : DaySettings.dayKey(_targetDate!),
      clearNotes: notes.isEmpty,
      clearTargetDate: _targetDate == null,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final canSave = _titleController.text.trim().isNotEmpty;

    return AppModalBase(
      title: 'Edit Goal',
      scrollable: true,
      actions: [
        AppButton(
          label: 'Save Changes',
          style: .primary,
          size: .medium,
          mainAxisSize: .max,
          state: canSave ? .def : .disabled,
          onTap: _save,
        ),
        Row(
          children: [
            if (!widget.goal.isCompleted) ...[
              Expanded(
                child: AppButton(
                  label: widget.isInToday ? 'In Today ✓' : 'Push to Today',
                  style: .creamy,
                  size: .small,
                  mainAxisSize: .max,
                  state: widget.isInToday ? .disabled : .def,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPushToToday();
                  },
                ),
              ),
              Space.x.t08,
            ],
            Expanded(
              child: AppButton(
                label: 'Delete Goal',
                style: .error,
                size: .small,
                mainAxisSize: .max,
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
              ),
            ),
          ],
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TITLE',
            style: AppText.l1b.cl(AppTheme.c.subText).copyWith(letterSpacing: 1.1),
          ),
          Space.y.t08,
          Container(
            padding: Space.sym(14, 10),
            decoration: BoxDecoration(
              color: AppTheme.c.specBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.c.border, width: 1.2),
            ),
            child: TextField(
              controller: _titleController,
              maxLength: 200,
              style: AppText.b1b.cl(AppTheme.c.text),
              decoration: InputDecoration(
                hintText: 'Goal title...',
                hintStyle: AppText.b1.cl(AppTheme.c.subText),
                border: InputBorder.none,
                isDense: true,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Space.y.t16,
          Text(
            'NOTES',
            style: AppText.l1b.cl(AppTheme.c.subText).copyWith(letterSpacing: 1.1),
          ),
          Space.y.t08,
          Container(
            padding: Space.sym(14, 10),
            decoration: BoxDecoration(
              color: AppTheme.c.specBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.c.border, width: 1.2),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 1000,
              style: AppText.b1.cl(AppTheme.c.text),
              decoration: InputDecoration(
                hintText: 'Add details, steps, or links...',
                hintStyle: AppText.b1.cl(AppTheme.c.subText),
                border: InputBorder.none,
                isDense: true,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Space.y.t16,
          Text(
            'TARGET DATE',
            style: AppText.l1b.cl(AppTheme.c.subText).copyWith(letterSpacing: 1.1),
          ),
          Space.y.t08,
          _TargetDateSelector(
            targetDate: _targetDate,
            onPick: _pickDate,
            onClear: () => setState(() => _targetDate = null),
          ),
        ],
      ),
    );
  }
}

class _TargetDateSelector extends StatelessWidget {
  final DateTime? targetDate;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _TargetDateSelector({
    required this.targetDate,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onPick,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: Space.sym(14, 12),
        decoration: BoxDecoration(
          color: AppTheme.c.specBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.c.border, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 18,
              color: targetDate != null ? AppTheme.c.accent : AppTheme.c.subText,
            ),
            Space.x.t08,
            Expanded(
              child: Text(
                targetDate == null
                    ? 'Set target date (optional)'
                    : DateFormat('EEE, MMM d, yyyy').format(targetDate!),
                style: AppText.b1.cl(
                  targetDate == null ? AppTheme.c.subText : AppTheme.c.text,
                ),
              ),
            ),
            if (targetDate != null)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppTheme.c.subText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
