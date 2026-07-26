import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedaya2/core/modules/auth/models/auth_models.dart';

/// Centralised storage service that combines:
/// - [FlutterSecureStorage] for security-sensitive data (tokens, user ID).
/// - [SharedPreferences] for non-sensitive preferences and lightweight cache.
///
/// Tokens are stored under obfuscated key names to make them harder to
/// identify if a device backup is inspected.
///
/// Obtain a fully-initialised instance via [StorageService.create].
class StorageService {
  StorageService._();

  static StorageService? _instance;

  /// Returns the singleton instance, creating and initialising it on first
  /// call.  Must be awaited before the instance is usable.
  static Future<StorageService> create() async {
    if (_instance != null) return _instance!;
    _instance = StorageService._();
    await _instance!._init();
    return _instance!;
  }

  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _secure;

  static const _secureOptions = AndroidOptions();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _secure = const FlutterSecureStorage(aOptions: _secureOptions);
  }

  // ─── Key constants (obfuscated) ───────────────────────────────────────────
  static const _kAccessToken = '_b_at';
  static const _kRefreshToken = '_b_rt';
  static const _kUserId = '_b_uid';
  static const _kUserCountry = '_b_uc';
  static const _kUserJson = '_b_usr';
  static const _kAccessExpiry = '_b_ate';
  static const _kRefreshExpiry = '_b_rte';

  // ─── Access Token ─────────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token, {DateTime? expiry}) async {
    await _secure.write(key: _kAccessToken, value: token);
    if (expiry != null) {
      await _prefs.setString(_kAccessExpiry, expiry.toIso8601String());
    }
  }

  Future<String?> getAccessToken() => _secure.read(key: _kAccessToken);

  bool isAccessTokenExpired() {
    final raw = _prefs.getString(_kAccessExpiry);
    if (raw == null) return false;
    return DateTime.now().isAfter(DateTime.parse(raw));
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────

  Future<void> saveRefreshToken(String token, {DateTime? expiry}) async {
    await _secure.write(key: _kRefreshToken, value: token);
    if (expiry != null) {
      await _prefs.setString(_kRefreshExpiry, expiry.toIso8601String());
    }
  }

  Future<String?> getRefreshToken() => _secure.read(key: _kRefreshToken);

  bool isRefreshTokenExpired() {
    final raw = _prefs.getString(_kRefreshExpiry);
    if (raw == null) return false;
    return DateTime.now().isAfter(DateTime.parse(raw));
  }

  // ─── Composite Auth Response ──────────────────────────────────────────────
  Future<void> saveAuthResponse(AuthResponse response) async {
    await Future.wait([
      saveAccessToken(response.accessToken, expiry: response.accessTokenExpiry),
      if (response.refreshToken != null)
        saveRefreshToken(
          response.refreshToken!,
          expiry: response.refreshTokenExpiry,
        ),
      _secure.write(key: _kUserId, value: response.user.id.toString()),
      _secure.write(
        key: _kUserCountry,
        value: response.user.nationality.toString(),
      ),
    ]);
    await _prefs.setString(_kUserJson, jsonEncode(response.user.toJson()));
  }

  Future<void> clearAuthData() async {
    await Future.wait([
      _secure.delete(key: _kAccessToken),
      _secure.delete(key: _kRefreshToken),
      _secure.delete(key: _kUserId),
    ]);
    await Future.wait([
      _prefs.remove(_kUserJson),
      _prefs.remove(_kAccessExpiry),
      _prefs.remove(_kRefreshExpiry),
    ]);
  }

  // ─── User Data ────────────────────────────────────────────────────────────

  Future<UserModel?> getUser() async {
    final raw = _prefs.getString(_kUserJson);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Persists updated user data without touching tokens.
  Future<void> updateUser(UserModel user) async {
    await _prefs.setString(_kUserJson, jsonEncode(user.toJson()));
  }

  Future<String?> getUserId() => _secure.read(key: _kUserId);

  bool get isLoggedIn => _prefs.getString(_kUserJson) != null;

  // ─── Generic SharedPreferences helpers ───────────────────────────────────

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearPreferences() => _prefs.clear();
}
