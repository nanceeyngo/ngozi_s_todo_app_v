import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ngozi_s_todo_app_v/todo_app.dart';
import 'package:ngozi_s_todo_app_v/todo_app/services/todo_notification_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('todos');

  final notificationService = TodoNotificationServiceImpl();
  await notificationService.init();

  Get.put<TodoNotificationService>(notificationService, permanent: true);

  runApp(const TodoApp());
}

