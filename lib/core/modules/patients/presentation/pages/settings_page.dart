import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/app_config.dart';
import '../../../../models/app_remote_config_model.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../../auth/presentation/cubits/app_config_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigCubit, AppConfigState>(
      builder: (context, state) {
        final config = context.read<AppConfigCubit>().current;
        return _SettingsBody(config: config);
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.config});

  final AppRemoteConfig config;

  @override
  Widget build(BuildContext context) {
    final appName = config.appName ?? 'bedaya_hospital'.tr();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        title: Text(
          'settings'.tr(),
          style: AppStyles.h3.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── General Section ─────────────────────────────────────────────
            _buildSectionHeader('general'.tr()),
            const SizedBox(height: 12),
            _buildSettingsCard([_buildLanguageSettingTile(context)]),

            const SizedBox(height: 32),

            // ── About Section ───────────────────────────────────────────────
            _buildSectionHeader('about'.tr()),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.info_outline,
                title: 'version'.tr(),
                subtitle: AppConfig.currentVersion,
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.language,
                title: 'current_language'.tr(),
                subtitle: context.locale.languageCode == 'ar'
                    ? 'arabic'.tr()
                    : 'english'.tr(),
              ),
            ]),

            // ── Support / Contact Section ────────────────────────────────────
            if (config.supportEmail != null || config.supportPhone != null) ...[
              const SizedBox(height: 32),
              _buildSectionHeader('contact_support'.tr()),
              const SizedBox(height: 12),
              _buildSettingsCard([
                if (config.supportEmail != null)
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'support_email'.tr(),
                    subtitle: config.supportEmail!,
                  ),
                if (config.supportEmail != null && config.supportPhone != null)
                  _buildDivider(),
                if (config.supportPhone != null)
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'support_phone'.tr(),
                    subtitle: config.supportPhone!,
                  ),
              ]),
            ],

            // ── Payments Section ─────────────────────────────────────────────
            if (config.paymentEnabled) ...[
              const SizedBox(height: 32),
              _buildSectionHeader('payment_settings'.tr()),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildInfoTile(
                  icon: Icons.attach_money_outlined,
                  title: 'currency'.tr(),
                  subtitle: '${config.currencyCode}  ${config.currencySymbol}',
                ),
              ]),
            ],

            // ── Security Section ─────────────────────────────────────────────
            const SizedBox(height: 32),
            _buildSectionHeader('security_settings'.tr()),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildToggleInfoTile(
                icon: Icons.fingerprint,
                title: 'biometric_login'.tr(),
                enabled: config.biometricLoginEnabled,
              ),
              _buildDivider(),
              _buildToggleInfoTile(
                icon: Icons.notifications_outlined,
                title: 'push_notifications'.tr(),
                enabled: config.pushNotificationsEnabled,
              ),
            ]),

            const SizedBox(height: 32),

            // ── App Branding Info ────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appName,
                    style: AppStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'version'.tr()} ${AppConfig.currentVersion}',
                    style: AppStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageSettingTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.language,
          color: AppColors.primaryTeal,
          size: 24,
        ),
      ),
      title: Text(
        'language'.tr(),
        style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        context.locale.languageCode == 'ar' ? 'arabic'.tr() : 'english'.tr(),
        style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 24),
      ),
      title: Text(
        title,
        style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildToggleInfoTile({
    required IconData icon,
    required String title,
    required bool enabled,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 24),
      ),
      title: Text(
        title,
        style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.onlineGreen.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          enabled ? 'enabled'.tr() : 'disabled'.tr(),
          style: AppStyles.bodySmall.copyWith(
            color: enabled ? AppColors.onlineGreen : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.greyOutline.withValues(alpha: 0.3),
      indent: 72,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('choose_language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('english'.tr()),
                trailing: context.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const Text('eg', style: TextStyle(fontSize: 24)),
                title: Text('arabic'.tr()),
                trailing: context.locale.languageCode == 'ar'
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'cancel'.tr(),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.scaffoldBackground,
    appBar: AppBar(
      backgroundColor: AppColors.primaryTeal,
      title: Text(
        'settings'.tr(),
        style: AppStyles.h3.copyWith(color: Colors.white),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Section
          _buildSectionHeader('general'.tr()),
          const SizedBox(height: 12),
          _buildSettingsCard([_buildLanguageSettingTile(context)]),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader('about'.tr()),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'version'.tr(),
              subtitle: AppConfig.currentVersion,
            ),
            _buildDivider(),
            _buildInfoTile(
              icon: Icons.language,
              title: 'current_language'.tr(),
              subtitle: context.locale.languageCode == 'ar'
                  ? 'arabic'.tr()
                  : 'english'.tr(),
            ),
          ]),

          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 40,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'bedaya_hospital'.tr(),
                  style: AppStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${'version'.tr()} ${AppConfig.currentVersion}',
                  style: AppStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      title.toUpperCase(),
      style: AppStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );
}

Widget _buildSettingsCard(List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

Widget _buildLanguageSettingTile(BuildContext context) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.language, color: AppColors.primaryTeal, size: 24),
    ),
    title: Text(
      'language'.tr(),
      style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      context.locale.languageCode == 'ar' ? 'arabic'.tr() : 'english'.tr(),
      style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    onTap: () => _showLanguageDialog(context),
  );
}

Widget _buildInfoTile({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primaryTeal, size: 24),
    ),
    title: Text(
      title,
      style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      subtitle,
      style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
  );
}

Widget _buildDivider() {
  return Divider(
    height: 1,
    color: AppColors.greyOutline.withValues(alpha: 0.3),
    indent: 72,
  );
}

void _showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('choose_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text('english'.tr()),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primaryTeal)
                  : null,
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Text('eg', style: TextStyle(fontSize: 24)),
              title: Text('arabic'.tr()),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: AppColors.primaryTeal)
                  : null,
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    },
  );
}
