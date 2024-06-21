import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/screens/widgets/add_task_dialog.dart';
import 'package:task_manager/screens/widgets/edit_task_dialog.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';

class TaskView extends StatefulWidget {
  final int userId;

  TaskView({required this.userId});

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            return SlidableAutoCloseBehavior(
              child: ListView.builder(
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
                              widget.userId,
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
                  print("Task key ${task['id']}");
                  return Slidable(
                    groupTag: 0,
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          autoClose: true,
                          onPressed: (context) {
                            context.read<TaskBloc>().add(DeleteTask(task['id']));
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _showEditTaskDialog(
                              context,
                              task['id'],
                              task['todo'],
                              task['userId'],
                            );
                          },
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(task['todo']),
                      trailing: Checkbox(
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
                    ),
                  );
                },
              ),
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
                child: AddTaskDialog(userId: widget.userId),
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
