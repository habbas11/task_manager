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
    if (!(taskBloc.state is TaskLoaded)) {
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
        title: Text('Tasks'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          print("Current state: $state");
          if (state is TaskLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return ListTile(
                  title: Text(task['todo']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task['completed'],
                        onChanged: (bool? value) {
                          context.read<TaskBloc>().add(UpdateTask(
                              id: task['id'], completed: value ?? false));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditTaskDialog(
                              context, task['id'], task['todo'], userId);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
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
        child: Icon(Icons.add),
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
              taskId: taskId, taskText: taskText, userId: userId),
        );
      },
    );
  }
}
