import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_routes.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: ToDoRoutes.getRoutes(),
      initialRoute: '/',
      //initialBinding: TodDoBindings(),
    );
  }
}