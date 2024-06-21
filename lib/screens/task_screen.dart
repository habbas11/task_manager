import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/screens/task_view.dart';
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
