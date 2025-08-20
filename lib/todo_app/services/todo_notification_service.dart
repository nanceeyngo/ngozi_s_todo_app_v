import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/todo.dart';

abstract interface class TodoNotificationService {
  FlutterLocalNotificationsPlugin get plugin;
  Future<void> init();
  Future<void> scheduleReminderForTodo(Todo todo);
  Future<void> cancelReminderForTodo(Todo todo);
}

class TodoNotificationServiceImpl implements TodoNotificationService{

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  @override
  Future<void> init() async{
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(const InitializationSettings(
        android: android,
        iOS: ios
    ));

    //initialize timezone package
    tzdata.initializeTimeZones();
    final String localtz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localtz));
  }

  @override
  Future<void> scheduleReminderForTodo(Todo todo) async{

    final reminder = todo.reminderDateTime;
    if(reminder == null) return;
    final tz.TZDateTime scheduled = tz.TZDateTime.from(reminder, tz.local);
    if(scheduled.isBefore(tz.TZDateTime.now(tz.local))){
      return;
    }
    final androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo reminders',
        channelDescription: 'Remind before deadlines',
        importance: Importance.max,
        priority: Priority.max
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      todo.id.hashCode,
      'Reminder: ${todo.title}',
      todo.description?? '',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

  }

  @override
  Future<void> cancelReminderForTodo(Todo todo) async{
    await _plugin.cancel(todo.id.hashCode);
  }

}