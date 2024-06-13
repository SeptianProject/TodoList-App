import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_todo_app/list_todo_page.dart';
import 'package:my_todo_app/todo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InputTodoPage extends StatefulWidget {
  final Todo? todo;

  const InputTodoPage({super.key, this.todo});

  @override
  // ignore: library_private_types_in_public_api
  _InputTodoPageState createState() => _InputTodoPageState();
}

class _InputTodoPageState extends State<InputTodoPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  String _selectedPriority = 'IMPORTANT';
  DateTime _dueDate = DateTime.now();
  String _selectedStatus = 'Not Started';
  final List<String> _selectedTags = [];
  File? _image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Create Todo' : 'Edit Todo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  minLines: 3,
                  maxLines: 3,
                  maxLength: 50,
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  items: ['IMPORTANT', 'MEDIUM', 'LOW'].map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Priority'),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a priority';
                    }
                    return null;
                  }),
                ),
                TextFormField(
                  readOnly: true,
                  controller: dueDateController,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  onTap: () async {
                    final pickDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickDate != null && pickDate != _dueDate) {
                      setState(() {
                        _dueDate = pickDate;
                        dueDateController.text =
                            DateFormat('dd-MM-yyyy').format(pickDate);
                        // DateFormat.YEAR_MONTH_DAY.FormData
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text('status'),
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Radio<String>(
                              value: 'Not Started',
                              groupValue: _selectedStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                            const Text('Not Started')
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio<String>(
                              value: 'In Progress',
                              groupValue: _selectedStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                            const Text('In Progress'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio<String>(
                              value: 'Completed',
                              groupValue: _selectedStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                            const Text('Completed'),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text('Tags'),
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _selectedTags.contains('Sekolah'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedTags.add('Sekolah');
                              } else {
                                _selectedTags.remove('Sekolah');
                              }
                            });
                          },
                        ),
                        const Text('Sekolah'),
                        Checkbox(
                          value: _selectedTags.contains('Rumah'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedTags.add('Rumah');
                              } else {
                                _selectedTags.remove('Rumah');
                              }
                            });
                          },
                        ),
                        const Text('Rumah'),
                      ],
                    )
                  ],
                ),
                InkWell(
                  onTap: () {
                    _pickImage();
                  },
                  child: _image == null
                      ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: const Icon(Icons.camera_alt,
                              size: 50, color: Colors.white),
                        )
                      : Image.file(
                          _image!,
                          width: 320,
                          height: 320,
                        ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String id = widget.todo != null
                          ? widget.todo!.id
                          : const Uuid().v4();
                      String title = titleController.text;
                      String description = descriptionController.text;
                      String priority = _selectedPriority;
                      String dueDate = dueDateController.text;
                      String status = _selectedStatus;
                      final todo = Todo(
                          id: id,
                          title: title,
                          description: description,
                          priority: priority,
                          dueDate: dueDate,
                          status: status,
                          tags: _selectedTags,
                          attachments: _image!.path);
                      saveOrUpdateData(todo);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const ListTodoPage(),
                      ));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveOrUpdateData(Todo todo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dataList = prefs.getStringList('data') ?? [];
    Map<String, String> newData = {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'priority': todo.priority,
      'dueDate': todo.dueDate,
      'status': todo.status,
      'attachments': todo.attachments,
      'tags': todo.tags.toString(),
    };
    int dataIndex = -1;
    // Check if the item with the same ID already exists in the list
    for (int i = 0; i < dataList.length; i++) {
      Map<String, dynamic> item = jsonDecode(dataList[i]);
      if (item['id'] == todo.id) {
        dataIndex = i;
        break;
      }
    }
    if (dataIndex != -1) {
      dataList[dataIndex] = jsonEncode(newData); // Edit the existing item
    } else {
      dataList.add(jsonEncode(newData)); // Add a new item to the list
    }
    prefs.setStringList(
        'data', dataList); // Save the updated list to local storage
    debugPrint(dataList.toString());
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}
