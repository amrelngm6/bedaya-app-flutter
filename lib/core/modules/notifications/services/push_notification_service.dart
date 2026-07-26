import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:bedaya2/core/modules/notifications/services/notification_api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background handler — MUST be a top-level function (not a class method).
// ─────────────────────────────────────────────────────────────────────────────

/// Called by the OS when a data-only FCM message arrives while the app is in
/// the background or terminated.  A separate Dart isolate is created for this
/// so the function is intentionally minimal.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Re-initialise Firebase for the background isolate.
  await Firebase.initializeApp();
  // Data payloads that carry a `notification` object are shown automatically
  // by the OS.  Nothing extra is needed here for the default use-case.
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification channel constants
// ─────────────────────────────────────────────────────────────────────────────

const _kChannelId = 'bedaya_high_importance';
const _kChannelName = 'Bedaya Notifications';
const _kChannelDesc = 'Appointment reminders, medication alerts, and updates';

// ─────────────────────────────────────────────────────────────────────────────
// PushNotificationService
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the full push-notification lifecycle:
///
/// - Requests OS permission.
/// - Creates the Android notification channel.
/// - Registers / refreshes the FCM token with the Laravel backend.
/// - Displays a heads-up local notification when a message arrives
///   while the app is in the **foreground**.
/// - Routes the user to the correct screen when they tap a notification
///   (foreground, background, or terminated state).
///
/// Usage
/// -----
/// ```dart
/// // In main():
/// await sl.pushNotifications.initialize();
///
/// // In MaterialApp:
/// navigatorKey: PushNotificationService.navigatorKey,
/// ```
class PushNotificationService {
  PushNotificationService({
    required NotificationApiService notificationApiService,
  }) : _notificationApiService = notificationApiService;

  final NotificationApiService _notificationApiService;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Shared navigator key — pass to [MaterialApp.navigatorKey] in main.dart.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ─── Android notification channel ────────────────────────────────────────

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _kChannelId,
    _kChannelName,
    description: _kChannelDesc,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Call once after [Firebase.initializeApp].
  Future<bool?> initialize() async {
    await _requestPermissions();
    await _initLocalNotifications();
    await _createAndroidChannel();
    _listenForeground();
    _listenTaps();
    await _registerToken();
    _listenTokenRefresh();
    return true;
  }

  // ─── Permission ───────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    // FCM permission (covers iOS alert/badge/sound + Android 13 POST_NOTIFICATIONS)
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // ─── Local notifications setup ────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      // Permissions are already requested via FCM — do NOT request again here.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> _createAndroidChannel() async {
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // ─── Foreground message handling ──────────────────────────────────────────

  void _listenForeground() {
    // iOS: show alert/badge/sound even while the app is open.
    _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android: FCM suppresses the system notification when the app is
    // foreground — we must display it manually via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Use the large icon if an image URL was provided.
          styleInformation: notification.android?.imageUrl != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(notification.android!.imageUrl!),
                )
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Pass the type so we can route correctly on tap.
      payload: message.data['type'] as String? ?? 'general',
    );
  }

  // ─── Tap / open-app handling ──────────────────────────────────────────────

  void _listenTaps() {
    // Terminated → app opened by tapping notification.
    _fcm.getInitialMessage().then((message) {
      if (message != null) _routeFromRemoteMessage(message);
    });

    // Background → app brought to foreground by tapping notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_routeFromRemoteMessage);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    _navigateForType(type: response.payload ?? 'general', actionId: null);
  }

  void _routeFromRemoteMessage(RemoteMessage message) {
    _navigateForType(
      type: message.data['type'] as String? ?? 'general',
      actionId: message.data['action_id'] as String?,
    );
  }

  /// Navigates to the correct screen based on the notification [type].
  ///
  /// Extend the switch arms as you add new deep-link destinations.
  void _navigateForType({required String type, required String? actionId}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    switch (type) {
      case 'appointment_reminder':
      case 'appointment':
        navigator.pushNamed('/notifications');
        break;

      case 'medication_reminder':
      case 'medication':
        navigator.pushNamed('/notifications');
        break;

      case 'test_result':
      case 'treatment':
        navigator.pushNamed('/notifications');
        break;

      case 'article':
        navigator.pushNamed('/notifications');
        break;

      default:
        navigator.pushNamed('/notifications');
        break;
    }
  }

  // ─── FCM token management ─────────────────────────────────────────────────

  Future<void> _registerToken() async {
    try {
      String? token;

      if (Platform.isIOS) {
        // Wait for APNs token before requesting the FCM token on iOS.
        final apns = await _fcm.getAPNSToken();
        if (apns == null) {
          await Future<void>.delayed(const Duration(seconds: 3));
        }
      }

      token = await _fcm.getToken();
      if (token != null) await _sendTokenToBackend(token);
    } catch (e) {
      // Token registration failure is non-fatal — the device will retry
      // automatically on the next cold launch.
    }
  }

  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen(_sendTokenToBackend);
  }

  Future<void> _sendTokenToBackend(String token) async {
    final deviceType = Platform.isIOS ? 'ios' : 'android';

    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;

    final allInfo = deviceInfo.data;

    final deviceName = allInfo['name'] as String? ?? 'Unknown Device';
    final brandName = allInfo['brand'] as String? ?? '';
    final modelName = allInfo['model'] as String? ?? '';
    final osVersion = Platform.operatingSystemVersion
        .split('_')
        .last
        .substring(0, 2);
    await _notificationApiService.registerFcmToken(
      token: token,
      deviceType: deviceType,
      deviceName: deviceName,
      brandName: brandName,
      modelName: modelName,
      osVersion: osVersion,
    );
  }

  /// Call this on logout to unregister the device token from the backend.
  Future<void> unregisterToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _notificationApiService.unregisterFcmToken(token);
      }
      await _fcm.deleteToken();
    } catch (e) {
      // Token unregistration failure is non-fatal — the device will retry
      // automatically on the next cold launch.
    }
  }
}
