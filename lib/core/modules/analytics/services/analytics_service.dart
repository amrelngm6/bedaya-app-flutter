import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/modules/analytics/models/analytics_models.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';

/// Analytics service — manages mobile session lifecycle and in-app event tracking.
///
/// Usage in [ServiceLocator.initialize]:
/// ```dart
/// analytics = AnalyticsService(apiClient);
/// await analytics.initialize();
/// WidgetsBinding.instance.addObserver(analytics);
/// ```
///
/// Track custom events anywhere:
/// ```dart
/// sl.analytics.trackEvent(AnalyticsEvent(eventName: 'button_click', screenName: 'Home'));
/// sl.analytics.trackScreen('DoctorList');
/// ```
///
/// Call [updatePushToken] whenever FCM delivers a new token.
class AnalyticsService extends BaseApiService with WidgetsBindingObserver {
  AnalyticsService(super.client);

  // ─── State ──────────────────────────────────────────────────────────────────

  String? _deviceId;
  String? _currentSessionId;
  DateTime? _sessionStartedAt;
  String? _platform;
  String? _osVersion;
  String? _deviceModel;
  String? _deviceBrand;
  String? _timezone;
  String? _locale;
  String? _pushToken;

  /// Buffered events flushed in batch on session end or when threshold reached.
  final List<AnalyticsEvent> _eventBuffer = [];

  /// After this many buffered events the buffer is auto-flushed.
  static const int _flushThreshold = 5;

  static const _kDeviceIdKey = '_b_did';

  bool _initialized = false;

  // ─── Initialization ─────────────────────────────────────────────────────────

  /// Must be called once during [ServiceLocator.initialize].
  /// Collects device information and starts the first session.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _collectDeviceInfo();
    await _startSession();
  }

  // ─── WidgetsBindingObserver ──────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Re-start only if the session was terminated (app was fully killed).
        _startSession();
      case AppLifecycleState.paused:
        // App went to background — keep the session alive, just flush buffered
        // events so nothing is lost while the app is not in the foreground.
        _flushEvents();
      case AppLifecycleState.detached:
        // App process is being killed — close the session properly.
        _endCurrentSession();
      default:
        break;
    }
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Tracks a named event.  The event is buffered and auto-flushed when the
  /// buffer reaches [_flushThreshold] events.
  void trackEvent(AnalyticsEvent event) {
    if (_currentSessionId == null) return;
    _eventBuffer.add(event);
    if (_eventBuffer.length >= _flushThreshold) {
      _flushEvents();
    }
  }

  /// Convenience method for screen-view events.
  void trackScreen(String screenName) {
    trackEvent(
      AnalyticsEvent(
        eventName: 'screen_view',
        eventCategory: 'navigation',
        screenName: screenName,
        occurredAt: DateTime.now(),
      ),
    );
  }

  /// Convenience method for button / action tap events.
  void trackTap(String buttonName, {String? screenName}) {
    trackEvent(
      AnalyticsEvent(
        eventName: 'button_click',
        eventCategory: 'interaction',
        screenName: screenName,
        eventData: {'button': buttonName},
        occurredAt: DateTime.now(),
      ),
    );
  }

  /// Notifies the backend of a new or refreshed FCM / APNS push token.
  /// Also stores the token locally so it is included in the next session start.
  Future<void> updatePushToken(String token) async {
    _pushToken = token;
    final sessionId = _currentSessionId;
    if (sessionId == null) return;

    await execute<void>(() async {
      await dio.post<Map<String, dynamic>>(
        ApiEndpoints.analyticsUpdatePushToken(sessionId),
        data: {'push_token': token},
      );
    });
  }

  // ─── Private session management ──────────────────────────────────────────────

  Future<void> _startSession() async {
    if (_currentSessionId != null) return; // Session already active
    final sessionId = _generateSessionId();
    _currentSessionId = sessionId;
    _sessionStartedAt = DateTime.now();

    final request = AnalyticsSessionStartRequest(
      businessId: AppConfig.businessId,
      deviceId: _deviceId ?? 'unknown',
      sessionId: sessionId,
      appVersion: AppConfig.version,
      platform: _platform,
      osVersion: _osVersion,
      deviceModel: _deviceModel,
      deviceBrand: _deviceBrand,
      timezone: _timezone,
      locale: _locale,
      pushToken: _pushToken,
      startedAt: _sessionStartedAt,
    );

    await execute<AnalyticsSessionStartResponse>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.analyticsStartSession,
        data: request.toJson(),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) throw const FormatException('Missing data field');
      return AnalyticsSessionStartResponse.fromJson(data);
    });
  }

  Future<void> _endCurrentSession() async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return;

    final endedAt = DateTime.now();
    final duration = _sessionStartedAt != null
        ? endedAt.difference(_sessionStartedAt!).inSeconds
        : null;

    // Flush any buffered events before ending.
    await _flushEvents();

    _currentSessionId = null;
    _sessionStartedAt = null;

    final request = AnalyticsSessionEndRequest(
      endedAt: endedAt,
      durationSeconds: duration,
      pushToken: _pushToken,
    );

    await execute<void>(() async {
      await dio.post<Map<String, dynamic>>(
        ApiEndpoints.analyticsEndSession(sessionId),
        data: request.toJson(),
      );
    });
  }

  /// Sends all buffered events to the batch endpoint and clears the buffer.
  Future<void> _flushEvents() async {
    if (_eventBuffer.isEmpty) return;
    final sessionId = _currentSessionId;
    if (sessionId == null) {
      _eventBuffer.clear();
      return;
    }

    final snapshot = List<AnalyticsEvent>.from(_eventBuffer);
    _eventBuffer.clear();

    final request = AnalyticsBatchEventRequest(
      businessId: AppConfig.businessId,
      sessionId: sessionId,
      deviceId: _deviceId ?? 'unknown',
      events: snapshot,
      platform: _platform,
      appVersion: AppConfig.version,
    );

    await execute<void>(() async {
      await dio.post<Map<String, dynamic>>(
        ApiEndpoints.analyticsSendEventsBulk,
        data: request.toJson(),
      );
    });
  }

  // ─── Device info ─────────────────────────────────────────────────────────────

  Future<void> _collectDeviceInfo() async {
    // Persist device ID across sessions
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_kDeviceIdKey);
    if (_deviceId == null) {
      _deviceId = _generateDeviceId();
      await prefs.setString(_kDeviceIdKey, _deviceId!);
    }

    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      _timezone = tzInfo.localizedName?.name;
    } catch (_) {
      _timezone = null;
    }

    try {
      _locale = Platform.localeName;
    } catch (_) {
      _locale =
          'Arabic'; // Fallback to Arabic as it's the primary language of the app
    }

    if (kIsWeb) {
      _platform = 'unknown';
      return;
    }

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      _platform = 'android';
      try {
        final info = await deviceInfo.androidInfo;
        _osVersion = info.version.release;
        _deviceModel = info.model;
        _deviceBrand = info.brand;
      } catch (_) {}
    } else if (Platform.isIOS) {
      _platform = 'ios';
      try {
        final info = await deviceInfo.iosInfo;
        _osVersion = info.systemVersion;
        _deviceModel = info.model;
        _deviceBrand = 'Apple';
      } catch (_) {}
    } else {
      _platform = 'unknown';
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _generateSessionId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // UUID v4 version bits
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // UUID v4 variant bits
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  String _generateDeviceId() => _generateSessionId();
}
