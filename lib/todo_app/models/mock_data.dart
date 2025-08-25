import 'package:ngozi_s_todo_app_v/todo_app/models/mock_todo.dart';

final mockTodos = [
  MockTodo(id: "1", title: "Buy groceries", subTodoIds: ["2", "3"]),
  MockTodo(id: "2", title: "Buy milk", parentId: "1", subTodoIds: ["11"]),
  MockTodo(id: "3", title: "Buy bread", parentId: "1"),
  MockTodo(id: "4", title: "Clean room"),
  MockTodo(id: "5", title: "Go shopping", subTodoIds: ["7", "8"]),
  MockTodo(id: "6", title: "Visit friend"),
  MockTodo(id: "7", title: "Buy clothes", parentId: "5"),
  MockTodo(id: "8", title: "Buy shoes", parentId: "5"),
  MockTodo(id: "9", title: "Sweep hall"),
  MockTodo(id: "10", title: "Wash car"),
  MockTodo(id: "11", title: "Buy Dano Milk", parentId: "5"),
];