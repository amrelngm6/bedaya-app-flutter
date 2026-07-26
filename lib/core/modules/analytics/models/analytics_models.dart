// ─────────────────────────────────────────────────────────────────────────────
// Session models
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsSessionStartRequest {
  const AnalyticsSessionStartRequest({
    required this.businessId,
    required this.deviceId,
    required this.sessionId,
    this.appVersion,
    this.platform,
    this.osVersion,
    this.deviceModel,
    this.deviceBrand,
    this.locale,
    this.timezone,
    this.screenWidth,
    this.screenHeight,
    this.pushToken,
    this.startedAt,
  });

  final int businessId;
  final String deviceId;
  final String sessionId;
  final String? appVersion;

  /// 'ios' | 'android' | 'unknown'
  final String? platform;
  final String? osVersion;
  final String? deviceModel;
  final String? deviceBrand;
  final String? locale;
  final String? timezone;
  final int? screenWidth;
  final int? screenHeight;
  final String? pushToken;
  final DateTime? startedAt;

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'device_id': deviceId,
    'session_id': sessionId,
    if (appVersion != null) 'app_version': appVersion,
    if (platform != null) 'platform': platform,
    if (osVersion != null) 'os_version': osVersion,
    if (deviceModel != null) 'device_model': deviceModel,
    if (deviceBrand != null) 'device_brand': deviceBrand,
    if (locale != null) 'locale': locale,
    if (timezone != null) 'timezone': timezone,
    if (screenWidth != null) 'screen_width': screenWidth,
    if (screenHeight != null) 'screen_height': screenHeight,
    if (pushToken != null) 'push_token': pushToken,
    if (startedAt != null) 'started_at': startedAt!.toUtc().toIso8601String(),
  };
}

class AnalyticsSessionStartResponse {
  const AnalyticsSessionStartResponse({
    required this.id,
    required this.sessionId,
    required this.isUniqueSession,
  });

  final int id;
  final String sessionId;
  final bool isUniqueSession;

  factory AnalyticsSessionStartResponse.fromJson(Map<String, dynamic> json) =>
      AnalyticsSessionStartResponse(
        id: json['id'] as int,
        sessionId: json['session_id'] as String,
        isUniqueSession: (json['is_unique_session'] as bool?) ?? false,
      );
}

class AnalyticsSessionEndRequest {
  const AnalyticsSessionEndRequest({
    this.endedAt,
    this.durationSeconds,
    this.pushToken,
  });

  final DateTime? endedAt;
  final int? durationSeconds;
  final String? pushToken;

  Map<String, dynamic> toJson() => {
    if (endedAt != null) 'ended_at': endedAt!.toUtc().toIso8601String(),
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
    if (pushToken != null) 'push_token': pushToken,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Event models
// ─────────────────────────────────────────────────────────────────────────────

/// A single in-app event to be sent to the API.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.eventName,
    this.eventCategory,
    this.screenName,
    this.eventData,
    this.occurredAt,
  });

  final String eventName;
  final String? eventCategory;
  final String? screenName;
  final Map<String, dynamic>? eventData;
  final DateTime? occurredAt;

  Map<String, dynamic> toJson() => {
    'event_name': eventName,
    if (eventCategory != null) 'event_category': eventCategory,
    if (screenName != null) 'screen_name': screenName,
    if (eventData != null) 'event_data': eventData,
    if (occurredAt != null)
      'occurred_at': occurredAt!.toUtc().toIso8601String(),
  };
}

/// Full single-event request body (wraps shared fields + one event).
class AnalyticsSingleEventRequest {
  const AnalyticsSingleEventRequest({
    required this.businessId,
    required this.sessionId,
    required this.deviceId,
    required this.event,
    this.platform,
    this.appVersion,
  });

  final int businessId;
  final String sessionId;
  final String deviceId;
  final AnalyticsEvent event;
  final String? platform;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'session_id': sessionId,
    'device_id': deviceId,
    'event_name': event.eventName,
    if (event.eventCategory != null) 'event_category': event.eventCategory,
    if (event.screenName != null) 'screen_name': event.screenName,
    if (event.eventData != null) 'event_data': event.eventData,
    if (event.occurredAt != null)
      'occurred_at': event.occurredAt!.toUtc().toIso8601String(),
    if (platform != null) 'platform': platform,
    if (appVersion != null) 'app_version': appVersion,
  };
}

/// Batch event request body.
class AnalyticsBatchEventRequest {
  const AnalyticsBatchEventRequest({
    required this.businessId,
    required this.sessionId,
    required this.deviceId,
    required this.events,
    this.platform,
    this.appVersion,
  });

  final int businessId;
  final String sessionId;
  final String deviceId;
  final List<AnalyticsEvent> events;
  final String? platform;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'session_id': sessionId,
    'device_id': deviceId,
    'events': events.map((e) => e.toJson()).toList(),
    if (platform != null) 'platform': platform,
    if (appVersion != null) 'app_version': appVersion,
  };
}
