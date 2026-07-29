import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/modules/auth/models/auth_models.dart';
import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/bookings/presentation/pages/bookings_list_page.dart';
import 'package:bedaya2/core/modules/chat/presentation/pages/chat_rooms_page.dart';
import 'package:bedaya2/core/modules/invoices/presentation/pages/invoices_page.dart';
import 'package:bedaya2/core/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:bedaya2/core/modules/patients/presentation/pages/patient_profile_page.dart';
import 'package:bedaya2/core/modules/services/presentation/pages/services_list_page.dart';
import 'package:bedaya2/core/modules/videos/presentation/pages/video_reels_page.dart';
import 'package:bedaya2/core/modules/patients/presentation/pages/settings_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/presentation/widgets/main-navigation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/auth_cubit.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/doctors/presentation/pages/doctors_list_page.dart';

class SideMenuBottom extends StatelessWidget {
  final PatientModel? patient;
  const SideMenuBottom({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        UserModel? user = state is AuthAuthenticated ? state.user : null;
        return Drawer(
          backgroundColor: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _DrawerHeader(patient: patient),

              // ── Menu Items ──────────────────────────────────────────
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    (user != null)
                        ? _MenuItem(
                            icon: Icons.event_note_outlined,
                            label: 'Profile'.tr(),
                            onTap: () {
                              _navigate(
                                context,
                                PatientProfilePage(
                                  patient:
                                      patient ??
                                      PatientModel.fromJson(user.toJson()),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),

                    (user != null)
                        ? _MenuItem(
                            icon: Icons.inventory_outlined,
                            label: 'Invoices'.tr(),
                            onTap: () {
                              _navigate(context, InvoicesPage());
                            },
                          )
                        : const SizedBox.shrink(),

                    (user != null)
                        ? _MenuItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'appointments'.tr(),
                            onTap: () =>
                                _navigate(context, const BookingsListPage()),
                          )
                        : const SizedBox.shrink(),

                    _MenuItem(
                      icon: Icons.home_outlined,
                      label: 'Homepage'.tr(),
                      onTap: () => Navigator.pop(context),
                      badge: '',
                    ),

                    _MenuItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'doctors'.tr(),
                      onTap: () => _navigate(context, const DoctorsListPage()),
                    ),

                    _MenuItem(
                      icon: Icons.medical_services_outlined,
                      label: 'services'.tr(),
                      onTap: () => _navigate(context, const ServicesListPage()),
                    ),

                    _MenuItem(
                      icon: Icons.video_library_outlined,
                      label: 'videos'.tr(),
                      onTap: () => _navigate(context, const VideoReelsPage()),
                    ),
                    // _MenuItem(
                    //   icon: Icons.article_outlined,
                    //   label: 'articles'.tr(),
                    //   onTap: () => _navigate(context, const ArticlesListPage()),
                    // ),
                    const Divider(height: 24, indent: 16, endIndent: 16),

                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'settings'.tr(),
                      onTap: () => _navigate(context, const SettingsPage()),
                    ),

                    (user != null)
                        ? _MenuItem(
                            icon: Icons.chat_outlined,
                            label: 'support'.tr(),
                            onTap: () {
                              _navigate(context, ChatRoomsPage());
                            },
                          )
                        : const SizedBox.shrink(),
                    (user != null)
                        ? _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications'.tr(),
                            onTap: () {
                              _navigate(context, NotificationsPage());
                            },
                          )
                        : const SizedBox.shrink(),

                    // ── Auth section ────────────────────────────────
                    if (user != null)
                      _MenuItem(
                        icon: Icons.logout,
                        label: 'auth_logout'.tr(),
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () => _confirmLogout(context),
                      )
                    else ...[
                      _MenuItem(
                        icon: Icons.login,
                        label: 'auth_login'.tr(),
                        iconColor: AppColors.primaryTeal,
                        textColor: AppColors.primaryTeal,
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        icon: Icons.person_add_outlined,
                        label: 'auth_register'.tr(),
                        iconColor: AppColors.darkTeal,
                        textColor: AppColors.darkTeal,
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // ── Footer ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('bedaya_hospital'.tr(), style: AppStyles.bodySmall),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      (route) => false,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('auth_logout'.tr()),
        content: Text('auth_logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('auth_logout'.tr()),
          ),
        ],
      ),
    );
  }
}

// ── Custom header ────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.patient});

  final PatientModel? patient;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkTeal, AppColors.primaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPadding + 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          if (patient == null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                '${AppConfig.baseUrl}/images/white-logo.png',
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.local_hospital,
                  color: AppColors.darkTeal,
                  size: 48,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (patient != null) ...[
            // Avatar + name
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  backgroundImage: patient?.avatar != null
                      ? NetworkImage(
                          patient!.avatar!.contains('http')
                              ? patient!.avatar!
                              : '${AppConfig.baseUrl}/${patient!.avatar}',
                        )
                      : null,
                  child: patient?.avatar == null
                      ? Text(
                          (patient!.fullName).characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientProfilePage(
                            patient:
                                patient ??
                                PatientModel.fromJson(patient!.toJson()),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient!.fullName,
                          style: AppStyles.h3.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          patient!.email as String,
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'bedaya_hospital'.tr(),
              style: AppStyles.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'bedaya_hospital_tagline'.tr(),
              style: AppStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Reusable menu tile ────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.darkTeal;
    return ListTile(
      minVerticalPadding: 0,
      titleAlignment: ListTileTitleAlignment.center,
      style: ListTileStyle.drawer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(icon, color: color, size: 18),
      title: Row(
        children: [
          Text(
            label,
            style: AppStyles.bodyLarge.copyWith(
              color: textColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      horizontalTitleGap: 8,
    );
  }
}
