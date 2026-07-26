import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

/// Shown when [AppRemoteConfig.forceUpdateEnabled] is `true` and the running
/// app version is behind [AppRemoteConfig.minAppVersion].
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = sl.appConfig.current;
    final appName = config.appName ?? 'bedaya_hospital'.tr();

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
                  Icons.system_update_outlined,
                  size: 64,
                  color: AppColors.primaryTeal,
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'force_update_title'.tr(),
                style: AppStyles.h2.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ── Message ───────────────────────────────────────────────────
              Text(
                'force_update_message'.tr(args: [appName]),
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // ── Version info ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _VersionBadge(
                    label: 'your_version'.tr(),
                    version: AppConfig.currentVersion,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _VersionBadge(
                    label: 'required_version'.tr(),
                    version: config.minAppVersion,
                    color: AppColors.primaryTeal,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Update button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // The app store URL would come from config or a deep link;
                    // for now this is a placeholder.
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text('update_now'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({
    required this.label,
    required this.version,
    required this.color,
  });

  final String label;
  final String version;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'v$version',
            style: AppStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
