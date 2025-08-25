class MockTodo {
  final String id;
  final String title;
  bool done;
  String? parentId;
  List<String> subTodoIds;

  MockTodo({
    required this.id,
    required this.title,
    this.done = false,
    this.parentId,
    List<String>? subTodoIds,
  }) : subTodoIds = subTodoIds ?? [];
}
