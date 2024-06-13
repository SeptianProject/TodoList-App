import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_todo_app/input_todo_page.dart';
import 'package:my_todo_app/list_todo_page.dart';
import 'package:my_todo_app/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailTodoPage extends StatelessWidget {
  final Todo todo;

  const DetailTodoPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
      ),
      body: Column(
        children: [
          if (todo.attachments.isNotEmpty)
            Image.file(File(todo.attachments), width: 150, height: 150),
          buildDetailItem('Title', todo.title),
          buildDetailItem('Description', todo.description),
          buildDetailItem('Priority', todo.priority.toString()),
          buildDetailItem('Due Date', todo.dueDate),
          buildDetailItem('Status', todo.status),
          buildDetailItem('Tags', todo.tags.join(', ')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => InputTodoPage(todo: todo),
                  ));
                },
                child: const Text('Edit'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                deleteData(todo);
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => const ListTodoPage(),
                                ));
                              },
                            ),
                          ],
                        );
                      });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> deleteData(Todo todo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dataList = prefs.getStringList('data') ?? [];
    // Find and remove the specific Todo based on its 'id'
    dataList.removeWhere((data) {
      final Map<String, dynamic> decodedData = jsonDecode(data);
      final String id = decodedData['id'];
      return id == todo.id;
    });
    prefs.setStringList('data', dataList);
  }

  Widget buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ]),
    );
  }
}
