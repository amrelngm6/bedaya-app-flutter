import 'package:dio/dio.dart';

import 'package:bedaya2/core/network/api_client.dart';
import 'package:bedaya2/core/network/network_result.dart';

/// Abstract base class for all API service classes.
///
/// Provides the [execute] helper which wraps every Dio call in
/// a try/catch and maps any [DioException] or unexpected error into
/// the appropriate [ApiException] subclass, returning a [NetworkResult].
///
/// Usage:
/// ```dart
/// class MyService extends BaseApiService {
///   MyService(super.client);
///
///   Future<NetworkResult<MyModel>> fetch() =>
///       execute(() async {
///         final res = await dio.get('/endpoint');
///         return MyModel.fromJson(res.data);
///       });
/// }
/// ```
abstract class BaseApiService {
  const BaseApiService(this._client);

  final ApiClient _client;

  /// Shortcut to the underlying Dio instance.
  Dio get dio => _client.dio;

  // ─── execute ──────────────────────────────────────────────────────────────

  Future<NetworkResult<T>> execute<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on DioException catch (err) {
      return Failure(_mapDioException(err));
    } on ApiException catch (err) {
      return Failure(err);
    } catch (err) {
      return Failure(UnknownException(err.toString()));
    }
  }

  // ─── DioException → ApiException ─────────────────────────────────────────

  ApiException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        return _mapHttpError(err.response);

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'SSL certificate error. Connection is not secure.',
        );

      case DioExceptionType.unknown:
        return UnknownException(err.message ?? 'An unexpected error occurred.');
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  ApiException _mapHttpError(Response<dynamic>? response) {
    if (response == null) return const ServerException();

    final message = _extractMessage(response);
    final errors = _extractErrors(response);

    return switch (response.statusCode) {
      400 => BadRequestException(message, errors: errors),
      401 => const UnauthorizedException(),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      422 => ValidationException(message, errors: errors),
      429 => const TooManyRequestsException(),
      _ when (response.statusCode ?? 0) >= 500 => ServerException(message),
      _ => UnknownException(message),
    };
  }

  String _extractMessage(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          response.statusMessage ??
          'Unexpected error occurred.';
    }
    return response.statusMessage ?? 'Unexpected error occurred.';
  }

  Map<String, dynamic>? _extractErrors(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['errors'] as Map<String, dynamic>?;
    }
    return null;
  }
}
