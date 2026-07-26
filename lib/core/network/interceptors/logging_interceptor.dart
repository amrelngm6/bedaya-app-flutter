import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Pretty-prints request and response details to the debug console.
///
/// This interceptor is intentionally **only** added to the Dio instance in
/// debug mode (`kDebugMode`).  It is never registered in release/profile
/// builds, so no sensitive data can leak to logs in production.
final class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '\n┌─── [REQUEST] ${options.method} ${options.uri} ───────────────────',
    );
    _logHeaders(options.headers);
    if (options.data != null) {
      debugPrint('│ Body: ${_sanitize(options.data)}');
    }
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '\n┌─── [RESPONSE] ${response.statusCode} ${response.requestOptions.uri} ───',
    );
    debugPrint('│ ${_sanitize(response.data)}');
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '\n┌─── [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri} ───',
    );
    debugPrint('│ Type  : ${err.type}');
    debugPrint('│ Msg   : ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│ Body  : ${_sanitize(err.response?.data)}');
    }
    debugPrint('└────────────────────────────────────────────────────────────');
    handler.next(err);
  }

  void _logHeaders(Map<String, dynamic> headers) {
    final safe = Map.of(headers)
      ..removeWhere(
        (k, _) => k.toLowerCase() == 'authorization',
      ); // never log tokens
    if (safe.isNotEmpty) debugPrint('│ Headers: $safe');
  }

  /// Truncates very long responses so the console does not overflow.
  String _sanitize(dynamic data) {
    final str = data.toString();
    return str.length > 500 ? '${str.substring(0, 500)}…' : str;
  }
}
