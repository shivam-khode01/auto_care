import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import '../data/models/models.dart';
import 'database_service.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  final logger = Logger();
  final DatabaseService _dbService = DatabaseService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late StreamController<SafetyAlarm> _alarmTriggeredStream;
  Timer? _alarmCheckTimer;
  String? _currentUserId;

  AlarmService._internal() {
    _alarmTriggeredStream = StreamController<SafetyAlarm>.broadcast();
    _initializeNotifications();
  }

  factory AlarmService() {
    return _instance;
  }

  Stream<SafetyAlarm> get alarmTriggeredStream => _alarmTriggeredStream.stream;

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      logger.i('Notifications initialized successfully');
    } catch (e) {
      logger.e('Error initializing notifications: $e');
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    logger.i('Notification tapped: ${response.payload}');
  }

  void startAlarmMonitoring(String userId) {
    if (_currentUserId == userId && _alarmCheckTimer?.isActive == true) {
      logger.i('Alarm monitoring already running for user: $userId');
      return;
    }

    _currentUserId = userId;
    logger.i('Starting alarm monitoring for user: $userId');

    // Check alarms immediately
    _checkAndTriggerAlarms();

    // Then check every minute
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer =
        Timer.periodic(Duration(seconds: AppConstants.alarmCheckIntervalSeconds),
            (_) {
      _checkAndTriggerAlarms();
    });
  }

  void stopAlarmMonitoring() {
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = null;
    logger.i('Alarm monitoring stopped');
  }

  Future<void> _checkAndTriggerAlarms() async {
    if (_currentUserId == null) return;

    try {
      final alarms = await _dbService.getAlarms(_currentUserId!);

      for (final alarm in alarms) {
        if (!alarm.isActive) continue;

        final now = DateTime.now();
        final scheduledTime = alarm.scheduledTime;

        bool shouldTrigger = false;

        if (alarm.recurrence == 'NONE') {
          // One-time alarm
          if (now.isAfter(scheduledTime) &&
              now.difference(scheduledTime).inMinutes < 1 &&
              (alarm.lastTriggered == null ||
                  now.difference(alarm.lastTriggered!).inMinutes > 1)) {
            shouldTrigger = true;
          }
        } else if (alarm.recurrence == 'DAILY') {
          // Check if time matches (within 1 minute window)
          if (now.hour == scheduledTime.hour &&
              now.minute == scheduledTime.minute &&
              (alarm.lastTriggered == null ||
                  now.difference(alarm.lastTriggered!).inHours > 23)) {
            shouldTrigger = true;
          }
        } else if (alarm.recurrence == 'WEEKLY') {
          // Check if day and time match
          if (alarm.recurrenceDays?.contains(now.weekday) == true &&
              now.hour == scheduledTime.hour &&
              now.minute == scheduledTime.minute &&
              (alarm.lastTriggered == null ||
                  now.difference(alarm.lastTriggered!).inDays > 6)) {
            shouldTrigger = true;
          }
        } else if (alarm.recurrence == 'MONTHLY') {
          // Check if date and time match
          if (now.day == scheduledTime.day &&
              now.hour == scheduledTime.hour &&
              now.minute == scheduledTime.minute &&
              (alarm.lastTriggered == null ||
                  now.difference(alarm.lastTriggered!).inDays > 28)) {
            shouldTrigger = true;
          }
        }

        if (shouldTrigger) {
          await _triggerAlarm(alarm);
        }
      }
    } catch (e) {
      logger.e('Error checking alarms: $e');
    }
  }

  Future<void> _triggerAlarm(SafetyAlarm alarm) async {
    try {
      logger.i('Triggering alarm: ${alarm.id}');

      // Update last triggered time
      await _dbService.updateAlarm(
        alarm.copyWith(lastTriggered: DateTime.now()),
      );

      // Show notification
      await _showAlarmNotification(alarm);

      // Emit event
      _alarmTriggeredStream.add(alarm);
    } catch (e) {
      logger.e('Error triggering alarm: $e');
    }
  }

  Future<void> _showAlarmNotification(SafetyAlarm alarm) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        color: Colors.blue,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        alarm.id.hashCode,
        alarm.title,
        alarm.description,
        platformDetails,
        payload: alarm.id,
      );
    } catch (e) {
      logger.e('Error showing alarm notification: $e');
    }
  }

  Future<void> createAlarm(SafetyAlarm alarm) async {
    try {
      await _dbService.insertAlarm(alarm);
      logger.i('Alarm created: ${alarm.id}');
    } catch (e) {
      logger.e('Error creating alarm: $e');
      rethrow;
    }
  }

  Future<void> updateAlarm(SafetyAlarm alarm) async {
    try {
      await _dbService.updateAlarm(alarm);
      logger.i('Alarm updated: ${alarm.id}');
    } catch (e) {
      logger.e('Error updating alarm: $e');
      rethrow;
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    try {
      await _dbService.deleteAlarm(alarmId);
      logger.i('Alarm deleted: $alarmId');
    } catch (e) {
      logger.e('Error deleting alarm: $e');
      rethrow;
    }
  }

  Future<List<SafetyAlarm>> getAlarms(String userId) async {
    try {
      return await _dbService.getAlarms(userId);
    } catch (e) {
      logger.e('Error getting alarms: $e');
      return [];
    }
  }

  Future<void> snoozeAlarm(SafetyAlarm alarm, int minutes) async {
    try {
      final newScheduledTime =
          DateTime.now().add(Duration(minutes: minutes));
      await updateAlarm(alarm.copyWith(scheduledTime: newScheduledTime));
      logger.i('Alarm snoozed for $minutes minutes: ${alarm.id}');
    } catch (e) {
      logger.e('Error snoozing alarm: $e');
      rethrow;
    }
  }

  Future<void> dismissAlarm(SafetyAlarm alarm) async {
    try {
      // Cancel notification
      await _notificationsPlugin.cancel(alarm.id.hashCode);
      logger.i('Alarm dismissed: ${alarm.id}');
    } catch (e) {
      logger.e('Error dismissing alarm: $e');
    }
  }

  void dispose() {
    stopAlarmMonitoring();
    _alarmTriggeredStream.close();
  }
}
