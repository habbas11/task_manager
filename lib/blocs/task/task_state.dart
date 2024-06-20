import 'package:equatable/equatable.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<dynamic> tasks;
  final int total;
  final int skip;
  final int limit;

  const TaskLoaded({
    required this.tasks,
    required this.total,
    required this.skip,
    required this.limit,
  });

  @override
  List<Object> get props => [tasks, total, skip, limit];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}
