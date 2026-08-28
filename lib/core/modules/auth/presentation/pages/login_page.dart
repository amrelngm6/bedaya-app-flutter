import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/divider.dart';
import 'package:bedaya2/presentation/widgets/main-navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    sl.analytics.trackScreen('LoginPage');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        handleError: () {},
        handleResponse: () async {
        },
      );
    }
  }

  // ─── Validators ────────────────────────────────────────────────────────────

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'auth_required'.tr();
    if (v.trim().length < 8) return 'auth_invalid_phone'.tr();
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'auth_required'.tr();
    if (v.length < 6) return 'auth_password_too_short'.tr();
    return null;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context, bool loading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth_no_account'.tr(),
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: loading
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryTeal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'auth_register'.tr(),
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthAuthenticated ||
            (curr is AuthFailure && prev is AuthLoading),
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Redirect to MainNaviationPage or pop the login page if already logged in
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationPage(),
              ),
              (route) => false, // This condition clears the entire history
            );
          } else if (state is AuthFailure) {
            _showError(context, state.message);
          }
        },
        buildWhen: (prev, curr) =>
            curr is AuthLoading ||
            curr is AuthAuthenticated ||
            curr is AuthUnauthenticated ||
            curr is AuthFailure,
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Column(
            children: [
              AuthGradientHeader(
                title: 'auth_login'.tr(),
                subtitle: 'auth_sign_in_subtitle'.tr(),
                iconData: Icons.medical_services_rounded,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // ── Phone ──────────────────────────────────────
                          AuthTextField(
                            label: 'auth_phone'.tr(),
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: _validatePhone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            onFieldSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                            enabled: !loading,
                          ),
                          const SizedBox(height: 16),

                          // ── Password ───────────────────────────────────
                          AuthTextField(
                            label: 'auth_password'.tr(),
                            controller: _passwordCtrl,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: _validatePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            focusNode: _passwordFocus,
                            onFieldSubmitted: (_) => _submit(),
                            enabled: !loading,
                          ),
                          const SizedBox(height: 6),

                          // ── Forgot password link ────────────────────────
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryTeal,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'auth_forgot_password'.tr(),
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Login button ────────────────────────────────
                          AuthPrimaryButton(
                            label: 'auth_login'.tr(),
                            onPressed: _submit,
                            isLoading: loading,
                          ),
                          const SizedBox(height: 24),

                          CustomDivider(label: 'or'.tr()),
                          const SizedBox(height: 20),

                          // ── Register link ───────────────────────────────
                          _buildRegisterLink(context, loading),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
