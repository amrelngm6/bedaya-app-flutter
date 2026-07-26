import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/interceptors/auth_interceptor.dart';
import 'package:bedaya2/core/network/interceptors/logging_interceptor.dart';
import 'package:bedaya2/core/services/storage_service.dart';

/// The single, application-wide [Dio] HTTP client.
///
/// Two Dio instances are maintained:
/// - [dio] — the main instance, with auth, logging, and error interceptors.
/// - [_refreshDio] — a clean instance used exclusively by [AuthInterceptor]
///   to exchange refresh tokens.  It has no interceptors so it cannot trigger
///   a recursive refresh loop.
///
/// Obtain via [ApiClient.instance] after calling [ApiClient.init].
class ApiClient {
  ApiClient._({required StorageService storage}) {
    _refreshDio = _buildRefreshDio();
    dio = _buildMainDio(storage);
  }

  static ApiClient? _instance;

  /// Must be called once (in [ServiceLocator.initialize]) before any service
  /// tries to use the client.
  static void init(StorageService storage) {
    _instance ??= ApiClient._(storage: storage);
  }

  static ApiClient get instance {
    assert(
      _instance != null,
      'ApiClient.init() must be called before accessing ApiClient.instance.',
    );
    return _instance!;
  }

  /// Main Dio instance – use this for all API calls.
  late final Dio dio;

  /// Refresh-only Dio – no interceptors, used internally by AuthInterceptor.
  late final Dio _refreshDio;

  // ─── Builders ──────────────────────────────────────────────────────────────

  Dio _buildRefreshDio() => Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (_) => true, // We handle status codes ourselves.
    ),
  );

  Dio _buildMainDio(StorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storage: storage, refreshDio: _refreshDio),
      if (kDebugMode) LoggingInterceptor(),
    ]);

    return dio;
  }
}
