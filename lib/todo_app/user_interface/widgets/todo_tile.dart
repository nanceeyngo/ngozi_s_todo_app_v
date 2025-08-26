import 'package:flutter/material.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/models/todo.dart';
import 'package:ngozi_s_todo_app_v/todo_app/user_interface/widgets/delete_alert_dialog.dart';
import 'package:ngozi_s_todo_app_v/todo_app/utils/fonts.dart';
import '../../utils/colors.dart';


class TodoTile extends StatelessWidget {
  const TodoTile({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    return DragTarget<Todo>(
      onWillAcceptWithDetails: (details) {
        final incoming = details.data;
        return controller.canNest(todo, incoming) && todo.parentId == null;
        // if (!allowed) {
        //   Get.snackbar(
        //     "Not Allowed",
        //     "You cannot nest ${incoming.title} under ${todo.title}",
        //     backgroundColor: AppColors.error,
        //     colorText: AppColors.surface
        //   );
        // }
        //
        // return allowed; // return whether we allow drop
      },
      onAcceptWithDetails: (details) async{
        final incoming = details.data;
        await controller.nestUnder(todo, incoming);
        Get.snackbar("Nested", "${incoming.title} is now a sub-task of ${todo.title}");
      },
      builder: (context, candidateData, rejectedData){
        // If something is being dragged over
        final isDraggingOver = candidateData.isNotEmpty;

        // If dragging but not accepted (rejectedData filled)
        final isRejected = rejectedData.isNotEmpty;

        return LongPressDraggable<Todo>(
          data: todo,
          feedback: Material(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.surface,
              child: Text(todo.title, style: s18w700.copyWith(color: AppColors.primaryDark)),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primaryDark,
                border: Border.all(
                  color: isRejected
                      ? Colors.red
                      : (isDraggingOver ? Colors.green : Colors.transparent),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white,
                      offset: Offset(0, 4),
                      blurRadius: 7
                  )
                ]
            ),
            child: ExpansionTile(
              key: ValueKey(todo.id),
              trailing: controller.canHaveChildren(todo)?Icon(
                Icons.keyboard_arrow_down, // or expand_more
                size: 30,
                color: AppColors.surface,
                weight: 3.0,
              ) : SizedBox(),
              //backgroundColor: AppColors.textPrimary,
              title: Row(
                children: [
                  Checkbox(
                    checkColor: AppColors.primaryDark,
                    side: BorderSide(width: 2.5, color: AppColors.surface),
                    activeColor: AppColors.surface,
                    value: todo.done,
                    onChanged: (_) => controller.toggleDone(todo),
                  ),
                  Expanded(
                      child: Text(todo.title,
                          style: s18w700.copyWith(color: AppColors.surface,
                            overflow: TextOverflow.ellipsis,))
                  ),
                  IconButton(
                      onPressed: (){
                        Get.toNamed('/todo_details', arguments: todo);
                      },
                      icon: Icon(Icons.info_outline_rounded, color: AppColors.surface,size: 18,)
                  ),
                  controller.canHaveChildren(todo)? IconButton(
                      icon: const Icon(Icons.add, color: AppColors.surface,),
                      tooltip: 'Add SubTodo',
                      onPressed: () {
                        Get.toNamed(
                            '/add_todo',
                            arguments: {'parent': todo}
                        );
                      }
                  ): SizedBox(),
                  IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error,),
                    onPressed: () async {
                      final confirmed = await Get.dialog(
                        DeleteAlertDialog(
                            title: 'Delete Todo',
                            content: "Are you sure you want to delete '${todo.title}'?",
                        )
                      );
                      if (confirmed == true) {
                        await controller.deleteTodo(todo);
                        Get.snackbar("Deleted", "'${todo.title}' was removed",
                        );
                      }
                    },
                  ),
                ],
              ),
              children: todo.subTodoIds
                  .map((id) => controller.findById(id))
                  .whereType<Todo>()
                  .map((child) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TodoTile(todo: child), // recursion
              )).toList(),
            ),
          ),
        );
      },
    );
  }
}
