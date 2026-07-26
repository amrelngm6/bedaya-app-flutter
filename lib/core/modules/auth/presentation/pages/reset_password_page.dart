import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.phone, required this.otp});

  final String phone;
  final String otp;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(
        phone: widget.phone,
        otp: widget.otp,
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      );
    }
  }

  // ─── Validators ────────────────────────────────────────────────────────────

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'auth_required'.tr();
    if (v.length < 8) return 'auth_password_too_short'.tr();
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'auth_required'.tr();
    if (v != _passwordCtrl.text) return 'auth_password_mismatch'.tr();
    return null;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthPasswordResetSuccess ||
            (curr is AuthFailure && prev is AuthLoading),
        listener: (context, state) {
          if (state is AuthPasswordResetSuccess) {
            _showSuccess(context);
            // After a short delay, navigate to login replacing this page.
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (r) => r.isFirst,
                );
              }
            });
          } else if (state is AuthFailure) {
            _showError(context, state.message);
          }
        },
        buildWhen: (prev, curr) =>
            curr is AuthLoading ||
            curr is AuthPasswordResetSuccess ||
            curr is AuthFailure,
        builder: (context, state) {
          final loading = state is AuthLoading;
          final done = state is AuthPasswordResetSuccess;

          return Column(
            children: [
              AuthGradientHeader(
                title: 'auth_reset_title'.tr(),
                iconData: Icons.lock_reset_rounded,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: done
                      ? _SuccessView()
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Password strength hints ────────────────────
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal.withValues(
                                    alpha: 0.06,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryTeal.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      color: AppColors.primaryTeal,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'auth_password_hint'.tr(),
                                        style: AppStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── New password ─────────────────────────────
                              AuthTextField(
                                label: 'auth_new_password'.tr(),
                                controller: _passwordCtrl,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: _validatePassword,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) =>
                                    _confirmFocus.requestFocus(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 16),

                              // ── Confirm password ─────────────────────────
                              AuthTextField(
                                label: 'auth_confirm_password'.tr(),
                                controller: _confirmCtrl,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: _validateConfirm,
                                focusNode: _confirmFocus,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) => _submit(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 32),

                              // ── Reset button ──────────────────────────────
                              AuthPrimaryButton(
                                label: 'auth_reset_button'.tr(),
                                onPressed: _submit,
                                isLoading: loading,
                                icon: Icons.check_circle_outline_rounded,
                              ),
                            ],
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

  void _showSuccess(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text('auth_password_reset_success'.tr()),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

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
}

// ─── Success view ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 50,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth_password_reset_success'.tr(),
          style: AppStyles.h3.copyWith(color: AppColors.darkTeal),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth_login'.tr(),
          style: AppStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
