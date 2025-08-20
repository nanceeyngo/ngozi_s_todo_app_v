// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  reminderBefore: json['reminderBefore'] == null
      ? null
      : Duration(microseconds: (json['reminderBefore'] as num).toInt()),
  parentId: json['parentId'] as String?,
  subTodoIds: (json['subTodoIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  done: json['done'] as bool? ?? false,
);

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'deadline': instance.deadline?.toIso8601String(),
  'reminderBefore': instance.reminderBefore?.inMicroseconds,
  'parentId': instance.parentId,
  'subTodoIds': instance.subTodoIds,
  'done': instance.done,
};
