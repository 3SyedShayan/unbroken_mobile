import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:unbroken_mobile/services/logging/app_log.dart';

/// Centralized Local Notification Service for scheduling daily reminders.
///
/// Features:
/// - Strictly local (zero Firebase/network dependency).
/// - Exact zoned scheduling with daily time-matching.
/// - Android notification channel creation and graceful permission requests.
/// - Resilient fallback to inexact scheduling if exact alarm is restricted.
class LocalNotificationService {
  static LocalNotificationService _instance = LocalNotificationService._();
  LocalNotificationService._();
  factory LocalNotificationService() => _instance;

  @visibleForTesting
  LocalNotificationService.test();

  static LocalNotificationService get ins => _instance;

  @visibleForTesting
  static set ins(LocalNotificationService svc) => _instance = svc;

  FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  void setPluginForTesting(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
  }

  static const int morningReminderId = 1001;
  static const int nightReminderId = 1002;

  static const String channelId = 'unbroken_daily_reminders';
  static const String channelName = 'Daily Reminders';
  static const String channelDescription =
      'Scheduled notifications for planning tasks and completing daily goals';

  static const String morningPayload = 'open_focus_tasks';
  static const String nightPayload = 'open_habits_goals';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes the local notification plugin and sets up timezone locations.
  Future<void> init({
    void Function(NotificationResponse)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      final timeZone = await FlutterTimezone.getLocalTimezone();
      try {
        tz.setLocalLocation(tz.getLocation(timeZone.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      'Failed to initialize timezone for notifications: $e'.appLog();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTapped?.call(response);
      },
    );

    _isInitialized = true;
  }

  /// Requests notification permissions on iOS and Android (API 33+).
  Future<bool> requestPermissions() async {
    bool? granted = false;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return granted ?? false;
  }

  /// Calculates the next occurrence of a given [hour] and [minute] in the local timezone.
  tz.TZDateTime nextInstanceOfTime(int hour, int minute, [tz.Location? location]) {
    final loc = location ?? tz.local;
    final now = tz.TZDateTime.now(loc);
    var scheduledDate = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Parses a 24-hr format string "HH:mm" into a record of (hour, minute).
  (int, int) parseTimeString(String timeString, {int defaultHour = 9, int defaultMinute = 0}) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        return (h, m);
      }
    }
    return (defaultHour, defaultMinute);
  }

  /// Schedules a recurring daily notification at [hour]:[minute].
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final scheduledDate = nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      // Fallback to inexact alarm if system restricts exact alarms
      'Exact alarm not permitted, falling back to inexact: $e'.appLog();
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
  }

  /// Cancels a notification by its ID.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Syncs and reschedules all reminders according to user preferences.
  Future<void> rescheduleDailyReminders({
    required bool morningEnabled,
    required String morningTime,
    required bool nightEnabled,
    required String nightTime,
  }) async {
    if (morningEnabled) {
      final (mHour, mMinute) = parseTimeString(morningTime, defaultHour: 9, defaultMinute: 0);
      await scheduleDailyNotification(
        id: morningReminderId,
        title: 'Plan Your Day ☀️',
        body: 'What are your 3 core focus tasks for today? Take a minute to add them.',
        hour: mHour,
        minute: mMinute,
        payload: morningPayload,
      );
    } else {
      await cancel(morningReminderId);
    }

    if (nightEnabled) {
      final (nHour, nMinute) = parseTimeString(nightTime, defaultHour: 21, defaultMinute: 0);
      await scheduleDailyNotification(
        id: nightReminderId,
        title: 'Complete Your Daily Goals 🌙',
        body: 'Check in on your daily habits and wrap up today\'s focus before the day ends.',
        hour: nHour,
        minute: nMinute,
        payload: nightPayload,
      );
    } else {
      await cancel(nightReminderId);
    }
  }
}
