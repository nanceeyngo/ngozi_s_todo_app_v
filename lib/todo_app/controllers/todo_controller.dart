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
  Future<bool> addOrUpdate(Todo todo);
  Future<void> deleteTodo(Todo todo);
  Future<void> deleteAll();
  Future<void> toggleDone(Todo todo);
  bool canNest(Todo parent, Todo child);
  Future<bool> nestUnder(Todo parent, Todo child);
  bool canHaveChildren(Todo todo);

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
    // await _notificationService.cancelReminderForTodo(todo);
    // if(!todo.done) await _notificationService.scheduleReminderForTodo(todo);
    try {
      // Cancel any existing reminder first
      await _notificationService.cancelReminderForTodo(todo);

      // Only schedule if todo is not done, has a deadline, and reminder is valid
      if (!todo.done && todo.deadline != null && todo.reminderBefore != null) {
        final reminderTime = todo.deadline!.subtract(todo.reminderBefore!);

        // Prevent scheduling in the past
        if (reminderTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleReminderForTodo(todo);
        } else {

        }
      }
    } catch (e) {
      // Throw to UI if you want user to know
      throw Exception("Failed to schedule reminder for '${todo.title}': $e");
    }
  }

  @override
  Future<bool> addOrUpdate(Todo todo) async {
    try {
      final isUpdate = _todos.any((t) => t.id == todo.id);

      //If this todo has a parent, try to nest instead of treating like a normal save
      // if (todo.parentId != null) {
      //   final parent = findById(todo.parentId!);
      //   if (parent != null) {
      //     await nestUnder(parent, todo); // reuse your drag-nest logic
      //     return false; // treat as "new" since it's nested
      //   }
      // }

      //Otherwise, normal add or update
      await _repo.saveTodo(todo);
      await reschedule(todo);

      //loadAll();

      final index = _todos.indexWhere((test) => test.id == todo.id);
      if (index >= 0) {
        _todos[index] = todo;
      } else {
        _todos.add(todo);
      }

      // If it has a parent, update parent's subTodoIds and _todos
      if (todo.parentId != null) {
        final parent = findById(todo.parentId!);
        if (parent != null && !parent.subTodoIds.contains(todo.id)) {
          parent.subTodoIds.add(todo.id);
          await _repo.saveTodo(parent);

          final parentIndex = _todos.indexWhere((t) => t.id == parent.id);
          if (parentIndex >= 0) _todos[parentIndex] = parent;
        }
      }
      _todos.refresh();

      return isUpdate;
    } catch(e){
      throw Exception("Failed to save todo '${todo.title}': $e");
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

    // Remove from parent if exists
    if (todo.parentId != null) {
      final parent = findById(todo.parentId!);
      if (parent != null) {
        parent.subTodoIds.remove(todo.id);
        final index = _todos.indexWhere((t) => t.id == parent.id);
        if (index >= 0) _todos[index] = parent;
        await _repo.saveTodo(parent); // persist the updated parent
      }
    }

    await _repo.deleteTodo(todo.id);
    //loadAll();
    _todos.removeWhere((test)=> test.id == todo.id);//update the list directly
    _todos.refresh();
  }

  @override
  Future<void> deleteAll() async {
    // Cancel all reminders first
    for (final todo in _todos) {
      await _notificationService.cancelReminderForTodo(todo);
    }

    // Clear from repository
    await _repo.clearAllTodo();

    // Clear the observable list
    _todos.clear();
    _todos.refresh();
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

    if(parent.id == child.id) return false;//blocks self-nesting

    if(child.parentId == parent.id) return false; //prevents duplicates of a child in a parent

    //prevent nesting if parent is already a child (depth >= 2)
    if(parent.parentId != null) return false; // parent is a sub-todo, so nesting not allowed

    if (child.subTodoIds.isNotEmpty) return false; //prevent nesting a child that already has subtodos

    final visited = <String>{};//holds the values of visited IDs

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

    // extra safety: prevent depth > 2
    if(parent.parentId != null) return false;


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
    _todos.refresh();
    return true;

  }

  @override
  bool canHaveChildren(Todo todo) {
    return todo.parentId == null; // only top-level todos can have children
  }

}