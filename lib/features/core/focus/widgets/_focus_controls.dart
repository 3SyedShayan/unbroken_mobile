part of 'focus_list_card.dart';

class _OverflowToggle extends StatefulWidget {
  final bool isExpanded;
  final int overflowCount;
  final int completedCount;
  final VoidCallback onTap;

  const _OverflowToggle({
    required this.isExpanded,
    required this.overflowCount,
    required this.completedCount,
    required this.onTap,
  });

  @override
  State<_OverflowToggle> createState() => _OverflowToggleState();
}

class _OverflowToggleState extends State<_OverflowToggle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final count = widget.overflowCount;
    final done = widget.completedCount;
    final label = widget.isExpanded
        ? 'Hide additional tasks'
        : 'Show $count more ${count == 1 ? 'task' : 'tasks'}';
    final progressLabel = done > 0 ? ' • $done/$count done' : '';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppProps.quick,
        curve: Curves.easeOutCubic,
        child: Container(
          padding: Space.sym(12, 8),
          decoration: BoxDecoration(
            color: widget.isExpanded
                ? AppTheme.c.subBackground
                : AppTheme.c.specBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.c.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isExpanded
                        ? Icons.unfold_less_rounded
                        : Icons.unfold_more_rounded,
                    size: 16,
                    color: AppTheme.c.accent,
                  ),
                  Space.x.t08,
                  Text.rich(
                    TextSpan(
                      text: label,
                      style: AppText.b2b.cl(AppTheme.c.text),
                      children: [
                        if (progressLabel.isNotEmpty)
                          TextSpan(
                            text: progressLabel,
                            style: AppText.b2.cl(
                              done == count
                                  ? AppTheme.c.accent
                                  : AppTheme.c.subText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0.0,
                duration: AppProps.medium,
                curve: Curves.easeInOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppTheme.c.subText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaxTasksReachedRow extends StatelessWidget {
  const _MaxTasksReachedRow({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      width: double.infinity,
      padding: Space.sym(12, 8),
      decoration: BoxDecoration(
        color: AppTheme.c.subBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 15, color: AppTheme.c.accent),
          Space.x.t08,
          Text(
            'Maximum 10 tasks reached for today',
            style: AppText.b2.cl(AppTheme.c.subText).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _AddTaskRow({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  void _submitIfValid() {
    if (controller.text.trim().isNotEmpty) {
      onSubmitted(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Icon(Icons.add, size: 14, color: AppTheme.c.subText),
        ),
        Space.x.t12,
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: 300,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            style: AppText.b1.cl(AppTheme.c.text),
            decoration: InputDecoration(
              hintText: 'Add a task…',
              hintStyle: AppText.b1.cl(
                AppTheme.c.subText.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: (_) => _submitIfValid(),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) {
            if (value.text.trim().isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: AppTheme.c.accent,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: _submitIfValid,
            );
          },
        ),
      ],
    );
  }
}
