import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class FlameCheckButton extends StatefulWidget {
  final Color color;
  final bool isDone;
  final VoidCallback onToggle;

  const FlameCheckButton({
    super.key,
    required this.color,
    required this.isDone,
    required this.onToggle,
  });

  @override
  State<FlameCheckButton> createState() => _FlameCheckButtonState();
}

class _FlameCheckButtonState extends State<FlameCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppProps.fast,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(FlameCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isDone && widget.isDone) {
      _controller.forward(from: 0.0);
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          widget.onToggle();
          if (!widget.isDone) {
            _controller.forward(from: 0.0);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.isDone
                ? widget.color
                : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDone
                  ? widget.color
                  : widget.color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.isDone
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.color.withValues(alpha: 0.4),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

