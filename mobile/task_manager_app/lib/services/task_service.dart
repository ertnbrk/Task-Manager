import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskService {
  final Box _taskBox = Hive.box('tasks');

  List<Task> loadTasks() {
    return _taskBox.values.cast<Task>().toList();
  }

  void saveTasks(List<Task> tasks) {
    _taskBox.clear();
    for (var task in tasks) {
      _taskBox.put(task.id, task);
    }
  }

  void addTask(Task task) {
    _taskBox.put(task.id, task);
  }

  void deleteTask(String id) {
    _taskBox.delete(id);
  }
}
