/// Central configuration for the Bedaya Hospital API.
///
/// Change [baseUrl] to your actual Laravel backend URL before going to
/// production.  When running locally you can override this via the
/// [AppConfig.development] factory.
///
class AppConfig {
  const AppConfig._();

  // ─── Backend Base URL ───────────────────────────────────────────────────────
  /// The root URL of the Laravel API (no trailing slash).
  static const String baseUrl = 'https://bedayaapp.com';

  /// Full base URL including the API prefix.
  static const String apiBaseUrl = '$baseUrl/secured-api';

  /// Version string to send in API requests for compatibility checks.
  static const String version = '1.1.4';

  // ─── HTTP Timeouts ──────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ─── Pagination defaults ────────────────────────────────────────────────────
  static const int defaultPageSize = 15;

  // ─── Token settings ─────────────────────────────────────────────────────────
  /// How many seconds before expiry to treat a token as "expired" (safety
  /// buffer to avoid using a token that expires in-flight).
  static const int tokenExpiryBufferSeconds = 60;

  // ─── Business ─────────────────────────────────────────────────────────────────
  /// The backend business / tenant ID used by analytics endpoints.
  static const int businessId = 1;

  // ─── App version ─────────────────────────────────────────────────────────────
  /// Current running version of the app (must match pubspec.yaml).
  static const String currentVersion = '1.1.4+14';

  /// Returns `true` when [currentVersion] is lower than [minVersion].
  /// Uses semantic version comparison (major.minor.patch).
  static bool isVersionBehind(String minVersion) {
    final current = currentVersion.split('.').map(_intOrZero).toList();
    final min = minVersion.split('.').map(_intOrZero).toList();
    final length = min.length > current.length ? min.length : current.length;
    for (var i = 0; i < length; i++) {
      final c = i < current.length ? current[i] : 0;
      final m = i < min.length ? min[i] : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false; // equal versions
  }

  static int _intOrZero(String s) => int.tryParse(s.trim()) ?? 0;
}
