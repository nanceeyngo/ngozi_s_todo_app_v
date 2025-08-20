import 'package:get/get.dart';
import 'package:ngozi_s_todo_app_v/todo_app/user_interface/pages/pages.dart';

class ToDoRoutes{
  static List<GetPage> getRoutes(){
    return[
      GetPage(name: '/', page: () => TodoListPage()),
      GetPage(name: '/add_todo', page: () => AddTodoPage()),
      GetPage(name: '/edit_todo', page: () => EditTodoPage()),
      GetPage(name: '/todo_details', page: () => TodoDetailsPage())
    ];
  }
}