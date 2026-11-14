import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

/// A reusable widget that displays decorative circles for a modern, minimal background design.
/// Use this as a background layer in a Stack widget.
class DecorativeCircles extends StatelessWidget {
  const DecorativeCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ═══════════════════════════════════════════
        // TOP SECTION - Hero area decorations
        // ═══════════════════════════════════════════
        Positioned(
          top: (AppMedia.width * -0.12),
          right: (AppMedia.width * -0.1),
          child: _GradientCircle(
            diameter: (AppMedia.width * 0.45),
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.12),
              AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.05),
            ],
          ),
        ),
        Positioned(
          top: (AppMedia.width * -0.08),
          left: (AppMedia.width * -0.15),
          child: _GradientCircle(
            diameter: (AppMedia.width * 0.4),
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.1),
              AppTheme.c.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.08),
          right: (AppMedia.width * 0.1),
          child: _CircleOutline(
            diameter: (AppMedia.width * 0.12),
            color: AppTheme.c.primary.withValues(alpha: 0.15),
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.05),
          left: (AppMedia.width * 0.2),
          child: _Circle(
            diameter: (AppMedia.width * 0.04),
            color: AppTheme.c.primary.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.12),
          left: (AppMedia.width * 0.05),
          child: _DottedCircle(
            diameter: (AppMedia.width * 0.08),
            color: AppTheme.c.primary.withValues(alpha: 0.12),
          ),
        ),

        // ═══════════════════════════════════════════
        // UPPER-MIDDLE SECTION
        // ═══════════════════════════════════════════
        Positioned(
          top: (AppMedia.height * 0.2),
          right: (AppMedia.width * -0.06),
          child: _CircleOutline(
            diameter: (AppMedia.width * 0.18),
            color: AppTheme.c.primary.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.25),
          left: (AppMedia.width * 0.15),
          child: _Circle(
            diameter: (AppMedia.width * 0.03),
            color: AppTheme.c.primary.withValues(alpha: 0.15),
          ),
        ),

        // ═══════════════════════════════════════════
        // MIDDLE SECTION
        // ═══════════════════════════════════════════
        Positioned(
          top: (AppMedia.height * 0.4),
          left: (AppMedia.width * -0.08),
          child: _GradientCircle(
            diameter: (AppMedia.width * 0.25),
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.08),
              AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.03),
            ],
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.45),
          right: (AppMedia.width * 0.08),
          child: _DottedCircle(
            diameter: (AppMedia.width * 0.1),
            color: AppTheme.c.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          top: (AppMedia.height * 0.52),
          left: (AppMedia.width * 0.35),
          child: _Circle(
            diameter: (AppMedia.width * 0.025),
            color: AppTheme.c.primary.withValues(alpha: 0.2),
          ),
        ),

        // ═══════════════════════════════════════════
        // LOWER-MIDDLE SECTION
        // ═══════════════════════════════════════════
        Positioned(
          bottom: (AppMedia.height * 0.25),
          right: (AppMedia.width * -0.05),
          child: _CircleOutline(
            diameter: (AppMedia.width * 0.2),
            color: AppTheme.c.primary.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          bottom: (AppMedia.height * 0.22),
          left: (AppMedia.width * 0.1),
          child: _Circle(
            diameter: (AppMedia.width * 0.035),
            color: AppTheme.c.primary.withValues(alpha: 0.18),
          ),
        ),

        // ═══════════════════════════════════════════
        // BOTTOM SECTION - Larger background circles
        // ═══════════════════════════════════════════
        Positioned(
          bottom: (AppMedia.width * -0.15),
          left: (AppMedia.width * -0.18),
          child: _GradientCircle(
            diameter: (AppMedia.width * 0.55),
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.1),
              AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.04),
            ],
          ),
        ),
        Positioned(
          bottom: (AppMedia.width * -0.12),
          right: (AppMedia.width * -0.15),
          child: _GradientCircle(
            diameter: (AppMedia.width * 0.5),
            colors: [
              AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.08),
              AppTheme.c.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
        Positioned(
          bottom: (AppMedia.width * 0.1),
          left: (AppMedia.width * 0.25),
          child: _CircleOutline(
            diameter: (AppMedia.width * 0.15),
            color: AppTheme.c.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: (AppMedia.width * 0.05),
          right: (AppMedia.width * 0.2),
          child: _DottedCircle(
            diameter: (AppMedia.width * 0.08),
            color: AppTheme.c.primary.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          bottom: (AppMedia.height * 0.02),
          left: (AppMedia.width * 0.5),
          child: _Circle(
            diameter: (AppMedia.width * 0.03),
            color: AppTheme.c.primary.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

/// Filled circle with solid color
class _Circle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _Circle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Circle with gradient fill
class _GradientCircle extends StatelessWidget {
  final double diameter;
  final List<Color> colors;

  const _GradientCircle({required this.diameter, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
    );
  }
}

/// Outlined circle (ring)
class _CircleOutline extends StatelessWidget {
  final double diameter;
  final Color color;

  const _CircleOutline({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5.un()),
      ),
    );
  }
}

/// Dotted/dashed circle outline
class _DottedCircle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _DottedCircle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _DottedCirclePainter(color: color),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;

  _DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const dashCount = 20;
    const dashLength = 0.12; // Fraction of circumference per dash

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i / dashCount) * 2 * 3.14159;
      final sweepAngle = dashLength * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small decorative circle — used inside the navigation bar and other compact areas.
class NavDecorativeCircle extends StatelessWidget {
  final double diameter;
  final Color color;
  final bool isOutline;

  const NavDecorativeCircle({
    super.key,
    required this.diameter,
    required this.color,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOutline ? Colors.transparent : color,
        border: isOutline ? Border.all(color: color, width: 1.5) : null,
      ),
    );
  }
}

/// Decorative circle layout for the bottom navigation bar.
class NavBarDecorativeCircles extends StatelessWidget {
  const NavBarDecorativeCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -18.un(),
          left: -12.un(),
          child: NavDecorativeCircle(
            diameter: 48.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -10.un(),
          right: 40.un(),
          child: NavDecorativeCircle(
            diameter: 32.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.14),
          ),
        ),
        Positioned(
          top: 6.un(),
          right: -8.un(),
          child: NavDecorativeCircle(
            diameter: 36.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.1),
            isOutline: true,
          ),
        ),
        Positioned(
          bottom: -6.un(),
          left: 60.un(),
          child: NavDecorativeCircle(
            diameter: 20.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.15),
          ),
        ),
        Positioned(
          top: 2.un(),
          left: (AppMedia.width * 0.4),
          child: NavDecorativeCircle(
            diameter: 14.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.7).withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          bottom: 4.un(),
          right: -6.un(),
          child: NavDecorativeCircle(
            diameter: 28.un(),
            color: AppTheme.c.primary.withValues(alpha: 0.1),
            isOutline: true,
          ),
        ),
      ],
    );
  }
}
