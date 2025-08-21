import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/user_interface/widgets/todo_tile.dart';
import 'package:ngozi_s_todo_app_v/todo_app/utils/colors.dart';
import '../../utils/fonts.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Todos',
          style: s26w700.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx((){
        final todos = controller.topLevelTodos();
        if(todos.isEmpty) {
          return Center(child: Text('No todos yet',
            style: s26w700.copyWith(color: AppColors.textPrimary),),);
        }
        return ListView(
          children: todos.map((todo) => TodoTile(todo: todo)).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/add_todo'),
        child: Icon(Icons.add, size: 36, color: AppColors.textPrimary,),
      ),
    );
  }
}
