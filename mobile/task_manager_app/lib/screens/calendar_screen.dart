import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager_app/screens/tasks_screen.dart';
import 'package:task_manager_app/widgets/menu_drawer.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Task>> _tasksByDate = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _initializeNotifications();
  }

 void _loadTasks() {
  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
  _tasksByDate.clear();

  for (var task in taskProvider.tasks) {
    if (task.dueDate != null) {
      DateTime normalizedDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      print("📌 Normalized Date: $normalizedDate"); 
      print("🔹 Task Title: ${task.title}");
      
      if (_tasksByDate[normalizedDate] == null) {
        _tasksByDate[normalizedDate] = [];
      }
      _tasksByDate[normalizedDate]!.add(task);
    }
  }

  print("✅ Loaded Tasks: $_tasksByDate"); 
  setState(() {}); 
}



  void _initializeNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          /// 🗓 TABLE CALENDAR
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return _tasksByDate[normalizedDay] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(formatButtonVisible: false),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, tasks) {
                if (tasks.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),

          SizedBox(height: 10),

          /// 📝 TASK LIST BELOW CALENDAR
          Expanded(
            child: _tasksByDate[_selectedDay]?.isEmpty ?? true
                ? Center(
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TasksScreen()),
                      );
                    },
                    child: Icon(Icons.add, color: Colors.white),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green),
                    ),
                  ))
                : ListView.builder(
                    itemCount: _tasksByDate[_selectedDay]?.length ?? 0,
                    itemBuilder: (context, index) {
                      Task task = _tasksByDate[_selectedDay]![index];
                      return Card(
                        color: _getTaskColor(task),
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(task.title,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(task.description),
                          leading: Icon(Icons.check_circle,
                              color: task.isCompleted
                                  ? Colors.green
                                  : Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(Task task) {
    DateTime today = DateTime.now();

    if (task.dueDate == null) {
      return Colors.white;
    }

    DateTime dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (dueDate.isBefore(today)) {
      return Colors.red.shade300;
    } else if (dueDate.isAtSameMomentAs(today)) {
      return Colors.yellow.shade300;
    }
    return Colors.white;
  }
}
