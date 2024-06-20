import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/todos/user/${event.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tasks = data['todos'] as List<dynamic>;
        emit(TaskLoaded(tasks: tasks));
        print("TaskLoaded emitted with tasks: $tasks");
      } else {
        emit(TaskError('Failed to load tasks.'));
      }
    } catch (e) {
      print(e);
      emit(TaskError('An error occurred. Please try again.'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    print("_onAddTask is entered!");
    print("Current state is $state");
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      try {
        print("Task info: ${event.userId}, ${event.task}, ${event.completed}");
        final response = await http.post(
          Uri.parse('https://dummyjson.com/todos/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'todo': event.task,
            'completed': false,
            'userId': 5,
          }),
        );
        print("Response is: ${response.statusCode}");
        if (response.statusCode == 201) {
          final newTask = jsonDecode(response.body);
          final updatedTasks = List.from(currentState.tasks)..add(newTask);
          emit(TaskLoaded(tasks: updatedTasks));
        } else {
          emit(TaskError('Failed to add task.'));
        }
      } catch (e) {
        print(e);
        emit(TaskError('An error occurred. Please try again.'));
      }
    } else {
      print("State is not TaskLoaded");
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        if (task['id'] == event.id) {
          return {
            ...task,
            'todo': event.todo ?? task['todo'],
            'completed': event.completed ?? task['completed'],
          };
        }
        return task;
      }).toList();
      emit(TaskLoaded(tasks: updatedTasks));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.where((task) => task['id'] != event.id).toList();
      emit(TaskLoaded(tasks: updatedTasks));
    }
  }
}
