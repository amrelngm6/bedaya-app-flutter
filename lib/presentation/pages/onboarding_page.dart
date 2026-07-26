import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/presentation/pages/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.psychology,
      title: 'AI-Powered Fertility Consultant',
      description:
          'Get instant answers to your fertility questions with our intelligent AI chatbot, available 24/7',
      gradient: [AppColors.primaryTeal, AppColors.darkTeal],
      features: [
        'Instant medical guidance',
        'Personalized recommendations',
        'Available anytime, anywhere',
      ],
    ),
    OnboardingSlide(
      icon: Icons.qr_code_scanner,
      title: 'Smart Booking & Queue System',
      description:
          'Book appointments effortlessly and skip the wait with our QR code-based queue management',
      gradient: [AppColors.darkTeal, Color(0xFF7B2CBF)],
      features: [
        'Quick appointment booking',
        'QR code check-in',
        'Real-time queue updates',
      ],
    ),
    OnboardingSlide(
      icon: Icons.pregnant_woman,
      title: 'Pregnancy Calculator & Tracking',
      description:
          'Track your pregnancy journey with accurate calculators and personalized milestone tracking',
      gradient: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
      features: [
        'Due date calculator',
        'Week-by-week guidance',
        'Milestone notifications',
      ],
    ),
    OnboardingSlide(
      icon: Icons.medical_services,
      title: 'Expert IVF Specialists',
      description:
          'Access top fertility experts and stay informed with curated articles and educational content',
      gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      features: [
        'Renowned IVF specialists',
        'Educational articles',
        'Treatment insights',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip'.tr(),
                    style: AppStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primaryTeal,
                  dotColor: AppColors.greyOutline,
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 4,
                  spacing: 8,
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage < _slides.length - 1
                        ? AppColors.primaryTeal
                        : AppColors.onlineGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentPage < _slides.length - 1
                        ? 'Next'.tr()
                        : 'Get Started'.tr(),
                    style: AppStyles.buttonText.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gradient icon container with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: slide.gradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: slide.gradient[0].withValues(alpha: 0.4),
                          spreadRadius: 5,
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(slide.icon, size: 90, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              slide.title.tr(),
              style: AppStyles.h1.copyWith(fontSize: 20, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              slide.description.tr(),
              style: AppStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Features list
            ...slide.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: slide.gradient),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final List<String> features;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.features,
  });
}
