import 'package:flutter/material.dart';
import 'dart:math' as math;

class BabyGrowthAnimationWidget extends StatefulWidget {
  final int weeksPregnant;
  final double size;

  const BabyGrowthAnimationWidget({
    super.key,
    required this.weeksPregnant,
    this.size = 200,
  });

  @override
  State<BabyGrowthAnimationWidget> createState() =>
      _BabyGrowthAnimationWidgetState();
}

class _BabyGrowthAnimationWidgetState extends State<BabyGrowthAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation for heartbeat effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Gentle rotation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Color _getBabyColor() {
    if (widget.weeksPregnant < 12) {
      return const Color(0xFFFFA7C4); // Pink for first trimester
    } else if (widget.weeksPregnant < 27) {
      return const Color(0xFFFFB347); // Orange for second trimester
    } else {
      return const Color(0xFF87CEEB); // Blue for third trimester
    }
  }

  double _getBabyScale() {
    // Scale baby from 0.3 to 1.0 based on weeks
    return (0.3 + (widget.weeksPregnant / 40) * 0.7).clamp(0.3, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _pulseController,
        _rotateController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getBabyColor().withValues(alpha: 0.1),
                      _getBabyColor().withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: Size(
                      widget.size * _getBabyScale(),
                      widget.size * _getBabyScale(),
                    ),
                    painter: BabyPainter(
                      weeksPregnant: widget.weeksPregnant,
                      color: _getBabyColor(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BabyPainter extends CustomPainter {
  final int weeksPregnant;
  final Color color;

  BabyPainter({required this.weeksPregnant, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    if (weeksPregnant < 8) {
      // Early stage - simple circle/blob
      canvas.drawCircle(center, size.width * 0.3, paint);
      canvas.drawCircle(center, size.width * 0.3, outlinePaint);
    } else if (weeksPregnant < 16) {
      // Developing - head and body
      // Head
      canvas.drawCircle(
        Offset(center.dx, center.dy - size.height * 0.15),
        size.width * 0.25,
        paint,
      );
      // Body
      final bodyPath = Path();
      bodyPath.addOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.1),
          width: size.width * 0.35,
          height: size.height * 0.45,
        ),
      );
      canvas.drawPath(bodyPath, paint);

      // Add sweet details - eyes
      final eyePaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.18),
        size.width * 0.04,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.08, center.dy - size.height * 0.18),
        size.width * 0.04,
        eyePaint,
      );
    } else if (weeksPregnant < 28) {
      // Mid-stage - more defined features
      // Head
      canvas.drawCircle(
        Offset(center.dx, center.dy - size.height * 0.2),
        size.width * 0.28,
        paint,
      );

      // Body
      final bodyPath = Path();
      bodyPath.moveTo(
        center.dx - size.width * 0.22,
        center.dy - size.height * 0.05,
      );
      bodyPath.quadraticBezierTo(
        center.dx - size.width * 0.25,
        center.dy + size.height * 0.1,
        center.dx - size.width * 0.15,
        center.dy + size.height * 0.25,
      );
      bodyPath.lineTo(
        center.dx + size.width * 0.15,
        center.dy + size.height * 0.25,
      );
      bodyPath.quadraticBezierTo(
        center.dx + size.width * 0.25,
        center.dy + size.height * 0.1,
        center.dx + size.width * 0.22,
        center.dy - size.height * 0.05,
      );
      bodyPath.close();
      canvas.drawPath(bodyPath, paint);

      // Arms
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.28, center.dy + size.height * 0.05),
        size.width * 0.08,
        paint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.28, center.dy + size.height * 0.05),
        size.width * 0.08,
        paint,
      );

      // Legs
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - size.width * 0.1,
            center.dy + size.height * 0.35,
          ),
          width: size.width * 0.12,
          height: size.height * 0.15,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx + size.width * 0.1,
            center.dy + size.height * 0.35,
          ),
          width: size.width * 0.12,
          height: size.height * 0.15,
        ),
        paint,
      );

      // Facial features
      final eyePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.1, center.dy - size.height * 0.22),
        size.width * 0.05,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.1, center.dy - size.height * 0.22),
        size.width * 0.05,
        eyePaint,
      );

      // Smile
      final smilePath = Path();
      smilePath.moveTo(
        center.dx - size.width * 0.08,
        center.dy - size.height * 0.12,
      );
      smilePath.quadraticBezierTo(
        center.dx,
        center.dy - size.height * 0.08,
        center.dx + size.width * 0.08,
        center.dy - size.height * 0.12,
      );
      canvas.drawPath(
        smilePath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Late stage - fully formed baby
      // Head
      canvas.drawCircle(
        Offset(center.dx, center.dy - size.height * 0.22),
        size.width * 0.3,
        paint,
      );

      // Body
      final bodyPath = Path();
      bodyPath.moveTo(
        center.dx - size.width * 0.25,
        center.dy - size.height * 0.05,
      );
      bodyPath.quadraticBezierTo(
        center.dx - size.width * 0.28,
        center.dy + size.height * 0.15,
        center.dx - size.width * 0.18,
        center.dy + size.height * 0.28,
      );
      bodyPath.lineTo(
        center.dx + size.width * 0.18,
        center.dy + size.height * 0.28,
      );
      bodyPath.quadraticBezierTo(
        center.dx + size.width * 0.28,
        center.dy + size.height * 0.15,
        center.dx + size.width * 0.25,
        center.dy - size.height * 0.05,
      );
      bodyPath.close();
      canvas.drawPath(bodyPath, paint);

      // Arms
      final armPath1 = Path();
      armPath1.moveTo(center.dx - size.width * 0.25, center.dy);
      armPath1.quadraticBezierTo(
        center.dx - size.width * 0.35,
        center.dy + size.height * 0.08,
        center.dx - size.width * 0.32,
        center.dy + size.height * 0.18,
      );
      canvas.drawPath(
        armPath1,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.15
          ..strokeCap = StrokeCap.round,
      );

      final armPath2 = Path();
      armPath2.moveTo(center.dx + size.width * 0.25, center.dy);
      armPath2.quadraticBezierTo(
        center.dx + size.width * 0.35,
        center.dy + size.height * 0.08,
        center.dx + size.width * 0.32,
        center.dy + size.height * 0.18,
      );
      canvas.drawPath(
        armPath2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.15
          ..strokeCap = StrokeCap.round,
      );

      // Legs
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - size.width * 0.12,
            center.dy + size.height * 0.38,
          ),
          width: size.width * 0.15,
          height: size.height * 0.2,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx + size.width * 0.12,
            center.dy + size.height * 0.38,
          ),
          width: size.width * 0.15,
          height: size.height * 0.2,
        ),
        paint,
      );

      // Detailed facial features
      final eyePaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.24),
        size.width * 0.06,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.24),
        size.width * 0.06,
        eyePaint,
      );

      // Pupils
      final pupilPaint = Paint()..color = color.withValues(alpha: 0.6);
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.24),
        size.width * 0.03,
        pupilPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.24),
        size.width * 0.03,
        pupilPaint,
      );

      // Smile
      final smilePath = Path();
      smilePath.moveTo(
        center.dx - size.width * 0.1,
        center.dy - size.height * 0.14,
      );
      smilePath.quadraticBezierTo(
        center.dx,
        center.dy - size.height * 0.09,
        center.dx + size.width * 0.1,
        center.dy - size.height * 0.14,
      );
      canvas.drawPath(
        smilePath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );

      // Rosy cheeks
      final cheekPaint = Paint()..color = Colors.pink.withValues(alpha: 0.3);
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.18, center.dy - size.height * 0.18),
        size.width * 0.08,
        cheekPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.18, center.dy - size.height * 0.18),
        size.width * 0.08,
        cheekPaint,
      );
    }

    // Add sparkles around baby
    _drawSparkles(canvas, center, size);
  }

  void _drawSparkles(Canvas canvas, Offset center, Size size) {
    final sparklePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final sparklePositions = [
      Offset(center.dx - size.width * 0.4, center.dy - size.height * 0.3),
      Offset(center.dx + size.width * 0.4, center.dy - size.height * 0.35),
      Offset(center.dx - size.width * 0.35, center.dy + size.height * 0.3),
      Offset(center.dx + size.width * 0.38, center.dy + size.height * 0.25),
    ];

    for (var pos in sparklePositions) {
      _drawSparkle(canvas, pos, size.width * 0.04, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final midAngle = angle + math.pi / 4;
      final midX = center.dx + math.cos(midAngle) * (size * 0.3);
      final midY = center.dy + math.sin(midAngle) * (size * 0.3);
      path.lineTo(midX, midY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BabyPainter oldDelegate) {
    return oldDelegate.weeksPregnant != weeksPregnant ||
        oldDelegate.color != color;
  }
}
