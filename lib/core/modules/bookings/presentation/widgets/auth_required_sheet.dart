import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthRequiredSheet extends StatelessWidget {
  final VoidCallback onNavigateToLogin;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onGoBack;

  const AuthRequiredSheet({super.key, 
    required this.onNavigateToLogin,
    required this.onNavigateToRegister,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                child: IconButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  onPressed: onGoBack,
                  icon: const Icon(Icons.close),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyOutline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Icon badge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Sign In Required'.tr(),
                      style: AppStyles.h2.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'Please log in or create an account to\ncomplete your appointment booking.'
                          .tr(),
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Inline feature pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeaturePill(
                          icon: Icons.calendar_month_outlined,
                          label: 'Book Easily'.tr(),
                        ),
                        const SizedBox(width: 10),
                        _FeaturePill(
                          icon: Icons.history_rounded,
                          label: 'Track History'.tr(),
                        ),
                        const SizedBox(width: 10),
                        _FeaturePill(
                          icon: Icons.notifications_outlined,
                          label: 'Reminders'.tr(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Log In button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onNavigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: AppColors.primaryTeal.withValues(
                            alpha: 0.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Log In'.tr(),
                          style: AppStyles.buttonText.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Create Account button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onNavigateToRegister,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                          side: const BorderSide(
                            color: AppColors.primaryTeal,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Create Account'.tr(),
                          style: AppStyles.buttonText.copyWith(
                            fontSize: 16,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Go back link
                    GestureDetector(
                      onTap: onGoBack,
                      child: Text(
                        'Go Back'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkTeal),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.darkTeal,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
