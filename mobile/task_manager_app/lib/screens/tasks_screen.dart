import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TasksScreen extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Tasks")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: "New Task",
                    prefixIcon: Icon(Icons.task),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Task Description (Optional)",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      taskProvider.addTask(
                        _taskController.text,
                        _descriptionController.text.isEmpty ? "" : _descriptionController.text,
                      );
                      _taskController.clear();
                      _descriptionController.clear();
                    }
                  },
                  child: const Text("Add Task"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          SizedBox(height: 10), // ✅ Prevents overflow issues

          /// ✅ Use `Expanded` to prevent scrolling issues
          Expanded(
            child: ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];

                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => taskProvider.deleteTask(index),
                  background: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () => taskProvider.toggleExpandTask(index),
                    child: AnimatedContainer( //ss
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)
                        ],
                      ),
                      /// ✅ FIXED: Dynamic height for tasks
                      constraints: BoxConstraints(minHeight: 60), // ✅ Ensures minimum height
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => taskProvider.toggleTaskCompletion(index),
                              ),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /// ✅ FIXED: Prevents overflow by showing full text
                          if (task.isExpanded && task.description.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(left: 40, top: 5),
                              child: Text(
                                task.description,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                softWrap: true, // ✅ Ensures text wraps properly
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
