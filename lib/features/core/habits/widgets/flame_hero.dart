import 'package:flutter/material.dart';

class FlameHero extends StatefulWidget {
  final double size;
  final String? emoji;

  const FlameHero({
    super.key,
    this.size = 56,
    this.emoji,
  });

  @override
  State<FlameHero> createState() => _FlameHeroState();
}

class _FlameHeroState extends State<FlameHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _translateAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Text(
        widget.emoji ?? '🔥',
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }
}

