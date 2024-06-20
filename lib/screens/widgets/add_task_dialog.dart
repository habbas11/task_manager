import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';

class AddTaskDialog extends StatefulWidget {
  final int userId;

  AddTaskDialog({required this.userId});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _taskController = TextEditingController();
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(labelText: 'Task'),
          ),
          CheckboxListTile(
            title: Text('Completed'),
            value: _completed,
            onChanged: (bool? value) {
              setState(() {
                _completed = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<TaskBloc>().add(AddTask(
              task: _taskController.text,
              completed: _completed,
              userId: widget.userId,
            ));
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
