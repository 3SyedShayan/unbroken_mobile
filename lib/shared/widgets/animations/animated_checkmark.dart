import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class AppAnimatedCheckmark extends StatefulWidget {
  final bool checked;
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration? duration;
  final bool alwaysMountIcon;

  const AppAnimatedCheckmark({
    super.key,
    required this.checked,
    this.size = 20.0,
    this.color = Colors.white,
    this.strokeWidth = 2.2,
    this.duration,
    this.alwaysMountIcon = false,
  });

  @override
  State<AppAnimatedCheckmark> createState() => _AppAnimatedCheckmarkState();
}

class _AppAnimatedCheckmarkState extends State<AppAnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppProps.fast,
      value: widget.checked ? 1.0 : 0.0,
    );

    _drawAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AppAnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
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
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.alwaysMountIcon || widget.checked)
              Opacity(
                opacity: 0.0,
                child: Icon(Icons.check, size: widget.size),
              ),
            if (_controller.value > 0.0 || widget.checked)
              Transform.scale(
                scale: _scaleAnimation.value,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CheckmarkPainter(
                    progress: _drawAnimation.value,
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final p1 = Offset(w * 0.22, h * 0.52);
    final p2 = Offset(w * 0.42, h * 0.72);
    final p3 = Offset(w * 0.78, h * 0.32);

    final d1 = (p2 - p1).distance;
    final d2 = (p3 - p2).distance;
    final total = d1 + d2;
    final split = total > 0 ? d1 / total : 0.38;

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    if (progress <= split) {
      final t = split > 0 ? (progress / split) : 1.0;
      final current = Offset.lerp(p1, p2, t)!;
      path.lineTo(current.dx, current.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (1.0 - split) > 0 ? ((progress - split) / (1.0 - split)) : 1.0;
      final current = Offset.lerp(p2, p3, t.clamp(0.0, 1.0))!;
      path.lineTo(current.dx, current.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
