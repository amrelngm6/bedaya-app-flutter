import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/colors.dart';
import '../pages/pregnancy_calculator_page.dart';

class PregnancyCalculatorBanner extends StatefulWidget {
  const PregnancyCalculatorBanner({super.key});

  @override
  State<PregnancyCalculatorBanner> createState() =>
      _PregnancyCalculatorBannerState();
}

class _PregnancyCalculatorBannerState extends State<PregnancyCalculatorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PregnancyCalculatorPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFE4F3),
              const Color(0xFFE8F5FF),
              const Color(0xFFFFF3E0),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB3D9).withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF81D4FA).withValues(alpha: 0.3),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Track Your Baby\'s Journey'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Calculate your due date and watch your baby grow'
                              .tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryPurple,
                                AppColors.primaryPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Start Calculator'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildBabyIllustration(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFB3D9).withValues(alpha: 0.3),
            const Color(0xFFFFB3D9).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Baby illustration
            CustomPaint(
              size: const Size(80, 80),
              painter: SimpleBabyPainter(color: const Color(0xFFFFB3D9)),
            ),
            // Sparkles
            Positioned(
              top: 10,
              right: 15,
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFFFFA726).withValues(alpha: 0.6),
                size: 16,
              ),
            ),
            Positioned(
              bottom: 15,
              left: 10,
              child: Icon(
                Icons.favorite,
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleBabyPainter extends CustomPainter {
  final Color color;

  SimpleBabyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

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
        center: Offset(center.dx, center.dy + size.height * 0.15),
        width: size.width * 0.35,
        height: size.height * 0.4,
      ),
    );
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
        height: size.height * 0.12,
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
        height: size.height * 0.12,
      ),
      paint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
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

    // Smile
    final smilePath = Path();
    smilePath.moveTo(
      center.dx - size.width * 0.08,
      center.dy - size.height * 0.08,
    );
    smilePath.quadraticBezierTo(
      center.dx,
      center.dy - size.height * 0.05,
      center.dx + size.width * 0.08,
      center.dy - size.height * 0.08,
    );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(SimpleBabyPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
