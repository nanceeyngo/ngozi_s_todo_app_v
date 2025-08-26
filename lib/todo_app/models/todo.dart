import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@JsonSerializable(explicitToJson: true)
class Todo{
  String id;
  String title;
  String? description; //absolute date and time
  DateTime? deadline;
  Duration? reminderBefore;
  String? parentId; // id of parent to-do, null if top-level
  List<String> subTodoIds;
  bool done;

  Todo({
    String? id,
    required this.title,
    this.description,
    this.deadline,
    this.reminderBefore,
    this.parentId,
    List <String>? subTodoIds,
    this.done = false,
  }): id = id?? const Uuid().v4(),
        subTodoIds = subTodoIds ?? [];

  //from JSON
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  //to JSON
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  /// Helper: compute reminder DateTime if possible
  DateTime? get reminderDateTime{
    if(deadline == null || reminderBefore == null) return null;
    return deadline!.subtract(reminderBefore!);
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    Duration? reminderBefore,
    String? parentId,
    List<String>? subTodoIds,
    bool? done,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      reminderBefore: reminderBefore ?? this.reminderBefore,
      parentId: parentId ?? this.parentId,
      subTodoIds: subTodoIds ?? List.from(this.subTodoIds),
      done: done ?? this.done,
    );
  }


}