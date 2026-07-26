import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bedaya2/core/theme/colors.dart';

/// Represents the public remote configuration fetched from [ApiEndpoints.appConfig].
///
/// The server stores every value as a string; typed helpers perform the
/// conversion locally.  On parse failure the field falls back to its default.
///
/// Supports two API response shapes:
/// - Flat map  — `{ "app_name": "Bedaya", "primary_color": "#2491A1", … }`
/// - Entry list — `[ { "key": "app_name", "value": "Bedaya" }, … ]`
class AppRemoteConfig {
  const AppRemoteConfig({
    this.appName,
    this.appLogo,
    this.supportEmail,
    this.supportPhone,
    this.maintenanceMode = false,
    this.minAppVersion = '1.0.0',
    this.primaryColor = AppColors.primaryTeal,
    this.secondaryColor = AppColors.primaryPurple,
    this.darkModeEnabled = true,
    this.paymentEnabled = false,
    this.paymentGateways = const [],
    this.currencyCode = 'USD',
    this.currencySymbol = r'$',
    this.defaultLanguage = 'ar',
    this.supportedLanguages = const ['ar'],
    this.rtlEnabled = false,
    this.pushNotificationsEnabled = true,
    this.inAppNotificationsEnabled = true,
    this.biometricLoginEnabled = true,
    this.forceUpdateEnabled = false,
  });

  // ── General ──────────────────────────────────────────────────────────────
  final String? appName;
  final String? appLogo;
  final String? supportEmail;
  final String? supportPhone;
  final bool maintenanceMode;
  final String minAppVersion;

  // ── Appearance ────────────────────────────────────────────────────────────
  final Color primaryColor;
  final Color secondaryColor;
  final bool darkModeEnabled;

  // ── Payments ──────────────────────────────────────────────────────────────
  final bool paymentEnabled;
  final List<String> paymentGateways;
  final String currencyCode;
  final String currencySymbol;

  // ── Localization ──────────────────────────────────────────────────────────
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final bool rtlEnabled;

  // ── Notifications ─────────────────────────────────────────────────────────
  final bool pushNotificationsEnabled;
  final bool inAppNotificationsEnabled;

  // ── Security ──────────────────────────────────────────────────────────────
  final bool biometricLoginEnabled;
  final bool forceUpdateEnabled;

  /// Fallback used when no remote config has been loaded yet.
  static const AppRemoteConfig defaults = AppRemoteConfig();

  // ─── fromMap (flat key→value or list of entries) ──────────────────────────

  factory AppRemoteConfig.fromMap(Map<String, dynamic> map) {
    return AppRemoteConfig(
      appName: map['app_name'] as String?,
      appLogo: map['app_logo'] as String?,
      supportEmail: map['support_email'] as String?,
      supportPhone: map['support_phone'] as String?,
      maintenanceMode: _parseBool(map['maintenance_mode'], fallback: false),
      minAppVersion: (map['min_app_version'] as String?) ?? '1.0.0',
      primaryColor: _parseColor(
        map['primary_color'],
        fallback: AppColors.primaryTeal,
      ),
      secondaryColor: _parseColor(
        map['secondary_color'],
        fallback: AppColors.primaryPurple,
      ),
      darkModeEnabled: _parseBool(map['dark_mode_enabled'], fallback: true),
      paymentEnabled: _parseBool(map['payment_enabled'], fallback: false),
      paymentGateways: _parseStringList(map['payment_gateways']),
      currencyCode: (map['currency_code'] as String?) ?? 'USD',
      currencySymbol: (map['currency_symbol'] as String?) ?? r'$',
      defaultLanguage: (map['default_language'] as String?) ?? 'ar',
      supportedLanguages: _parseStringList(
        map['supported_languages'],
        fallback: ['ar'],
      ),
      rtlEnabled: _parseBool(map['rtl_enabled'], fallback: false),
      pushNotificationsEnabled: _parseBool(
        map['push_notifications'],
        fallback: true,
      ),
      inAppNotificationsEnabled: _parseBool(
        map['in_app_notifications'],
        fallback: true,
      ),
      biometricLoginEnabled: _parseBool(map['biometric_login'], fallback: true),
      forceUpdateEnabled: _parseBool(
        map['force_update_enabled'],
        fallback: false,
      ),
    );
  }

  // ─── Serialization (used for SharedPreferences caching) ──────────────────

  Map<String, dynamic> toMap() => {
    'app_name': appName,
    'app_logo': appLogo,
    'support_email': supportEmail,
    'support_phone': supportPhone,
    'maintenance_mode': maintenanceMode.toString(),
    'min_app_version': minAppVersion,
    'primary_color': _colorToHex(primaryColor),
    'secondary_color': _colorToHex(secondaryColor),
    'dark_mode_enabled': darkModeEnabled.toString(),
    'payment_enabled': paymentEnabled.toString(),
    'payment_gateways': jsonEncode(paymentGateways),
    'currency_code': currencyCode,
    'currency_symbol': currencySymbol,
    'default_language': defaultLanguage,
    'supported_languages': jsonEncode(supportedLanguages),
    'rtl_enabled': rtlEnabled.toString(),
    'push_notifications': pushNotificationsEnabled.toString(),
    'in_app_notifications': inAppNotificationsEnabled.toString(),
    'biometric_login': biometricLoginEnabled.toString(),
    'force_update_enabled': forceUpdateEnabled.toString(),
  };

  String toJson() => jsonEncode(toMap());

  factory AppRemoteConfig.fromJson(String source) =>
      AppRemoteConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);

  // ─── Private helpers ──────────────────────────────────────────────────────

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return fallback;
  }

  static Color _parseColor(dynamic value, {required Color fallback}) {
    if (value == null || value is! String || value.trim().isEmpty) {
      return fallback;
    }
    try {
      final hex = value.trim().replaceAll('#', '');
      final full = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(full, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static String _colorToHex(Color color) {
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  static List<String> _parseStringList(
    dynamic value, {
    List<String> fallback = const [],
  }) {
    if (value == null) return fallback;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return fallback;
  }
}
