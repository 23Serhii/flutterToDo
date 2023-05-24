import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String apiUrl = 'https://to-do.softwars.com.ua/';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$apiUrl/tasks'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Login'),
          onPressed: () {
            fetchTasks().then((tasks) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(tasks: tasks)),
              );
            }).catchError((error) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to fetch tasks.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Task> tasks;
  final YourApiService apiService = YourApiService();

  HomePage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: FutureBuilder<List<Task>>(
        future: apiService.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditTaskPage(task: snapshot.data![index])),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskPage()),
          );
        },
      ),
    );
  }
}

class EditTaskPage extends StatelessWidget {
  final Task task;
  final YourApiService apiService = YourApiService();

  EditTaskPage({required this.task});

  Future<void> updateTaskStatus(int status) async {
    final updatedTask = task.copyWith(status: status);
    await apiService.updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Center(
        child: Checkbox(
          value: task.status == 2,
          onChanged: (bool? value) {
            int newStatus = value! ? 2 : 1;
            updateTaskStatus(newStatus).then((_) {
              // Task status updated successfully
            }).catchError((error) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to update task status.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}

class CreateTaskPage extends StatelessWidget {
  final YourApiService apiService = YourApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Create'),
          onPressed: () async {
            final newTask = Task(
              taskId: '',
              status: 1,
              name: 'New Task',
              type: 1,
              description: 'New Task Description',
              finishDate: '',
              urgent: 0,
              file: '',
            );
            await apiService.createTask(newTask);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class Task {
  final String taskId;
  final int status;
  final String name;
  final int type;
  final String description;
  final String finishDate;
  final int urgent;
  final String file;

  Task({
    required this.taskId,
    required this.status,
    required this.name,
    required this.type,
    required this.description,
    required this.finishDate,
    required this.urgent,
    required this.file,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'],
      status: json['status'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      finishDate: json['finishDate'],
      urgent: json['urgent'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'status': status,
      'name': name,
      'type': type,
      'description': description,
      'finishDate': finishDate,
      'urgent': urgent,
      'file': file,
    };
  }

  Task copyWith({
    String? taskId,
    int? status,
    String? name,
    int? type,
    String? description,
    String? finishDate,
    int? urgent,
    String? file,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      finishDate: finishDate ?? this.finishDate,
      urgent: urgent ?? this.urgent,
      file: file ?? this.file,
    );
  }
}

class YourApiService {
  final String apiUrl = 'https://to-do.softwars.com.ua';

  Future<List<Task>> fetchTasks() async {
    final url = Uri.parse('$apiUrl/tasks');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']}');
      }

      final tasksData = data['data'];
      final tasks =
          List<Task>.from(tasksData.map((taskData) => Task.fromJson(taskData)));
      return tasks;
    } else {
      throw Exception(
          'Failed to fetch tasks. Status code: ${response.statusCode}');
    }
  }

  Future<Task> createTask(Task task) async {
    final url = Uri.parse('$apiUrl/tasks');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']}');
      }

      final createdTaskData = data['data'];
      final createdTask = Task.fromJson(createdTaskData);
      return createdTask;
    } else {
      throw Exception(
          'Failed to create task. Status code: ${response.statusCode}');
    }
  }

  Future<Task> updateTask(Task task) async {
    final url = Uri.parse('$apiUrl/tasks/${task.taskId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']}');
      }

      final updatedTaskData = data['data'];
      final updatedTask = Task.fromJson(updatedTaskData);
      return updatedTask;
    } else {
      throw Exception(
          'Failed to update task. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final url = Uri.parse('$apiUrl/tasks/$taskId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception('API Error: ${data['error']}');
      }
    } else {
      throw Exception(
          'Failed to delete task. Status code: ${response.statusCode}');
    }
  }
}
