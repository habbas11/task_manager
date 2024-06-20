import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final int userId;

  const LoadTasks(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddTask extends TaskEvent {
  final String task;
  final bool completed;
  final int userId;

  const AddTask({
    required this.task,
    required this.completed,
    required this.userId,
  });

  @override
  List<Object> get props => [task, completed, userId];
}

class UpdateTask extends TaskEvent {
  final int id;
  final int userId;
  final String? todo;
  final bool? completed;

  const UpdateTask({
    required this.id,
    required this.userId,
    this.todo,
    this.completed,
  });

  @override
  List<Object> get props => [id, userId, todo ?? '', completed ?? false];
}

class DeleteTask extends TaskEvent {
  final int id;

  const DeleteTask(this.id);

  @override
  List<Object> get props => [id];
}
