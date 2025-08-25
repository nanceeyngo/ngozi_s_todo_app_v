import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/models/todo.dart';


abstract interface class AddTodoController{
  TextEditingController get titleController;
  TextEditingController get descriptionController;
  Rxn<DateTime> get deadline;
  Rxn<Duration> get reminder;
  bool get isTitleValid;
  Future<void> save(TodoController todoController, {Todo? parent});
}

class AddTodoControllerImpl extends GetxController implements AddTodoController{

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _deadline = Rxn<DateTime>();
  final _reminder = Rxn<Duration>();

  @override
  TextEditingController get titleController => _titleController;

  @override
  TextEditingController get descriptionController => _descriptionController;

  @override
  Rxn<DateTime> get deadline => _deadline;

  @override
  Rxn<Duration> get reminder => _reminder;

  @override
  bool get isTitleValid => _titleController.text.trim().isNotEmpty;

  @override
  void onClose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.onClose();
  }

  @override
  Future<void> save(TodoController todoController, {Todo? parent}) async{
    final title = _titleController.text.trim();
    if(title.isEmpty){
      Get.snackbar('Error', 'Title is required');
      return;
    }

    final todo = Todo(
      title: title,
      description: _descriptionController.text.trim(),
      deadline: _deadline.value,
      reminderBefore: _reminder.value,
      parentId: parent?.id
    );
    await todoController.addOrUpdate(todo);

    if(parent != null){
      todoController.nestUnder(parent, todo);
    }

    Get.back();
  }

}