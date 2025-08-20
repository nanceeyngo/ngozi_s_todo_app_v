import 'package:get/get.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import '../services/todo_notification_service.dart';


abstract interface class TodoController{
  RxList<Todo> get todos;
  //void loadAll();
  Todo? findById(String id);
  List<Todo> topLevelTodos();
  List<Todo> childrenOf(String parentId);
  Future<void> reschedule(Todo todo);
  Future<void> addOrUpdate(Todo todo);
  Future<void> deleteTodo(Todo todo);
  Future<void> toggleDone(Todo todo);
  bool canNest(Todo parent, Todo child);
  Future<bool> nestUnder(Todo parent, Todo child);

}

class TodoControllerImpl extends GetxController implements TodoController{

  final TodoRepository _repo;
  final TodoNotificationService _notificationService;

  TodoControllerImpl({
    required TodoRepository repo,
    required TodoNotificationService notificationService
  }): _repo = repo,
        _notificationService = notificationService;

  final RxList<Todo> _todos = <Todo>[].obs; //flat list of all todos

  @override
  void onInit() {
    _todos.assignAll(_repo.getAll());//initial load
    super.onInit();
  }

  @override
  RxList<Todo> get todos => _todos;

  // @override
  // void loadAll() {
  //   todos.value = _repo.getAll();
  // }

  @override
  Todo? findById(String id) => _todos.firstWhereOrNull((test)=> test.id == id);

  @override
  List<Todo> topLevelTodos() => _todos.where((test)=> test.parentId == null).toList();

  @override
  List<Todo> childrenOf(String parentId) => _todos.where((test)=> test.parentId == parentId).toList();

  @override
  Future<void> reschedule(Todo todo) async {
    //cancel then schedule afresh --to avoid duplicating scheduling
    await _notificationService.cancelReminderForTodo(todo);
    if(!todo.done) await _notificationService.scheduleReminderForTodo(todo);
  }

  @override
  Future<void> addOrUpdate(Todo todo) async {
    await _repo.saveTodo(todo);
    await reschedule(todo);

    //loadAll();

    final index = _todos.indexWhere((test)=> test.id == todo.id);
    if(index >=0){
      _todos[index] = todo;
      Get.snackbar("Updated", "Todo updated successfully");
    }else{
      _todos.add(todo);
      Get.snackbar("Added", "Todo added successfully");
    }

  }

  @override
  Future<void> deleteTodo(Todo todo) async{
    //recursively delete children
    for(final childId in todo.subTodoIds.toList()){
      final child = findById(childId);
      if(child != null) await deleteTodo(child);
    }
    await _notificationService.cancelReminderForTodo(todo);
    Get.snackbar("Deleted", "Todo removed");
    await _repo.deleteTodo(todo.id);
    //loadAll();
    _todos.removeWhere((test)=> test.id == todo.id);//update the list directly
  }

  @override
  Future<void> toggleDone(Todo todo) async{

    todo.done = !todo.done; //Flipping the "done" flag (mutating the same object)
    final index = _todos.indexWhere((test)=> test.id == todo.id);
    if(index >= 0) _todos[index] = todo; //Updating the observable list so GetX notifies the UI

    //with copyWith, we never mutate the original object → avoids weird bugs with object references
    //If the project grows and there is need for stricter immutability, we switch to the copyWith syntax below.
    //final updated = todo.copyWith(done: !todo.done)
    //everywhere we have 'todo', we replace with 'updated'

    //saving to hive
    await _repo.saveTodo(todo);

    //handling reminders
    if(todo.done){
      await _notificationService.cancelReminderForTodo(todo);
      Get.snackbar("Completed", "Great job! Todo marked as done ✅");
    }else{
      await reschedule(todo);
      Get.snackbar("Pending", "Todo marked as pending again");
    }
  }

  @override
  bool canNest(Todo parent, Todo child) {
    //blocks self-nesting
    if(parent.id == child.id) return false;

    //prevents duplicates of a child in a parent
    if(child.parentId == parent.id) return false;

    //holds the values of visited IDs
    final visited = <String>{};

    //function to check if the would-be parent(lookForId) is a descendant of the would-be child(nodeId).
    bool isDescendant(String lookForId, String nodeId){
      //stop if we've seen this node already (protects against corrupted cyclic data)
      if(!visited.add(nodeId)) return false;

      final node = findById(nodeId);
      if(node == null) return false;

      if(node.subTodoIds.contains(lookForId)) return true;

      for(final subId in node.subTodoIds){
        if(isDescendant(lookForId, subId)) return true;
      }
      return false;
    }

    //blocks circular nesting if the would-be parent is a descendant of the would-be child.
    if(isDescendant(parent.id,child.id)) return false;

    return true;
  }

  @override
  Future<bool> nestUnder(Todo parent, Todo child) async{

    if(!canNest(parent, child)) return false;

    if(child.parentId != null){
      final oldParent = findById(child.parentId!);
      if(oldParent != null){
        oldParent.subTodoIds.remove(child.id);
        await _repo.saveTodo(oldParent);
        final index = _todos.indexWhere((test)=> test.id == oldParent.id);
        if(index >=0) _todos[index] = oldParent;
      }
    }
    child.parentId = parent.id;
    //guarding against child duplicates - may not be necessary since this is captured in our canNest function
    if(!parent.subTodoIds.contains(child.id)){
      parent.subTodoIds.add(child.id);
    }

    await _repo.saveTodo(child);
    await _repo.saveTodo(parent);

    //loadAll();

    final childIndex = _todos.indexWhere((test)=> test.id == child.id);
    if(childIndex >=0) _todos[childIndex] = child;

    final parentIndex = _todos.indexWhere((test)=> test.id == parent.id);
    if(parentIndex >=0) _todos[parentIndex] = parent;

    return true;

  }

}