import 'dart:ui' show DartPluginRegistrant;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';


@pragma('vm:entry-point') // <- REQUIRED so Android can find it in background
void notificationCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized(); // register plugins on bg isolate

    // Minimal LN init on the background isolate
    final plugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(init);

    final title = (inputData?['title'] as String?) ?? 'Todo Reminder';
    final body  = (inputData?['body']  as String?) ?? '';
    final id    = (inputData?['todoId'] as int?) ?? 0;

    const android = AndroidNotificationDetails(
      'todo_workmanager_channel',
      'Todo WorkManager Notifications',
      channelDescription: 'Notifications triggered by WorkManager',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await plugin.show(id, title, body, const NotificationDetails(android: android));
    return true; // signal success to WorkManager
  });
}