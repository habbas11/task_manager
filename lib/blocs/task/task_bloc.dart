// task_bloc.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../helpers/database_helper.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks =
          await _databaseHelper.getTasks(limit: event.limit, skip: event.skip);
      print("_onLoadTasks, Skip is: ${event.skip}, limit is: ${event.limit}");
      emit(
        TaskLoaded(
          tasks: tasks,
          total: await _databaseHelper.getTaskCount(),
          skip: event.skip,
          limit: event.limit,
        ),
      );
      print("_onLoadTasks 2, Skip is: ${event.skip}, limit is: ${event.limit}");
      if (await _hasInternetConnection()) {
        await _syncTasksWithServer(event.userId, event.limit, event.skip);
        final updatedTasks = await _databaseHelper.getTasks(
          limit: event.limit,
          skip: event.skip,
        );
        emit(TaskLoaded(
          tasks: updatedTasks,
          total: await _databaseHelper.getTaskCount(),
          skip: event.skip,
          limit: event.limit,
        ));
      }
    } catch (e) {
      print(e);
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      try {
        final newTask = {
          'todo': event.task,
          'completed': event.completed ? 1 : 0,
          'userId': event.userId,
        };
        final id = await _databaseHelper.insertTask(newTask);
        newTask['id'] = id;
        final updatedTasks = List.from(currentState.tasks)..add(newTask);
        emit(TaskLoaded(
          tasks: updatedTasks,
          total: currentState.total + 1,
          skip: currentState.skip,
          limit: currentState.limit,
        ));
        if (await _hasInternetConnection()) {
          await _syncTaskWithServer(newTask);
        }
      } catch (e) {
        emit(TaskError('Failed to add task: $e'));
      }
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    print("Entered _onUpdateTask");
    print("state is $state");
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      try {
        print("Trying to update task");
        final updatedTask = {
          'id': event.id,
          'todo': event.todo,
          'completed': event.completed == true ? 1 : 0,
          'userId': event.userId,
        };
        await _databaseHelper.updateTask(updatedTask);
        final updatedTasks = currentState.tasks.map((task) {
          return task['id'] == event.id ? updatedTask : task;
        }).toList();
        emit(TaskLoaded(
          tasks: updatedTasks,
          total: currentState.total,
          skip: currentState.skip,
          limit: currentState.limit,
        ));
        if (await _hasInternetConnection()) {
          await _syncTaskWithServer(updatedTask);
        }
      } catch (e) {
        print(e);
        emit(TaskError('Failed to update task: $e'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      try {
        await _databaseHelper.deleteTask(event.id);
        final updatedTasks =
            currentState.tasks.where((task) => task['id'] != event.id).toList();
        emit(TaskLoaded(
          tasks: updatedTasks,
          total: currentState.total - 1,
          skip: currentState.skip,
          limit: currentState.limit,
        ));
        if (await _hasInternetConnection()) {
          await _deleteTaskFromServer(event.id);
        }
      } catch (e) {
        emit(TaskError('Failed to delete task: $e'));
      }
    }
  }

  Future<void> _syncTasksWithServer(int userId, int limit, int skip) async {
    print("_syncTasksWithServer got called");
    print("Limit is $limit, Skip is $skip");
    // final response =
    // await http.get(Uri.parse('https://dummyjson.com/todos/user/$userId'));
    // Use the following to test pagination
    final response = await http
        .get(Uri.parse('https://dummyjson.com/todos?limit=$limit&skip=$skip'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['todos'] as List;
      final total = jsonDecode(response.body)['total'] as int;
      final localTasks =
          await _databaseHelper.getTasks(limit: limit, skip: skip);
      print("localTasks $localTasks");
      print("data $data");
      // await _databaseHelper.deleteAllTasks();
      for (var task in data) {
        if (!(localTasks.where((_task) => _task['id'] == task['id']).isEmpty)) {
          continue;
        }
        print("Task ID: ${task['id']}");
        print("localTasks: ${localTasks}");
        await _databaseHelper.insertTask({
          'id': task['id'],
          'todo': task['todo'],
          'completed': task['completed'] ? 1 : 0,
          'userId': task['userId'],
        });
      }
      final updatedTasks = await _databaseHelper.getTasks(limit: limit, skip: skip);
      emit(TaskLoaded(tasks: updatedTasks, limit: limit, skip: skip, total: total));
    }
  }

  Future<void> _syncTaskWithServer(Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('https://dummyjson.com/todos/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo': task['todo'],
        'completed': task['completed'] == 1,
        'userId': task['userId'],
      }),
    );
    if (response.statusCode == 201) {
      final newTask = jsonDecode(response.body);
      task['id'] = newTask['id'];
      await _databaseHelper.updateTask(task);
    }
  }

  Future<void> _deleteTaskFromServer(int id) async {
    final response =
        await http.delete(Uri.parse('https://dummyjson.com/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task from server');
    }
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
