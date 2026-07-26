import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/services/storage_service.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/network_result.dart';

/// Intercepts every request to inject the Bearer token, and handles
/// automatic token refresh on 401 responses.
///
/// # Refresh flow
/// 1. On the first 401, this interceptor suspends the original request
///    and calls the refresh endpoint using a clean [Dio] instance (no
///    interceptors, so it cannot loop).
/// 2. While the refresh is in-flight, **all other** 401 requests are
///    queued instead of immediately triggering their own refresh.
/// 3. When the refresh succeeds every queued request is retried with
///    the new token.
/// 4. If the refresh fails (token revoked / expired) all pending
///    requests are rejected and auth data is wiped so the app can
///    navigate the user back to the login screen.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required StorageService storage, required Dio refreshDio})
    : _storage = storage,
      _refreshDio = refreshDio;

  final StorageService _storage;

  /// A dedicated Dio instance used **only** for the token-refresh call.
  /// It intentionally has NO interceptors attached to prevent infinite
  /// refresh loops.
  final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

  // ─── onRequest ────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ─── onError ──────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Avoid refresh loop: if the failing request IS the refresh endpoint,
    // immediately propagate the error so the caller can clear auth data.
    if (err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Queue and wait – will be resolved / rejected after refresh finishes.
      _pendingQueue.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    await _doRefresh(err, handler);
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _doRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _isRefreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const UnauthorizedException(
          'Session expired. Please log in again.',
        );
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        AppConfig.apiBaseUrl + ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data!;
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      await _storage.saveAccessToken(
        newAccessToken,
        expiry: expiresIn != null
            ? DateTime.now().add(
                Duration(
                  seconds: expiresIn - AppConfig.tokenExpiryBufferSeconds,
                ),
              )
            : null,
      );

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(newRefreshToken);
      }

      // Retry original request.
      handler.resolve(await _retry(err.requestOptions, newAccessToken));

      // Drain the pending queue.
      for (final pending in _pendingQueue) {
        try {
          pending.handler.resolve(
            await _retry(pending.options, newAccessToken),
          );
        } catch (e) {
          pending.handler.reject(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] Token refresh failed: $e');
      }
      await _storage.clearAuthData();

      // Reject original + queued requests with the original 401.
      handler.next(err);
      for (final pending in _pendingQueue) {
        pending.handler.next(
          DioException(
            requestOptions: pending.options,
            response: err.response,
            type: err.type,
            error: err.error,
          ),
        );
      }
    } finally {
      _pendingQueue.clear();
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) async {
    options.headers['Authorization'] = 'Bearer $token';
    return _refreshDio.fetch(options);
  }
}

class _PendingRequest {
  const _PendingRequest(this.options, this.handler);
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
