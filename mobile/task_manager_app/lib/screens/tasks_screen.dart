import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/widgets/menu_drawer.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../widgets/task_input_widget.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  String _filterOption = 'All'; // Default filter option

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    try {
      List<dynamic> fetchedTasks = await ApiService.fetchTasks();
      taskProvider
          .setTasks(fetchedTasks.map((task) => Task.fromJson(task)).toList());
    } catch (e) {
      print("Error fetching tasks: $e");
    }
    setState(() => _isLoading = false);
  }

  void _addTask() async {
    if (_taskController.text.isNotEmpty) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      bool success = await ApiService.addTask(
        _taskController.text,
        _descriptionController.text.isEmpty ? "" : _descriptionController.text,
        _selectedDueDate,
      );

      if (success) {
        _loadTasks();
        _taskController.clear();
        _descriptionController.clear();
        setState(() => _selectedDueDate = null); // Reset date picker
      }
    }
  }

  void _deleteTask(String id) async {
    bool success = await ApiService.deleteTask(id);
    if (success) _loadTasks();
  }

  Color _getTaskColor(DateTime? dueDate, BuildContext context) {
  if (dueDate == null) return Theme.of(context).cardColor; // Default background if no due date

  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

  if (taskDate.isBefore(today)) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.withOpacity(0.5)
        : Colors.red.withOpacity(0.2); // Overdue (past date)
  } else if (taskDate.isAtSameMomentAs(today)) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.withOpacity(0.5)
        : Colors.yellow.withOpacity(0.3); // Due today
  } else {
    return Theme.of(context).cardColor; // Default for future tasks
  }
}


  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    List<Task> filteredTasks;
    if (_filterOption == 'Completed') {
      filteredTasks = taskProvider.tasks.where((task) => task.isCompleted).toList();
    } else if (_filterOption == 'Incomplete') {
      filteredTasks = taskProvider.tasks.where((task) => !task.isCompleted).toList();
    } else {
      filteredTasks = taskProvider.tasks;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      drawer: MenuDrawer(),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Task Description (Optional)",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDueDate == null
                            ? ""
                            : "Due: ${_selectedDueDate!.toLocal()}"
                                .split('.')[0],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.blue),
                      onPressed: () => _pickDueDate(context),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text("Add Task"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _filterOption,
                  onChanged: (value) {
                    setState(() {
                      _filterOption = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All Tasks')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed Tasks')),
                    DropdownMenuItem(value: 'Incomplete', child: Text('Incomplete Tasks')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => _deleteTask(task.id),
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () => taskProvider.toggleExpandTask(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getTaskColor(task.dueDate, context),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5)
                              ],
                            ),
                            constraints: BoxConstraints(minHeight: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (value) => taskProvider
                                          .toggleTaskCompletion(index),
                                    ),
                                    Expanded(
                                      child: Text(
                                        task.title +
                                            (task.dueDate != null
                                                ? "\n${DateFormat.yMMMMd().add_Hm().format(task.dueDate!)}"
                                                : ""),
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
                                if (task.isExpanded &&
                                    task.description.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, top: 5),
                                    child: Text(
                                      task.description,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      softWrap: true,
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

  void _pickDueDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );

    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
}
