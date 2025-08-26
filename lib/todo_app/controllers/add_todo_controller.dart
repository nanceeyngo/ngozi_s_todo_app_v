import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/models/todo.dart';


abstract interface class AddTodoController{
  TextEditingController get titleController;
  TextEditingController get descriptionController;
  Rxn<DateTime> get deadline;
  Rxn<Duration?> get reminder;
  List<Duration?> get reminderOptions;
  bool get isTitleValid;
  String formatReminder(Duration? d);
  Future<Map<String, dynamic>> save(TodoController todoController, {Todo? parent});
}

class AddTodoControllerImpl extends GetxController implements AddTodoController{

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _deadline = Rxn<DateTime>();
  final _reminder = Rxn<Duration?>(null);



  final _reminderOptions = <Duration?>[
    null, //means no reminder
    const Duration(minutes: 5),
    const Duration(minutes: 10),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(hours: 3),
    const Duration(hours: 4),
    const Duration(hours: 5),
  ];


  @override
  List<Duration?> get reminderOptions => _reminderOptions;

  @override
  String formatReminder(Duration? d) {
    if (d == null) return "Remind me";
    if (d.inMinutes < 60) return "${d.inMinutes} min before";
    return "${d.inHours} hr${d.inHours > 1 ? 's' : ''} before";
  }

  @override
  TextEditingController get titleController => _titleController;

  @override
  TextEditingController get descriptionController => _descriptionController;

  @override
  Rxn<DateTime> get deadline => _deadline;

  @override
  Rxn<Duration?> get reminder => _reminder;

  @override
  bool get isTitleValid => _titleController.text.trim().isNotEmpty;

  @override
  void onClose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.onClose();
  }

  @override
  Future<Map<String, dynamic>> save(TodoController todoController, {Todo? parent}) async{
    final title = _titleController.text.trim();
    if (title.isEmpty) return {"success": false, "updated": false, "isSub": parent != null};
        final todo = Todo(
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          deadline: _deadline.value,
          reminderBefore: _reminder.value,
          parentId: parent?.id,
        );
    final updated = await todoController.addOrUpdate(todo);
    //
    // if(parent != null){
    //   todoController.nestUnder(parent, todo);
    // }
    Get.back(result: {"success": true,"updated": updated, "isSub": parent != null});
    return {"success": true,"updated": updated, "isSub": parent != null};

  }

}