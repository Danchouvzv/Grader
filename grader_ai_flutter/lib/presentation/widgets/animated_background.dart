import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(_animation.value),
          child: widget.child,
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFF0F4F8),
          const Color(0xFFE3F2FD),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw floating circles
    final circlePaint = Paint()
      ..color = const Color(0xFF1976D2).withOpacity(0.05);

    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * 0.2 * (i + 1) + 
            50 * math.sin(animationValue + i * 0.5),
        size.height * 0.15 * (i + 1) + 
            30 * math.cos(animationValue + i * 0.7),
      );
      
      canvas.drawCircle(
        offset,
        20 + 10 * math.sin(animationValue + i),
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
