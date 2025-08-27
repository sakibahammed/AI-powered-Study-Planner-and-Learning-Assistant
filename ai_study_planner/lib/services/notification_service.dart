import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _lastError;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  Future<bool> initialize() async {
    if (_isInitialized) {
      print('🔔 Notification service already initialized');
      return _isAvailable;
    }

    try {
      print('🔔 Starting notification service initialization...');

      await _initializeTimezone();

      final pluginInitialized = await _initializePlugin();
      if (!pluginInitialized) {
        _markAsUnavailable('Plugin initialization failed');
        return false;
      }

      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        _markAsUnavailable('Permissions not granted');
        return false;
      }

      _isInitialized = true;
      _isAvailable = true;
      _lastError = null;

      print('✅ Notification service fully initialized and available');
      return true;
    } catch (e) {
      _markAsUnavailable('Initialization error: $e');
      return false;
    }
  }

  Future<void> _initializeTimezone() async {
    try {
      tz.initializeTimeZones();
      print('✅ Timezone initialized');
    } catch (e) {
      print('⚠️ Timezone initialization failed (non-critical): $e');
    }
  }

  Future<bool> _initializePlugin() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);
      print('✅ Notifications plugin initialized');
      return true;
    } catch (e) {
      print('❌ Plugin initialization failed: $e');
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        print('📱 Android notification permission: $granted');
        if (granted == false) {
          print('⚠️ Android notifications not permitted');
          return false;
        }
      }

      print('🍎 iOS permissions are handled during initialization');
      print('✅ All permissions granted');
      return true;
    } catch (e) {
      print('❌ Permission request failed: $e');
      return false;
    }
  }

  void _markAsUnavailable(String reason) {
    _isInitialized = true;
    _isAvailable = false;
    _lastError = reason;
    print('❌ Notification service marked as unavailable: $reason');
  }

  /// Schedule a task notification using SUPER SIMPLE approach
  Future<bool> scheduleTaskNotification(Task task) async {
    try {
      print(
        '🔔 SUPER SIMPLE - scheduling task notification for: ${task.title}',
      );

      // Validate task has time
      if (task.dueDate.hour == 0 && task.dueDate.minute == 0) {
        print('⚠️ Task has no specific time, skipping notification');
        return false;
      }

      // Calculate notification time (5 minutes before task)
      final notificationTime = task.dueDate.subtract(Duration(minutes: 5));
      print('🔔 Notification will be sent at: $notificationTime');

      // Don't schedule if time has passed
      if (notificationTime.isBefore(DateTime.now())) {
        print('⚠️ Notification time has passed, skipping');
        return false;
      }

      // Use the SAME approach as super simple notification
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      );

      // Schedule using zonedSchedule (same as super simple but scheduled)
      await _notifications.zonedSchedule(
        task.id.hashCode,
        'Get ready to crush ${task.title} and grow! 💪',
        'Your task "${task.title}" starts in 5 minutes. Time to shine! ✨',
        tz.TZDateTime.from(notificationTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );

      print('✅ SUPER SIMPLE task notification scheduled successfully!');
      return true;
    } catch (e) {
      print('❌ SUPER SIMPLE task notification failed: $e');
      return false;
    }
  }

  /// Cancel a task notification
  Future<bool> cancelTaskNotification(Task task) async {
    try {
      await _notifications.cancel(task.id.hashCode);
      print('✅ Notification cancelled for task: ${task.title}');
      return true;
    } catch (e) {
      print('❌ Failed to cancel notification: $e');
      return false;
    }
  }

  /// Cancel all notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
      return true;
    } catch (e) {
      print('❌ Failed to cancel all notifications: $e');
      return false;
    }
  }

  /// SUPER SIMPLE - just show a notification, no checks, no nothing
  Future<bool> superSimpleNotification() async {
    try {
      print('🔥 SUPER SIMPLE NOTIFICATION - NO CHECKS AT ALL...');

      // Create a basic notification details object
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Test notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      );

      // Show the notification
      await _notifications.show(
        777,
        '🔥 FIRE NOTIFICATION 🔥',
        'This should work no matter what!',
        details,
      );

      print('✅ SUPER SIMPLE notification sent!');
      return true;
    } catch (e) {
      print('❌ SUPER SIMPLE failed: $e');
      return false;
    }
  }
}
