import 'package:bedaya2/core/modules/notifications/services/notification_api_service.dart';

enum NotificationType {
  appointment,
  medication,
  testResult,
  treatment,
  article,
  promotional,
  system,
  educational,
}

/// Maps the raw [String] type field coming from the Laravel API to the local
/// [NotificationType] enum.  Defaults to [NotificationType.system] for any
/// unknown value so the app never crashes on new server-side types.
NotificationType notificationTypeFromString(String raw) {
  switch (raw.toLowerCase()) {
    case 'appointment':
    case 'appointment_reminder':
      return NotificationType.appointment;
    case 'medication':
    case 'medication_reminder':
      return NotificationType.medication;
    case 'test_result':
      return NotificationType.testResult;
    case 'treatment':
      return NotificationType.treatment;
    case 'article':
      return NotificationType.article;
    case 'promotion':
    case 'promotional':
      return NotificationType.promotional;
    case 'educational':
    case 'health_tip':
      return NotificationType.educational;
    default:
      return NotificationType.system;
  }
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.imageUrl,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts a [NotificationApiModel] (from the Laravel backend) into
  /// the local domain model used throughout the UI.
  factory NotificationModel.fromApiModel(NotificationApiModel api) {
    final metadata = <String, dynamic>{};
    if (api.actionId != null) metadata['action_id'] = api.actionId;

    return NotificationModel(
      id: api.id.toString(),
      type: notificationTypeFromString(api.type),
      title: api.title,
      message: api.body,
      timestamp: DateTime.tryParse(api.createdAt) ?? DateTime.now(),
      isRead: api.isRead,
      actionUrl: api.actionRoute,
      imageUrl: api.imageUrl,
      metadata: metadata.isEmpty ? null : metadata,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.medication:
        return 'Medication';
      case NotificationType.testResult:
        return 'Test Result';
      case NotificationType.treatment:
        return 'Treatment Update';
      case NotificationType.article:
        return 'New Article';
      case NotificationType.promotional:
        return 'Offer';
      case NotificationType.system:
        return 'System';
      case NotificationType.educational:
        return 'Health Tip';
    }
  }
}
