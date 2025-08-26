import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/user_interface/widgets/delete_alert_dialog.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Tasks',
                    style: s30w700.copyWith(color: AppColors.textPrimary)),
                IconButton(
                    onPressed: () async{
                      final confirmed = await Get.dialog(
                        DeleteAlertDialog(
                            title: 'Delete all Todos',
                            content: 'Are you sure you want to delete all Todos?'
                        )
                      );
                      if (confirmed == true) {
                        await controller.deleteAll();
                        Get.snackbar("Deleted", "All Todos deleted",
                          // backgroundColor: AppColors.error,
                          // colorText: AppColors.surface
                        );
                      }
                    },
                    icon: Icon(Icons.delete, size: 30, color: AppColors.primaryDark,)
                )
              ],
            ),
          ),
          Expanded(
            child: Obx((){
                  final todos = controller.topLevelTodos();
                  if(todos.isEmpty) {
                    return Center(child: Text('No TODOs yet',
                      style: s26w700.copyWith(color: AppColors.textPrimary),),);
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index){
                        return TodoTile(todo: todos[index]);
                      }
                    ),
                  );
                  //Alternatively use listview -ListView(children: todos.map((todo) => TodoTile(todo: todo)).toList(),)
                }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/add_todo'),
        child: Icon(Icons.add, size: 36, color: AppColors.textPrimary,),
      ),
    );
  }
}
