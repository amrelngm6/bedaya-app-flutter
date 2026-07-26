import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification channel for medication reminders
// ─────────────────────────────────────────────────────────────────────────────

const _kChannelId = 'medication_reminders';
const _kChannelName = 'Medication Reminders';
const _kChannelDesc = 'Daily reminders to take your medication on time';
const _kPrefsPrefix = 'med_reminder_ids_';

// ─────────────────────────────────────────────────────────────────────────────
// MedicationReminderService
// ─────────────────────────────────────────────────────────────────────────────

/// Manages **daily repeating local notifications** for medication reminder
/// times.  Works entirely offline — no network calls are made.
///
/// Lifecycle
/// ---------
/// 1. Call [initialize] once (inside [ServiceLocator.initialize]).
/// 2. After adding or updating a medication call [scheduleForMedication].
/// 3. After deleting a medication call [cancelForMedication].
/// 4. On logout call [cancelAll] to remove every pending reminder.
class MedicationReminderService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // ─── Android channel ──────────────────────────────────────────────────────

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _kChannelId,
    _kChannelName,
    description: _kChannelDesc,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ─── Initialisation ───────────────────────────────────────────────────────

  /// Must be called once before scheduling any notifications.
  Future<void> initialize() async {
    // Set up the device-local timezone so zonedSchedule works correctly.
    tz.initializeTimeZones();
    try {
      // final tzName = await FlutterTimezone.getLocalTimezone();
      final tzName = 'Africa/Cairo';
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fall back to UTC if timezone detection fails (very rare edge-case).
      tz.setLocalLocation(tz.UTC);
    }

    // Also request the notification permission at scheduling time (in case the
    // user skipped the home-page prompt).
    final androidImpl = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();

    // On Android 12 (API 31-32), SCHEDULE_EXACT_ALARM requires an explicit
    // user grant via the system settings page.  Without it the service falls
    // back to inexact alarms, which OEM power-saving can delay by hours.
    // canScheduleExactNotifications returns true on API 33+ when
    // USE_EXACT_ALARM is declared, so this prompt only appears on API 31-32.
    final canExact = await androidImpl?.canScheduleExactNotifications();
    if (canExact == false) {
      await androidImpl?.requestExactAlarmsPermission();
    }

    // Initialise the plugin (tap routing is handled by PushNotificationService).
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    try {
      // Create the dedicated Android notification channel.
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    } catch (e) {}
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Cancels any existing reminders for [medication] then schedules a new
  /// daily notification for every [ReminderTime] in the medication's list.
  ///
  /// Safe to call both on **create** and **update**.
  Future<void> scheduleForMedication(MedicationModel medication) async {
    // Always cancel first so updates don't leave stale notifications.
    await cancelForMedication(medication.id);
    if (medication.reminderTimes.isEmpty) return;

    final scheduledIds = <int>[];

    // Determine whether the OS has granted exact-alarm scheduling.
    // USE_EXACT_ALARM (API 33+) is install-time so this is usually true;
    // SCHEDULE_EXACT_ALARM (API 31-32) needs user approval.  Fall back to
    // inexact mode so the notification still fires, albeit maybe a few minutes
    // late, rather than silently disappearing.
    final androidImpl = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final canUseExact =
        await androidImpl?.canScheduleExactNotifications() ?? true;
    // alarmClock uses AlarmManager.setAlarmClock(), which Android treats as a
    // user-visible alarm — it is exempt from Doze and OEM battery-saving
    // restrictions that often silently drop exactAllowWhileIdle alarms.
    final scheduleMode = canUseExact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (int i = 0; i < medication.reminderTimes.length; i++) {
      final reminder = medication.reminderTimes[i];
      final id = _notificationId(medication.id, i);

      final body = medication.dosage != null && medication.dosage!.isNotEmpty
          ? '${medication.name} · ${medication.dosage}'
          : medication.name;

      await _local.zonedSchedule(
        id: id,
        title: 'Medication Reminder'.tr(),
        body: '${'Time to take'.tr()} $body',
        scheduledDate: _nextInstanceOfTime(
          reminder.time.hour,
          reminder.time.minute,
        ),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kChannelId,
            _kChannelName,
            channelDescription: _kChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medication_reminder:${medication.id}',
      );

      scheduledIds.add(id);
    }

    await _saveIds(medication.id, scheduledIds);
  }

  /// Cancels all scheduled reminder notifications for [medicationId].
  Future<void> cancelForMedication(String medicationId) async {
    final ids = await _loadIds(medicationId);
    for (final id in ids) {
      await _local.cancel(id: id);
    }
    await _removeIds(medicationId);
  }

  /// Cancels **all** medication reminders.  Call on logout.
  Future<void> cancelAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_kPrefsPrefix))
        .toList(growable: false);

    // Cancel each individually so we only remove our reminders.
    for (final key in keys) {
      try {
        final raw = prefs.getString(key);
        if (raw != null) {
          final ids = (jsonDecode(raw) as List).cast<int>();
          for (final id in ids) {
            await _local.cancel(id: id);
          }
        }
      } catch (_) {}
      await prefs.remove(key);
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Generates a stable, deterministic notification ID for a specific
  /// reminder slot inside a medication, without relying on Dart's `hashCode`
  /// (which changed across Dart versions).
  int _notificationId(String medicationId, int index) {
    var hash = 5381;
    for (final unit in medicationId.codeUnits) {
      hash = ((hash << 5) + hash) ^ unit;
      hash = hash & 0x7FFFFFFF; // keep positive 31-bit
    }
    // Multiply by 10 to leave room for up to 10 reminders per medication.
    return (hash % 100000) * 10 + (index % 10);
  }

  /// Shows an immediate local notification confirming the medication was taken.
  Future<void> showTakenConfirmation(MedicationModel medication) async {
    final body = medication.dosage != null && medication.dosage!.isNotEmpty
        ? '${medication.name} · ${medication.dosage}'
        : medication.name;

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Medication is taken'.tr(),
      body: '$body ✓',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          channelDescription: _kChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: 'medication_taken:${medication.id}',
    );
  }

  /// Returns the next [tz.TZDateTime] for the given [hour]:[minute] in the
  /// device's local timezone.  If that time has already passed today, it
  /// returns tomorrow's occurrence.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── SharedPreferences persistence ───────────────────────────────────────

  Future<void> _saveIds(String medicationId, List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kPrefsPrefix$medicationId', jsonEncode(ids));
  }

  Future<List<int>> _loadIds(String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kPrefsPrefix$medicationId');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<int>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _removeIds(String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kPrefsPrefix$medicationId');
  }
}
