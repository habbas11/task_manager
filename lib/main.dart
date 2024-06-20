import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/task/task_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/task_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => TaskBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager App',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/tasks': (context) => TaskScreen(),
        },
      ),
    );
  }
}
