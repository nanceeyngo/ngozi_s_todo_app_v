import 'package:flutter/material.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/models/todo.dart';
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
        return controller.canNest(todo, incoming);
      },
      onAcceptWithDetails: (details) async{
        final incoming = details.data;
        await controller.nestUnder(todo, incoming);
        Get.snackbar("Nested", "${incoming.title} is now a sub-task of ${todo.title}");
      },
      builder: (context, candidateData, rejectedData){
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
              trailing: Icon(
                Icons.keyboard_arrow_down, // or expand_more
                size: 30,
                color: AppColors.surface,
                weight: 3.0,
              ),
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
                      child: Text(todo.title, style: s24w700.copyWith(color: AppColors.surface))
                  ),
                  IconButton(
                      icon: const Icon(Icons.add, color: AppColors.surface,),
                      onPressed: () {}
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
