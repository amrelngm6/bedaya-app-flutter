import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/auth_select_field.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/divider.dart';
import 'package:bedaya2/core/modules/auth/presentation/widgets/login_link.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/presentation/widgets/main-navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedaya2/core/theme/colors.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Countries List
  List<String> countries = sl.auth.countriesList();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();

  // Focus nodes
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _nationalityFocus = FocusNode();

  // Form values
  // String _gender = '';
  // DateTime? _dateOfBirth;
  String _selectedNationality = 'Egypt';

  @override
  void initState() {
    super.initState();
    sl.analytics.trackScreen('RegisterPage');
    countries = sl.auth.countriesList();
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
      _nationalityCtrl,
    ]) {
      c.dispose();
    }
    for (final f in [
      _lastNameFocus,
      _phoneFocus,
      _emailFocus,
      _passwordFocus,
      _confirmFocus,
      _nationalityFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // if (_gender.isEmpty) {
      //   _showError(context, 'auth_select_gender'.tr());
      //   return;
      // }
      context.read<AuthCubit>().register(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        nationality: _selectedNationality,
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
        // gender: _gender,
        // dateOfBirth: _dateOfBirth!,
      );
    }
  }

  // ─── Validators ───────────────────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'auth_required'.tr() : null;

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'auth_required'.tr();
    if (v.trim().length < 8) return 'auth_invalid_phone'.tr();
    return null;
  }

  // String? _validateEmail(String? v) {
  //   if (v == null || v.trim().isEmpty) return 'auth_required'.tr();
  //   if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
  //     return 'auth_invalid_email'.tr();
  //   }
  //   return null;
  // }

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

  Future<String?> _validatePhoneAPI(String? v) async {
    if (v == null || v.trim().isEmpty) return null;
    final result = await sl.auth.checkPhoneExists(v.trim());
    switch (result) {
      case Success(:final data):
        if (data.message == 'true') return 'auth_phone_exists'.tr();
        return null;
      case Failure(:final exception):
        return exception.message.tr();
    }
  }

  bool emailChecked = false;

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthOtpRequired ||
            curr is AuthAuthenticated ||
            (curr is AuthFailure && prev is AuthLoading),
        listener: (context, state) {
          if (state is AuthOtpRequired &&
              state.otpType == OtpType.phoneVerification) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(
                  phone: state.phone,
                  otpType: state.otpType,
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
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
            curr is AuthOtpRequired ||
            curr is AuthFailure,
        builder: (context, state) {
          final loading = state is AuthLoading;
          return emailChecked == false
              ? Column(
                  children: [
                    AuthGradientHeader(
                      title: 'auth_register'.tr(),
                      subtitle: 'auth_register_subtitle'.tr(),
                      iconData: Icons.person_add_rounded,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),

                              // ── Phone ──────────────────────────────────────────
                              AuthTextField(
                                label: 'auth_phone'.tr(),
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: _validatePhone,
                                focusNode: _phoneFocus,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                onFieldSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 14),

                              // ── Register button ────────────────────────────────
                              AuthPrimaryButton(
                                label: 'auth_register'.tr(),
                                onPressed: () async {
                                  if (_validatePhone(_phoneCtrl.text) != null) {
                                    return;
                                  }
                                  final validatePhone = await _validatePhoneAPI(
                                    _phoneCtrl.text,
                                  );

                                  if (validatePhone != null) {
                                    _showError(context, validatePhone);
                                    return;
                                  }

                                  setState(() => emailChecked = true);
                                },
                                isLoading: loading,
                                icon: Icons.person_add_rounded,
                              ),
                              const SizedBox(height: 24),

                              CustomDivider(label: 'or'.tr()),
                              const SizedBox(height: 20),

                              // ── Register link ───────────────────────────────
                              buildLoginLink(context, loading),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    AuthGradientHeader(
                      title: 'auth_register'.tr(),
                      subtitle: 'auth_register_subtitle'.tr(),
                      iconData: Icons.person_add_rounded,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),

                              // ── Name row ───────────────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: AuthTextField(
                                      label: 'auth_first_name'.tr(),
                                      controller: _firstNameCtrl,
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator: _required,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _lastNameFocus.requestFocus(),
                                      enabled: !loading,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AuthTextField(
                                      label: 'auth_last_name'.tr(),
                                      controller: _lastNameCtrl,
                                      validator: _required,
                                      focusNode: _lastNameFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _phoneFocus.requestFocus(),
                                      enabled: !loading,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // ── Nationality (Dropdown) ─────────────────────────────────────────────
                              AuthSelectField(
                                label: 'Nationality'.tr(),
                                value: _selectedNationality,
                                onChanged: (value) {
                                  setState(() => _selectedNationality = value);
                                },
                                items: countries
                                    .map(
                                      (country) => DropdownMenuItem(
                                        value: country,
                                        child: Text(country),
                                      ),
                                    )
                                    .toList(),

                                focusNode: _phoneFocus,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                onFieldSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 14),

                              // ── Phone ──────────────────────────────────────────
                              AuthTextField(
                                label: 'auth_phone'.tr(),
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: _validatePhone,
                                focusNode: _phoneFocus,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                onFieldSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 14),

                              // ── Password ───────────────────────────────────────
                              AuthTextField(
                                label: 'auth_password'.tr(),
                                hint: 'auth_password_hint'.tr(),
                                controller: _passwordCtrl,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: _validatePassword,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) =>
                                    _confirmFocus.requestFocus(),
                                enabled: !loading,
                              ),
                              const SizedBox(height: 14),

                              // ── Confirm password ───────────────────────────────
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
                              const SizedBox(height: 20),

                              // ── Register button ────────────────────────────────
                              AuthPrimaryButton(
                                label: 'auth_register'.tr(),
                                onPressed: _submit,
                                isLoading: loading,
                                icon: Icons.person_add_rounded,
                              ),
                              const SizedBox(height: 24),
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

// ─── DOB picker ───────────────────────────────────────────────────────────────

class DateOfBirthPicker extends StatelessWidget {
  const DateOfBirthPicker({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final DateTime? selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = selected != null
        ? DateFormat('dd / MM / yyyy').format(selected!)
        : 'auth_select_dob'.tr();

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F8),
          border: Border.all(
            color: selected != null
                ? AppColors.primaryTeal.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              size: 20,
              color: selected != null
                  ? AppColors.primaryTeal
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted,
                style: TextStyle(
                  fontSize: 14,
                  color: selected != null
                      ? AppColors.darkTeal
                      : Colors.grey.shade400,
                  fontWeight: selected != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
