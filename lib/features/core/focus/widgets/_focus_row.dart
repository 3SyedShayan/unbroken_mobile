part of 'focus_list_card.dart';

class _FocusRow extends StatefulWidget {
  final int index;
  final FocusItem item;
  final String placeholder;
  final VoidCallback onToggle;
  final void Function(String text, bool pruneEmpty) onTextChanged;
  final VoidCallback? onCommit;
  final VoidCallback onDelete;

  const _FocusRow({
    super.key,
    required this.index,
    required this.item,
    required this.placeholder,
    required this.onToggle,
    required this.onTextChanged,
    this.onCommit,
    required this.onDelete,
  });

  @override
  State<_FocusRow> createState() => _FocusRowState();
}

class _FocusRowState extends State<_FocusRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isCheckboxPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onTextChanged(_controller.text, true);
      widget.onCommit?.call();
    }
  }

  @override
  void didUpdateWidget(_FocusRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus &&
        oldWidget.item.text != widget.item.text &&
        _controller.text != widget.item.text) {
      _controller.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
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
          onTapDown:
              hasText ? (_) => setState(() => _isCheckboxPressed = true) : null,
          onTapUp:
              hasText ? (_) => setState(() => _isCheckboxPressed = false) : null,
          onTapCancel:
              hasText ? () => setState(() => _isCheckboxPressed = false) : null,
          onTap: hasText
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onToggle();
                }
              : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isCheckboxPressed ? 0.88 : 1.0,
            duration: AppProps.quick,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: AppProps.fast,
              curve: Curves.easeInOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color:
                    checked ? AppTheme.c.accent : AppTheme.c.specBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? Colors.transparent : AppTheme.c.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: AppAnimatedCheckmark(
                  checked: checked,
                  size: 14,
                  strokeWidth: 2.0,
                  color: AppTheme.c.onAccent,
                  alwaysMountIcon: true,
                ),
              ),
            ),
          ),
        ),
        Space.x.t12,
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: 300,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            style: AppText.b1.cl(checked ? AppTheme.c.subText : AppTheme.c.text).copyWith(
              decoration: checked ? TextDecoration.lineThrough : null,
              decorationColor: AppTheme.c.subText,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppText.b1.cl(AppTheme.c.subText.withValues(alpha: 0.6)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: (text) => widget.onTextChanged(text, false),
            onSubmitted: (text) {
              widget.onTextChanged(text, true);
              widget.onCommit?.call();
            },
          ),
        ),
        if (hasText)
          GestureDetector(
            onTap: () {
              _controller.clear();
              widget.onDelete();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: AppTheme.c.subText),
            ),
          ),
      ],
    );
  }
}
