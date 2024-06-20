import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';

class EditTaskDialog extends StatefulWidget {
  final int taskId;
  final String taskText;
  final int userId;

  EditTaskDialog({required this.taskId, required this.taskText, required this.userId});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.taskText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(labelText: 'Task'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<TaskBloc>().add(UpdateTask(
              id: widget.taskId,
              todo: _taskController.text,
              userId: widget.userId,
            ));
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
