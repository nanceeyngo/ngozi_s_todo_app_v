import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/todo_controller.dart';
import '../../models/todo.dart';
import '../../utils/colors.dart';
import '../../utils/fonts.dart';


class TodoDetailsPage extends StatelessWidget {
  const TodoDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Todo todo = Get.arguments as Todo;
    final controller = Get.find<TodoController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Todo Details",
            style: s26w700.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Title", style: s18w700.copyWith(color: AppColors.primaryDark)),
            SizedBox(height: 4),
            Text(todo.title, style: s16w500),
            SizedBox(height: 16),

            if (todo.description != null) ...[
              Text("Description", style: s18w700.copyWith(color: AppColors.primaryDark)),
              SizedBox(height: 4),
              Text(todo.description!, style: s16w400),
              SizedBox(height: 16),
            ],

            if (todo.deadline != null) ...[
              Text("Deadline", style: s18w700.copyWith(color: AppColors.primaryDark)),
              SizedBox(height: 4),
              Text(
                  todo.deadline!.toLocal().toString().split('.')[0], // shows date & time
                  style: s16w400),
              SizedBox(height: 16),
            ],

            if (todo.reminderBefore != null) ...[
              Text("Reminder", style: s18w700.copyWith(color: AppColors.primaryDark)),
              SizedBox(height: 4),
              Text("${todo.reminderBefore!.inMinutes} minutes before",
                  style: s16w400),
              SizedBox(height: 16),
            ],

            if (todo.subTodoIds.isNotEmpty) ...[
              Text("Sub Todos", style: s18w700.copyWith(color: AppColors.primaryDark)),
              SizedBox(height: 8),
              Column(
                children: todo.subTodoIds
                    .map((id) => controller.findById(id))
                    .whereType<Todo>()
                    .map(
                      (sub) => ListTile(
                        key: ValueKey(sub.id),
                    title: Text(sub.title, style: s16w500),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Get.to(()=> TodoDetailsPage(), arguments: sub);
                      },
                    ),
                  ),
                ).toList(),
              )
            ],
          ],
        ),
      ),
    );
  }
}
