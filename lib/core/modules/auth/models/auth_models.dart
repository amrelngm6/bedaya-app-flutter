// ignore_for_file: dangling_library_doc_comments

import 'package:bedaya2/core/config/app_config.dart';
import 'dart:ui';

/// Authentication-related request and response models.
///
/// These mirror the JSON payloads sent to / received from the Laravel
/// backend.  All `fromJson` factories use safe casts to avoid runtime
/// exceptions on unexpected server changes.

// ─────────────────────────────────────────────────────────────────────────────
// Request models
// ─────────────────────────────────────────────────────────────────────────────

class LoginRequest {
  const LoginRequest({
    required this.phone,
    required this.password,
    this.deviceToken,
    this.deviceType,
  });

  final String phone;
  final String password;

  /// FCM or APNs token for push notifications (optional).
  final String? deviceToken;

  /// 'android' | 'ios' | 'web'
  final String? deviceType;

  Map<String, dynamic> toJson() => {
    'phone': phone.trim(),
    'password': password,
    if (deviceToken != null) 'device_token': deviceToken,
    if (deviceType != null) 'device_type': deviceType,
  };
}

class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.nationality,
    required this.password,
    required this.passwordConfirmation,
    required this.gender,
    required this.dateOfBirth,
    this.countryCode,
    this.deviceToken,
    this.deviceType,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String nationality;
  final String password;
  final String passwordConfirmation;
  final String? countryCode;

  /// 'male' | 'female'
  final String gender;
  final DateTime dateOfBirth;
  final String? deviceToken;
  final String? deviceType;

  Map<String, dynamic> toJson() => {
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    'phone': phone.trim(),
    'email': email.trim().toLowerCase(),
    'password': password,
    'password_confirmation': passwordConfirmation,
    'gender': gender,
    'nationality': nationality,
    'country_code': countryCode ?? getCountryCode(),
    'date_of_birth':
        '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
    if (deviceToken != null) 'device_token': deviceToken,
    if (deviceType != null) 'device_type': deviceType,
  };

  String getCountryCode() {
    return PlatformDispatcher.instance.locale.countryCode ?? 'Unknown';
  }
}

class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
    this.type = 'phone_verification',
  });

  /// The phone number the OTP was sent to.
  final String phone;
  final String otp;

  /// 'phone_verification' | 'password_reset'
  final String type;

  Map<String, dynamic> toJson() => {
    'phone': phone.trim(),
    'otp': otp.trim(),
    'type': type,
  };
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.phone});
  final String phone;
  Map<String, dynamic> toJson() => {'phone': phone.trim()};
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.phone,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  final String phone;
  final String otp;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
    'phone': phone.trim(),
    'otp': otp.trim(),
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}

class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'new_password': newPassword,
    'new_password_confirmation': newPasswordConfirmation,
  };
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.emergencyContactName,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final String? emergencyContactName;

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'first_name': firstName!.trim(),
    if (lastName != null) 'last_name': lastName!.trim(),
    if (email != null) 'email': email!.trim().toLowerCase(),
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null)
      'date_of_birth':
          '${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}',
    if (address != null) 'address': address!.trim(),
    if (emergencyContact != null) 'emergency_contact': emergencyContact!.trim(),
    if (emergencyContactName != null)
      'emergency_contact_name': emergencyContactName!.trim(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Response models
// ─────────────────────────────────────────────────────────────────────────────

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    this.expiresIn,
    this.refreshToken,
    this.refreshExpiresIn,
  });

  final String accessToken;
  final String tokenType;
  final int? expiresIn;
  final String? refreshToken;
  final int? refreshExpiresIn;
  final UserModel user;

  /// Absolute expiry derived from [expiresIn] (seconds from now).
  DateTime? get accessTokenExpiry => expiresIn != null
      ? DateTime.now().add(Duration(seconds: expiresIn!))
      : null;

  DateTime? get refreshTokenExpiry => refreshExpiresIn != null
      ? DateTime.now().add(Duration(seconds: refreshExpiresIn!))
      : null;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['tokens']['access_token'] as String,
    tokenType: json['tokens']['token_type'] as String? ?? 'Bearer',
    expiresIn: json['tokens']['expires_in'] as int?,
    refreshToken: json['tokens']['refresh_token'] as String?,
    refreshExpiresIn: json['tokens']['refresh_expires_in'] as int?,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nationality,
    this.email,
    this.avatar,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.emergencyContactName,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.createdAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String nationality;
  final String? email;
  final String? avatar;

  /// 'male' | 'female'
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final String? emergencyContactName;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? createdAt;

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String avatar = json['avatar'] as String? ?? '';
    if (avatar.isNotEmpty && !avatar.startsWith('http')) {
      avatar = '${AppConfig.baseUrl}/$avatar';
    }
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      avatar: avatar,
      gender: json['gender'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      address: json['address'] as String? ?? '',
      emergencyContact: json['emergency_contact'] as String? ?? '',
      emergencyContactName: json['emergency_contact_name'] as String? ?? '',
      isPhoneVerified: json['phone_verified_at'] != null,
      isEmailVerified: json['email_verified_at'] != null,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'nationality': nationality,
    if (email != null) 'email': email,
    if (avatar != null) 'avatar': avatar,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
    if (address != null) 'address': address,
    if (emergencyContact != null) 'emergency_contact': emergencyContact,
    if (emergencyContactName != null)
      'emergency_contact_name': emergencyContactName,
    'phone_verified_at': isPhoneVerified ? 'verified' : null,
    'email_verified_at': isEmailVerified ? 'verified' : null,
    if (createdAt != null) 'created_at': createdAt,
  };

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? emergencyContact,
    String? emergencyContactName,
    String? nationality,
  }) => UserModel(
    id: id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    nationality: nationality ?? this.nationality,
    phone: phone,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    address: address ?? this.address,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    emergencyContactName: emergencyContactName ?? this.emergencyContactName,
    isPhoneVerified: isPhoneVerified,
    isEmailVerified: isEmailVerified,
    createdAt: createdAt,
  );
}

/// Simple message-only response (e.g. logout, mark-as-read).
class MessageResponse {
  const MessageResponse({required this.message});
  final String message;
  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(message: json['message'] as String? ?? '');
}
