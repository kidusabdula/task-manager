import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class Database {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.json');
  }

  Future<List<Task>> getTasks() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        await file.writeAsString('{"tasks": []}');
      }
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return (json['tasks'] as List).map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  Future<void> updateTask(String id, Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(tasks);
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final file = await _localFile;
    final json = {'tasks': tasks.map((t) => t.toJson()).toList()};
    await file.writeAsString(jsonEncode(json));
  }
}
