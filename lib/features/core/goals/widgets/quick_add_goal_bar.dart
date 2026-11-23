import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/support/settings/models/day_settings.dart';

class QuickAddGoalBar extends StatefulWidget {
  final String folderName;
  final void Function(String title, String? targetDateKey) onAddGoal;

  const QuickAddGoalBar({
    super.key,
    required this.folderName,
    required this.onAddGoal,
  });

  @override
  State<QuickAddGoalBar> createState() => _QuickAddGoalBarState();
}

class _QuickAddGoalBarState extends State<QuickAddGoalBar> {
  final _controller = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final dateKey =
        _targetDate == null ? null : DaySettings.dayKey(_targetDate!);
    widget.onAddGoal(text, dateKey);
    _controller.clear();
    if (_targetDate != null) {
      setState(() => _targetDate = null);
    }
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

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.c.border, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_task_rounded,
                size: 20,
                color: AppTheme.c.subText,
              ),
              Space.x.t08,
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppText.b1.cl(AppTheme.c.text),
                  decoration: InputDecoration(
                    hintText: 'Add a goal to ${widget.folderName}...',
                    hintStyle: AppText.b1.cl(AppTheme.c.subText),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.event_outlined,
                  size: 19,
                  color: _targetDate != null
                      ? AppTheme.c.accent
                      : AppTheme.c.subText,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: _pickDate,
              ),
              Space.x.t04,
              IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  size: 20,
                  color: AppTheme.c.accent,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: _submit,
              ),
            ],
          ),
          if (_targetDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: GestureDetector(
                onTap: () => setState(() => _targetDate = null),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.c.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Target: ${DateFormat('MMM d').format(_targetDate!)}',
                        style: AppText.l1b.cl(AppTheme.c.accent),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: AppTheme.c.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
