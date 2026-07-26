import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_input_widget.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.phone,
    required this.otpType,
  });

  final String phone;
  final OtpType otpType;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const _resendSeconds = 60;

  final _otpKey = GlobalKey<_OtpInputWidgetState>();
  String _otp = '';
  int _countdown = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ─── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _countdown = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _verify() {
    if (_otp.length < 6) return;
    context.read<AuthCubit>().verifyOtp(
      phone: widget.phone,
      otp: _otp,
      otpType: widget.otpType,
    );
  }

  void _resend() {
    _otpKey.currentState?.dispose();
    _startTimer();
    context.read<AuthCubit>().resendOtp(
      phone: widget.phone,
      otpType: widget.otpType,
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthAuthenticated ||
            curr is AuthOtpVerified ||
            (curr is AuthFailure && prev is AuthLoading) ||
            (curr is AuthOtpRequired && prev is AuthLoading),
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Phone verified — go to root.
            Navigator.of(context).popUntil((r) => r.isFirst);
          } else if (state is AuthOtpVerified) {
            // Password-reset OTP verified — go to reset password.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ResetPasswordPage(phone: state.phone, otp: state.otp),
              ),
            );
          } else if (state is AuthFailure) {
            _showError(context, state.message);
          }
          // AuthOtpRequired on resend — timer already restarted.
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
                title: 'auth_otp_title'.tr(),
                subtitle: 'auth_otp_subtitle'.tr(),
                iconData: Icons.verified_user_outlined,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Sent-to notice ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryTeal.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.smartphone_outlined,
                              color: AppColors.primaryTeal,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppStyles.bodySmall.copyWith(
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${'auth_otp_subtitle'.tr()} ',
                                    ),
                                    TextSpan(
                                      text: widget.phone,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── OTP boxes ────────────────────────────────────────
                      OtpInputWidget(
                        key: _otpKey,
                        onCompleted: (v) => setState(() => _otp = v),
                        onChanged: (v) => setState(() => _otp = v),
                        enabled: !loading,
                      ),
                      const SizedBox(height: 36),

                      // ── Verify button ────────────────────────────────────
                      AuthPrimaryButton(
                        label: 'auth_verify'.tr(),
                        onPressed: _otp.length == 6 ? _verify : null,
                        isLoading: loading,
                        enabled: _otp.length == 6,
                      ),
                      const SizedBox(height: 28),

                      // ── Resend row ───────────────────────────────────────
                      _ResendRow(
                        countdown: _countdown,
                        onResend: _resend,
                        enabled: !loading,
                      ),
                    ],
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

// ─── Resend row ───────────────────────────────────────────────────────────────

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.countdown,
    required this.onResend,
    required this.enabled,
  });
  final int countdown;
  final VoidCallback onResend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canResend = countdown == 0 && enabled;
    return Column(
      children: [
        Text(
          'auth_otp_expired_resend'.tr(),
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        if (countdown > 0)
          Text(
            'auth_resend_in'.tr(namedArgs: {'seconds': '$countdown'}),
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          GestureDetector(
            onTap: canResend ? onResend : null,
            child: Text(
              'auth_resend_otp'.tr(),
              style: AppStyles.bodySmall.copyWith(
                color: canResend
                    ? AppColors.primaryTeal
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                decoration: canResend ? TextDecoration.underline : null,
                decorationColor: AppColors.primaryTeal,
              ),
            ),
          ),
      ],
    );
  }
}

// ignore: library_private_types_in_public_api
typedef _OtpInputWidgetState = State<OtpInputWidget>;
