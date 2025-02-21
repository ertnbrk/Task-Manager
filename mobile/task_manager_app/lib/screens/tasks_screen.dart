import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        _selectedDueDate, // ✅ Ensure dueDate is included
      );

      if (success) {
        _loadTasks(); // ✅ Reload tasks after adding
        _taskController.clear();
        _descriptionController.clear();
        setState(() => _selectedDueDate = null); // ✅ Reset date picker
      }
    }
  }

  void _deleteTask(String id) async {
    bool success = await ApiService.deleteTask(id);
    if (success) _loadTasks();
  }
  ///To set color by dueDate
Color _getTaskColor(DateTime? dueDate) {
  if (dueDate == null) return Colors.white; // Default background if no due date

  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day); // Remove time part
  DateTime taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

  if (taskDate.isBefore(today)) {
    return Colors.red.withOpacity(0.2); // 🔴 Overdue (past date)
  } else if (taskDate.isAtSameMomentAs(today)) {
    return Colors.yellow.withOpacity(0.3); // 🟡 Due today
  } else {
    return Colors.white; // Default future tasks
  }
}

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // ☰ 3 çizgili menü ikonu
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menü",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _drawerItem(Icons.home, "Ana Sayfa", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/home");
            }),
            _drawerItem(Icons.calendar_today, "Takvim", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/calendar");
            }),
            _drawerItem(Icons.task, "Görevler", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/tasks");
            }),
            _drawerItem(Icons.settings, "Ayarlar", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");
            }),
          ],
        ),
      ),
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
                                .split('.')[0], // ✅ Show full Date & Time
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
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];

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
                              color:_getTaskColor(task.dueDate),
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
      lastDate: now.add(Duration(days: 365)), // 1 year ahead
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

  /// ✅ Menüdeki öğeleri oluşturmak için yardımcı fonksiyon
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
