import '../models/todo.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class TodoRepository{
  List<Todo> getAll();
  Todo? getById(String id);
  Future<void> saveTodo(Todo todo);
  Future<void> deleteTodo(String id);
  Future<void> clearAllTodo();
}

class TodoRepoImpl implements TodoRepository{
  final Box _box;

  TodoRepoImpl({required Box box}): _box = box;

  @override
  List<Todo> getAll(){
    return _box.values.map((element) =>
        Todo.fromJson(Map<String, dynamic>.from(element))).toList();
  }

  @override
  Todo? getById(String id){
    final data = _box.get(id);
    if(data == null) return null;
    return Todo.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveTodo(Todo todo) async{
    await _box.put(todo.id, todo.toJson());
  }

  @override
  Future<void> deleteTodo(String id) async{
    await _box.delete(id);
  }

  @override
  Future<void> clearAllTodo() async => await _box.clear();

}