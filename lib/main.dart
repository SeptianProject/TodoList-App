import 'package:flutter/material.dart';
import 'package:my_todo_app/list_todo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ListTodoPage(),
    );
  }
}
