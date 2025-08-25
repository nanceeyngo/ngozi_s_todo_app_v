import 'package:get/get.dart';
import '../models/mock_data.dart';
import '../models/mock_todo.dart';

class MockTodoController extends GetxController {
  final todos = <MockTodo>[].obs;

  MockTodoController() {
    todos.addAll(mockTodos);
  }

  MockTodo? findById(String id) => todos.firstWhereOrNull((t) => t.id == id);

  bool canNest(MockTodo parent, MockTodo child) => true;

  Future<void> nestUnder(MockTodo parent, MockTodo child) async {
    parent.subTodoIds.add(child.id);
    child.parentId = parent.id;
    todos.refresh();
  }

  Future<void> toggleDone(MockTodo todo) async {
    todo.done = !todo.done;
    todos.refresh();
  }
}