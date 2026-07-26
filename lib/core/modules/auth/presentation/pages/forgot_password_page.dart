import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/auth_cubit.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/auth_primary_button.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/auth_text_field.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().forgotPassword(phone: _phoneCtrl.text.trim());
    }
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'auth_required'.tr();
    if (v.trim().length < 8) return 'auth_invalid_phone'.tr();
    return null;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            (curr is AuthOtpRequired &&
                curr.otpType == OtpType.passwordReset) ||
            (curr is AuthFailure && prev is AuthLoading),
        listener: (context, state) {
          if (state is AuthOtpRequired &&
              state.otpType == OtpType.passwordReset) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(
                  phone: state.phone,
                  otpType: state.otpType,
                ),
              ),
            );
          } else if (state is AuthFailure) {
            _showError(context, state.message);
          }
        },
        buildWhen: (prev, curr) =>
            curr is AuthLoading ||
            curr is AuthOtpRequired ||
            curr is AuthFailure,
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Column(
            children: [
              AuthGradientHeader(
                title: 'auth_forgot_title'.tr(),
                subtitle: 'auth_forgot_subtitle'.tr(),
                iconData: Icons.lock_reset_rounded,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Info card ──────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(16),
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
                                Icons.info_outline_rounded,
                                color: AppColors.primaryTeal,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'auth_forgot_subtitle'.tr(),
                                  style: AppStyles.bodySmall.copyWith(
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Phone field ────────────────────────────────────
                        AuthTextField(
                          label: 'auth_phone'.tr(),
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: _validatePhone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          onFieldSubmitted: (_) => _submit(),
                          enabled: !loading,
                        ),
                        const SizedBox(height: 32),

                        // ── Send code button ───────────────────────────────
                        AuthPrimaryButton(
                          label: 'auth_send_code'.tr(),
                          onPressed: _submit,
                          isLoading: loading,
                          icon: Icons.send_rounded,
                        ),
                        const SizedBox(height: 20),

                        // ── Back to login link ─────────────────────────────
                        Center(
                          child: TextButton.icon(
                            onPressed: loading
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                            ),
                            label: Text('auth_login'.tr()),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryTeal,
                            ),
                          ),
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
