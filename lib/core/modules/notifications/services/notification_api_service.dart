import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/auth/models/auth_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification API model
// ─────────────────────────────────────────────────────────────────────────────

class NotificationApiModel {
  const NotificationApiModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
    this.actionId,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String body;

  /// e.g. 'appointment_reminder' | 'test_result' | 'promotion' | 'general'
  final String type;
  final String createdAt;
  final bool isRead;

  /// Deep-link route inside the app (e.g. '/bookings/42').
  final String? actionRoute;
  final String? actionId;
  final String? imageUrl;

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) =>
      NotificationApiModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['content'] as String? ?? '',
        type: json['type'] as String? ?? 'general',
        createdAt: json['created_at'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        actionRoute: json['action_route'] as String?,
        actionId: json['action_id'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}

class NotificationStats {
  const NotificationStats({required this.total, required this.unread});

  final int total;
  final int unread;

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      NotificationStats(
        total: json['total'] as int? ?? 0,
        unread: json['unread'] as int? ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification API Service
// ─────────────────────────────────────────────────────────────────────────────

class NotificationApiService extends BaseApiService {
  const NotificationApiService(super.client);

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<NotificationApiModel>>>
  getNotifications({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    bool? unreadOnly,
    String? type,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (unreadOnly == true) 'unread_only': true,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['notifications'],
      NotificationApiModel.fromJson,
    );
  });

  // ─── Stats ────────────────────────────────────────────────────────────────

  Future<NetworkResult<NotificationStats>> getStats() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.notifications}/stats',
    );
    return NotificationStats.fromJson(response.data ?? {});
  });

  // ─── Mark as read ─────────────────────────────────────────────────────────

  Future<NetworkResult<MessageResponse>> markAsRead(int id) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.markNotificationRead(id),
        );
        return MessageResponse.fromJson(response.data ?? {});
      });

  Future<NetworkResult<MessageResponse>> markAllAsRead() => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.markAllNotificationsRead,
    );
    return MessageResponse.fromJson(response.data ?? {});
  });

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<NetworkResult<MessageResponse>> deleteNotification(int id) =>
      execute(() async {
        final response = await dio.delete<Map<String, dynamic>>(
          ApiEndpoints.notificationById(id),
        );
        return MessageResponse.fromJson(response.data ?? {});
      });

  // ─── Device token registration ────────────────────────────────────────────

  /// Registers a push-notification token with the backend so the server
  /// can send targeted FCM / APNs messages.
  Future<NetworkResult<MessageResponse>> registerFcmToken({
    required String token,
    required String deviceName,
    required String deviceType,
    required String brandName,
    String? countryCode,
    String? modelName,
    String? osVersion,
  }) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.registerFcmToken,
      data: {
        'app_version': AppConfig.version,
        'device_name': deviceName,
        'device_token': token,
        'device_type': deviceType,
        'os_version': osVersion,
        'brand_name': brandName,
        'model_name': modelName,
        'country_code': countryCode,
      },
    );
    return MessageResponse.fromJson(response.data ?? {});
  });

  Future<NetworkResult<MessageResponse>> unregisterFcmToken(String token) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.unregisterFcmToken,
          data: {'token': token},
        );
        return MessageResponse.fromJson(response.data ?? {});
      });
}
