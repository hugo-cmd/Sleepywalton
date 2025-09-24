import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';
import 'storage_service.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static Timer? _alarmCheckTimer;

  static Future<void> init() async {
    if (_isInitialized) return;

    // Request notification permission
    final status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Notification permission denied');
    }

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Start alarm checking timer
    _startAlarmCheckTimer();

    _isInitialized = true;
  }

  static void _startAlarmCheckTimer() {
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndScheduleAlarms(),
    );
  }

  static Future<void> _checkAndScheduleAlarms() async {
    final enabledAlarms = StorageService.getEnabledAlarms();
    final now = DateTime.now();

    for (final alarm in enabledAlarms) {
      final nextAlarmTime = alarm.nextAlarmTime;
      
      // Check if alarm should trigger in the next minute
      if (nextAlarmTime.difference(now).inMinutes <= 1) {
        await _scheduleAlarm(alarm, nextAlarmTime);
      }
    }
  }

  static Future<void> _scheduleAlarm(Alarm alarm, DateTime alarmTime) async {
    final notificationId = alarm.id.hashCode;
    
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Notifications for alarm triggers',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      alarm.name,
      'Tap to dismiss alarm',
      tz.TZDateTime.from(alarmTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: alarm.isRepeating 
          ? DateTimeComponents.time 
          : null,
    );
  }


  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - this could open the alarm trigger screen
    // For now, we'll just log it
    print('Alarm notification tapped: ${response.payload}');
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isEnabled) return;

    final nextAlarmTime = alarm.nextAlarmTime;
    await _scheduleAlarm(alarm, nextAlarmTime);
  }

  static Future<void> cancelAlarm(String alarmId) async {
    final notificationId = alarmId.hashCode;
    await _notifications.cancel(notificationId);
  }

  static Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
  }

  static Future<void> rescheduleAllAlarms() async {
    await cancelAllAlarms();
    
    final enabledAlarms = StorageService.getEnabledAlarms();
    for (final alarm in enabledAlarms) {
      await scheduleAlarm(alarm);
    }
  }

  static Future<void> dismissAlarm(String alarmId, {
    String? nfcTagId,
    DismissalMethod method = DismissalMethod.standard,
    int? wakeLatencySeconds,
  }) async {
    // Cancel the notification
    await cancelAlarm(alarmId);

    // Log the wake-up
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      final existingLog = StorageService.getSleepLogByDate(today);
      final updatedLog = existingLog?.copyWith(
        wakeTime: now,
        nfcTagId: nfcTagId,
        wakeLatencySeconds: wakeLatencySeconds,
        dismissalMethod: method,
        updatedAt: now,
      );
      if (updatedLog != null) {
        await StorageService.saveSleepLog(updatedLog);
      }
    } catch (e) {
      // Create new sleep log if none exists
      final newLog = SleepLog(
        id: '${today.millisecondsSinceEpoch}',
        date: today,
        wakeTime: now,
        nfcTagId: nfcTagId,
        wakeLatencySeconds: wakeLatencySeconds,
        dismissalMethod: method,
        createdAt: now,
        updatedAt: now,
      );
      await StorageService.saveSleepLog(newLog);
    }

    // Reschedule if it's a repeating alarm
    final alarm = StorageService.getAlarm(alarmId);
    if (alarm != null && alarm.isRepeating) {
      await scheduleAlarm(alarm);
    }
  }

  static Future<void> logSleepTime(String? nfcTagId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      final existingLog = StorageService.getSleepLogByDate(today);
      final updatedLog = existingLog?.copyWith(
        bedtime: now,
        nfcTagId: nfcTagId,
        updatedAt: now,
      );
      if (updatedLog != null) {
        await StorageService.saveSleepLog(updatedLog);
      }
    } catch (e) {
      // Create new sleep log if none exists
      final newLog = SleepLog(
        id: '${today.millisecondsSinceEpoch}',
        date: today,
        bedtime: now,
        nfcTagId: nfcTagId,
        createdAt: now,
        updatedAt: now,
      );
      await StorageService.saveSleepLog(newLog);
    }
  }

  static void dispose() {
    _alarmCheckTimer?.cancel();
    _isInitialized = false;
  }
}
