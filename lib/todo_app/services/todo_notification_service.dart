import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ngozi_s_todo_app_v/todo_app/services/workmanage_guard.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:workmanager/workmanager.dart';

import '../models/todo.dart';

abstract interface class TodoNotificationService {
  FlutterLocalNotificationsPlugin get plugin;
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> scheduleReminderForTodo(Todo todo);
  Future<void> cancelReminderForTodo(Todo todo);
}

class TodoNotificationServiceImpl implements TodoNotificationService{

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  @override
  Future<void> init() async{
      //initialize timezone package
      tzdata.initializeTimeZones();
      final String localtz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localtz));

    const AndroidNotificationChannel workmanagerChannel = AndroidNotificationChannel(
      'todo_workmanager_channel',
      'Todo WorkManager Notifications',
      description: 'Notifications triggered by WorkManager',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(workmanagerChannel);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      initSettings,
    );
    // Request permissions after initialization
    await requestPermissions();

  }

  @override
  Future<void> requestPermissions() async {
    // Request Android 13+ notification permissions
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+
      await androidPlugin.requestExactAlarmsPermission();
    }
    // Request iOS permissions
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Future<void> scheduleReminderForTodo(Todo todo) async{

    final reminder = todo.reminderDateTime;
    if(reminder == null) return;

    // Make sure native WorkManager is initialized
    await WorkmanagerGuard.ensureInitialized();

    final tz.TZDateTime scheduled = tz.TZDateTime.from(reminder, tz.local);
    final scheduledTime = reminder;
    final now = tz.TZDateTime.now(tz.local);

    if(scheduled.isBefore(tz.TZDateTime.now(tz.local))){
      return;
    }
    // Calculate delay duration
    final delay = scheduledTime.difference(now);
    final uniqueName = 'todo_reminder_${todo.id}';

      await Workmanager().registerOneOffTask(
        uniqueName,
        'showNotification',
        initialDelay: delay,
        inputData: {
          'title': 'Todo Reminder: ${todo.title}',
          'body': todo.description ?? 'You have a todo item due',
          'todoId': todo.id.hashCode,
        },
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
  }


  @override
  Future<void> cancelReminderForTodo(Todo todo) async{
    final uniqueName = 'todo_reminder_${todo.id}';
    await Workmanager().cancelByUniqueName(uniqueName);
  }

}


// Future<void> showImmediateNotification(String title, String body) async {
//   const androidDetails = AndroidNotificationDetails(
//     'immediate_channel',
//     'Immediate Notifications',
//     channelDescription: 'Immediate notifications for testing',
//     importance: Importance.high,
//     priority: Priority.high,
//   );
//
//   const details = NotificationDetails(android: androidDetails);
//
//   await _plugin.show(
//     DateTime.now().millisecondsSinceEpoch.remainder(100000),
//     title,
//     body,
//     details,
//   );
// }
//
// // Debug method to list all pending notifications
// @override
// Future<void> listPendingNotifications() async {
//   final pending = await _plugin.pendingNotificationRequests();
//   print('Pending notifications: ${pending.length}');
//   for (final notification in pending) {
//     print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
//   }
// }

// @override
// Future<void> scheduleReminderForTodo(Todo todo) async{
//
//   final reminder = todo.reminderDateTime;
//   if(reminder == null) return;
//
//   final enabled = await areNotificationsEnabled();
//   if (!enabled) {
//     print('Notifications are not enabled');
//     return;
//   }
//
//   final tz.TZDateTime scheduled = tz.TZDateTime.from(reminder, tz.local);
//   final now = tz.TZDateTime.now(tz.local);
//
//   print('Current time: $now');
//   print('Scheduled time: $scheduled');
//   if(scheduled.isBefore(tz.TZDateTime.now(tz.local))){
//     return;
//   }
//
//   final androidDetails = AndroidNotificationDetails(
//     'todo_channel',
//     'Todo reminders',
//     channelDescription: 'Remind before deadlines',
//     importance: Importance.high,
//     priority: Priority.high,
//     enableVibration: true,
//     playSound: true,
//     icon: '@mipmap/ic_launcher',
//   );
//   final details = NotificationDetails(android: androidDetails);
//
//   final notificationId = todo.id.hashCode;
//
//   await _plugin.zonedSchedule(
//     todo.id.hashCode,
//     'Reminder: ${todo.title}',
//     todo.description?? '',
//     scheduled,
//     details,
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   );
//
//   print('Scheduled notification for "${todo.title}" at $scheduled with ID: $notificationId');
//
//   // Verify the notification was scheduled
//   final pendingNotifications = await _plugin.pendingNotificationRequests();
//   final scheduledNotification = pendingNotifications.where((n) => n.id == notificationId).firstOrNull;
//   if (scheduledNotification != null) {
//     print('Notification successfully scheduled: ${scheduledNotification.title}');
//   } else {
//     print('Warning: Notification may not have been scheduled properly');
//   }
//
// }