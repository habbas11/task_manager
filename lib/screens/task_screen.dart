import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/screens/widgets/add_task_dialog.dart';
import 'package:task_manager/screens/widgets/edit_task_dialog.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as int;
    print("TaskScreen is CALLED");

    // Only load tasks if the state is not already loaded
    final taskBloc = BlocProvider.of<TaskBloc>(context);
    if (taskBloc.state is! TaskLoaded) {
      taskBloc.add(LoadTasks(userId));
    }

    return BlocProvider.value(
      value: taskBloc,
      child: TaskView(userId: userId),
    );
  }
}

class TaskView extends StatelessWidget {
  final int userId;

  TaskView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length + 1,
              // Add 1 for the "More..." button
              itemBuilder: (context, index) {
                if (index == state.tasks.length) {
                  // Display "More..." button
                  if (state.tasks.length < state.total) {
                    return ElevatedButton(
                      onPressed: () {
                        context.read<TaskBloc>().add(
                              LoadTasks(
                                userId,
                                limit: state.limit,
                                skip: state.skip + state.limit,
                              ),
                            );
                      },
                      child: const Text('More...'),
                    );
                  } else {
                    return const SizedBox.shrink(); // No more tasks to load
                  }
                }

                // Display task
                final task = state.tasks[index];
                return ListTile(
                  title: Text(task['todo']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task['completed'] == 1,
                        onChanged: (bool? value) {
                          context.read<TaskBloc>().add(UpdateTask(
                                id: task['id'],
                                completed: value ?? false,
                                todo: task['todo'],
                                userId: task['userId'],
                              ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditTaskDialog(
                            context,
                            task['id'],
                            task['todo'],
                            task['userId'],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(task['id']));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return BlocProvider.value(
                value: BlocProvider.of<TaskBloc>(context),
                child: AddTaskDialog(userId: userId),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTaskDialog(
      BuildContext context, int taskId, String taskText, int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<TaskBloc>(context),
          child: EditTaskDialog(
            taskId: taskId,
            taskText: taskText,
            userId: userId,
          ),
        );
      },
    );
  }
}
