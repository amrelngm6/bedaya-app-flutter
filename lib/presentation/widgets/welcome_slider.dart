import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:bedaya2/core/theme/colors.dart';

class WelcomeSlider extends StatefulWidget {
  final List<SlideData> slides;
  final double height;
  final Duration animationDuration;
  final Duration autoPlayDuration;
  final bool autoPlay;

  const WelcomeSlider({
    super.key,
    required this.slides,
    this.height = 200,
    this.animationDuration = const Duration(milliseconds: 800),
    this.autoPlayDuration = const Duration(seconds: 6),
    this.autoPlay = false,
  });

  @override
  State<WelcomeSlider> createState() => _WelcomeSliderState();
}

class _WelcomeSliderState extends State<WelcomeSlider>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;
  late AnimationController _textAnimationController;
  late AnimationController _imageAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Start initial animations
    _animationController.forward();
    _textAnimationController.forward();
    _imageAnimationController.forward();

    // Auto play if enabled
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayDuration, () {
      if (mounted && widget.autoPlay) {
        final nextPage = (_currentPage + 1) % widget.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _textAnimationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Restart animations for new page
    _textAnimationController.reset();
    _imageAnimationController.reset();
    _animationController.reset();

    Future.delayed(const Duration(milliseconds: 100), () {
      _textAnimationController.forward();
      _imageAnimationController.forward();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Main PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(widget.slides[index], index);
            },
          ),

          // Page Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(SlideData slide, int index) {
    final isCurrentPage = index == _currentPage;

    return GestureDetector(
      onTap: () => slide.onTap?.call(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background layer with animated pattern
                  _buildBackgroundPattern(slide),

                  // Content layer
                  _buildFramedImage(slide, isCurrentPage),

                  // Content layer
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 0,
                      bottom: 0,
                    ),
                    child: _buildTextContent(slide, isCurrentPage),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern(SlideData slide) {
    return Positioned(
      width: 400,
      height: 700,
      top: 0,
      right: context.locale == Locale('ar') ? 150 : 0,
      child: CustomPaint(
        painter: _BackgroundPatternPainter(
          animation: _animationController,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildTextContent(SlideData slide, bool isCurrentPage) {
    return AnimatedBuilder(
      animation: _textAnimationController,
      builder: (context, child) {
        final slideAnimation = CurvedAnimation(
          parent: _textAnimationController,
          curve: Curves.easeOutCubic,
        );

        return Transform.translate(
          offset: Offset(-50 * (1 - slideAnimation.value), 0),
          child: Opacity(
            opacity: slideAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: slide.textColor ?? Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: (slide.textColor ?? Colors.white).withValues(
                      alpha: 0.9,
                    ),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 20),

                // Button
                if (slide.buttonText != null) _buildActionButton(slide),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(SlideData slide) {
    return ElevatedButton(
      onPressed: slide.onButtonTap ?? slide.onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: slide.buttonColor ?? Colors.white,
        foregroundColor: slide.buttonTextColor ?? AppColors.primaryTeal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
      ),
      child: Text(
        slide.buttonText!.tr(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFramedImage(SlideData slide, bool isCurrentPage) {
    return AnimatedBuilder(
      animation: _imageAnimationController,
      builder: (context, child) {
        final scaleAnimation = CurvedAnimation(
          parent: _imageAnimationController,
          curve: Curves.elasticOut,
        );

        return Transform.scale(
          scale: 1.1 * (isCurrentPage ? scaleAnimation.value : 0.9),
          child: Container(
            decoration: BoxDecoration(
              color: slide.frameColor ?? Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color:
                    slide.frameBorderColor ??
                    Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              child: slide.image != null
                  ? Image.asset(
                      slide.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(slide);
                      },
                    )
                  : slide.imageWidget ?? _buildPlaceholderImage(slide),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage(SlideData slide) {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.medical_services_rounded,
          size: 60,
          color:
              slide.textColor?.withValues(alpha: 0.5) ??
              Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.slides.length,
        (index) => _buildPageIndicator(index),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Custom painter for animated background pattern
class _BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _BackgroundPatternPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw animated circles
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + i * 0.3) % 1.0;
      final radius = size.width * 0.3 * progress;
      final opacity = (1 - progress) * 0.3;

      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3),
        radius,
        paint..color = color.withValues(alpha: opacity),
      );
    }

    // Draw decorative shapes
    final rectPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width * 0.1, size.height * 0.7);
    canvas.rotate(math.pi / 4 * animation.value);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 40, height: 40),
        const Radius.circular(8),
      ),
      rectPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackgroundPatternPainter oldDelegate) => false;
}

// Data model for slide content
class SlideData {
  final String title;
  final String subtitle;
  final String? buttonText;
  final String? image;
  final Widget? imageWidget;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? frameColor;
  final Color? frameBorderColor;
  final VoidCallback? onTap;
  final VoidCallback? onButtonTap;

  const SlideData({
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.image,
    this.imageWidget,
    this.backgroundColor,
    this.backgroundGradient,
    this.textColor,
    this.buttonColor,
    this.buttonTextColor,
    this.frameColor,
    this.frameBorderColor,
    this.onTap,
    this.onButtonTap,
  });
}
