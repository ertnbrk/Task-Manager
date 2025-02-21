import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  final TaskService _taskService = TaskService();

  List<Task> get tasks => _tasks;  // Getter for tasks

  TaskProvider() {
    loadTasks();
  }

  void loadTasks() async {
    _tasks = await _taskService.loadTasks();
    notifyListeners(); 
  }
  void setTasks(List<Task> tasks) {
  _tasks = tasks;
  notifyListeners();  
}


  void addTask(String title, String description) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    _tasks.add(newTask);
    _taskService.saveTasks(_tasks);
    notifyListeners(); 
  }

  void toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    _taskService.saveTasks(_tasks);
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _taskService.saveTasks(_tasks);
    notifyListeners();
  }

  void toggleExpandTask(int index) {
    _tasks[index].isExpanded = !_tasks[index].isExpanded;
    notifyListeners();
  }
}
