import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_todo_app/detail_todo_page.dart';
import 'package:my_todo_app/input_todo_page.dart';
import 'package:my_todo_app/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListTodoPage extends StatefulWidget {
  const ListTodoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListTodoPageState createState() => _ListTodoPageState();
}

class _ListTodoPageState extends State<ListTodoPage> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Todo App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              getData();
            },
          ),
        ],
      ),
      body: Container(
          margin: const EdgeInsets.all(8),
          child: todos.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.separated(
                  itemCount: todos.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    color: Colors.black54,
                  ),
                  itemBuilder: (context, index) {
                    Todo todo = todos[index];
                    return ListTile(
                      leading: todo.attachments.isNotEmpty
                          ? Image.file(File(todo.attachments))
                          : const Icon(Icons.image),
                      title: Text(todo.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${todo.description}'),
                          Text('priority: ${todo.priority}'),
                          Text('dueDate: ${todo.dueDate}'),
                          Text('status: ${todo.status}'),
                          Text('tags: ${todo.tags}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailTodoPage(todo: todo),
                        ));
                      },
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const InputTodoPage(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dataList = prefs.getStringList('data') ?? [];
    List<Todo> parsedData = [];
    for (String dataItem in dataList) {
      debugPrint(dataItem);
      Map<String, dynamic> decodedData = jsonDecode(dataItem);
      Todo todo = Todo(
        id: decodedData['id'],
        title: decodedData['title'],
        description: decodedData['description'],
        priority: decodedData['priority'],
        dueDate: decodedData['dueDate'] ?? "-",
        status: decodedData['status'] ?? "-",
        tags: (decodedData['tags'] as String)
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(', '),
        attachments: decodedData['attachments'] ?? "-",
      );
      parsedData.add(todo);
    }
    setState(() {
      todos = parsedData;
    });
  }
}
