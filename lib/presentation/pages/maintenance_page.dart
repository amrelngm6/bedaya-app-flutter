import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

/// Shown when [AppRemoteConfig.maintenanceMode] is `true`.
///
/// Displays a friendly message and the support contact details
/// fetched from the remote configuration.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = sl.appConfig.current;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Illustration ──────────────────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  size: 64,
                  color: AppColors.primaryTeal,
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'maintenance_title'.tr(),
                style: AppStyles.h2.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ── Message ───────────────────────────────────────────────────
              Text(
                'maintenance_message'.tr(),
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ── Support contacts (if available) ───────────────────────────
              if (config.supportEmail != null ||
                  config.supportPhone != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'contact_support'.tr(),
                        style: AppStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (config.supportEmail != null)
                        _ContactRow(
                          icon: Icons.email_outlined,
                          text: config.supportEmail!,
                        ),
                      if (config.supportEmail != null &&
                          config.supportPhone != null)
                        const SizedBox(height: 8),
                      if (config.supportPhone != null)
                        _ContactRow(
                          icon: Icons.phone_outlined,
                          text: config.supportPhone!,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
