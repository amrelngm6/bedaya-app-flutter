import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../models/auth_models.dart';
import '../../../../network/network_result.dart';

// ─── OTP purpose ─────────────────────────────────────────────────────────────

enum OtpType {
  phoneVerification('phone_verification'),
  passwordReset('password_reset');

  const OtpType(this.value);
  final String value;
}

// ─── States ───────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

/// Startup — has not yet checked local storage.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A network call is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is authenticated and ready.
final class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

/// No valid session found.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Server accepted the request; OTP has been sent to [phone].
final class AuthOtpRequired extends AuthState {
  final String phone;
  final OtpType otpType;
  const AuthOtpRequired({required this.phone, required this.otpType});
}

/// OTP was verified for a password-reset flow; carry phone + otp forward.
final class AuthOtpVerified extends AuthState {
  final String phone;
  final String otp;
  const AuthOtpVerified({required this.phone, required this.otp});
}

/// Password was reset successfully.
final class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// An error occurred during any auth operation.
final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial()) {
    _checkInitialAuth();
  }

  // ─── Session restore ───────────────────────────────────────────────────────

  Future<void> _checkInitialAuth() async {
    if (!sl.storage.isLoggedIn) {
      emit(const AuthUnauthenticated());
      return;
    }
    final token = await sl.storage.getAccessToken();
    if (token == null || sl.storage.isAccessTokenExpired()) {
      emit(const AuthUnauthenticated());
      return;
    }
    final user = await sl.storage.getUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> login({
    required String phone,
    required String password,
    required Function handleResponse,
    Function? handleError,
  }) async {
    emit(const AuthLoading());
    final result = await sl.auth.login(
      LoginRequest(phone: phone, password: password),
    );
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data.user));
        // await handleResponse.call();
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
        // await handleError?.call();
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
  }) async {
    emit(const AuthLoading());
    final result = await sl.auth.register(
      RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        nationality: nationality ?? 'Egypt',
        password: password,
        passwordConfirmation: passwordConfirmation,
        gender: gender ?? 'female',
        dateOfBirth: dateOfBirth ?? DateTime(1980, 1, 1),
      ),
    );
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data.user));
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
    }
  }

  // ─── OTP verification ─────────────────────────────────────────────────────

  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required OtpType otpType,
  }) async {
    emit(const AuthLoading());
    final result = await sl.auth.verifyOtp(
      VerifyOtpRequest(phone: phone, otp: otp, type: otpType.value),
    );
    switch (result) {
      case Success():
        if (otpType == OtpType.phoneVerification) {
          // Token was already stored during register; just restore the user.
          final user = await sl.storage.getUser();
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            final profile = await sl.auth.getMyProfile();
            switch (profile) {
              case Success(:final data):
                emit(AuthAuthenticated(data));
              case Failure():
                emit(const AuthUnauthenticated());
            }
          }
        } else {
          // Password-reset flow: carry credentials to reset page.
          emit(AuthOtpVerified(phone: phone, otp: otp));
        }
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
    }
  }

  Future<void> resendOtp({
    required String phone,
    required OtpType otpType,
  }) async {
    emit(const AuthLoading());
    final result = await sl.auth.resendOtp(phone);
    switch (result) {
      case Success():
        emit(AuthOtpRequired(phone: phone, otpType: otpType));
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
    }
  }

  // ─── Forgot / reset password ──────────────────────────────────────────────

  Future<void> forgotPassword({required String phone}) async {
    emit(const AuthLoading());
    final result = await sl.auth.forgotPassword(
      ForgotPasswordRequest(phone: phone),
    );
    switch (result) {
      case Success():
        emit(AuthOtpRequired(phone: phone, otpType: OtpType.passwordReset));
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const AuthLoading());
    final result = await sl.auth.resetPassword(
      ResetPasswordRequest(
        phone: phone,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
    switch (result) {
      case Success():
        emit(const AuthPasswordResetSuccess());
      case Failure(:final exception):
        emit(AuthFailure(exception.message));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await sl.auth.logout();
    emit(const AuthUnauthenticated());
  }
}
