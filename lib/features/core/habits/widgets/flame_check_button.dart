import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_checkmark.dart';

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
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
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
          HapticFeedback.lightImpact();
          widget.onToggle();
          if (!widget.isDone) {
            _controller.forward(from: 0.0);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppProps.fast,
          curve: Curves.easeInOut,
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
            child: AnimatedSwitcher(
              duration: AppProps.fast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: RotationTransition(
                    turns: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: widget.isDone
                  ? const AppAnimatedCheckmark(
                      key: ValueKey('done'),
                      checked: true,
                      size: 20,
                      strokeWidth: 2.2,
                      color: Colors.white,
                    )
                  : Text(
                      '🔥',
                      key: const ValueKey('flame'),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.color.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}


