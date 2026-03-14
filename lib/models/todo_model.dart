import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final int timeInSeconds;

  @HiveField(5)
  final int remainingTimeInSeconds;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timeInSeconds,
    required this.remainingTimeInSeconds,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? timeInSeconds,
    int? remainingTimeInSeconds,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      timeInSeconds: timeInSeconds ?? this.timeInSeconds,
      remainingTimeInSeconds: remainingTimeInSeconds ?? this.remainingTimeInSeconds,
    );
  }
}
