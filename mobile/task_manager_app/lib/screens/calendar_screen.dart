import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager_app/screens/tasks_screen.dart';
import 'package:task_manager_app/widgets/menu_drawer.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
      print("📌 Normalized Date: $normalizedDate"); // ✅ Debugging

      if (_tasksByDate[normalizedDate] == null) {
        _tasksByDate[normalizedDate] = [];
      }
      _tasksByDate[normalizedDate]!.add(task);
    }
  }

  print("✅ Loaded Tasks: $_tasksByDate"); // ✅ Debugging
  setState(() {}); // Refresh UI
  }

  /// Bildirimleri ayarla
  void _initializeNotifications() {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// Görev zamanı geldiğinde bildirim gönder
  void _scheduleNotification(Task task) async {
    final scheduledDate = tz.TZDateTime.from(task.createdAt, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_notifications', // Kanal ID
      'Task Notifications', // Kanal Adı
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      "Görev Hatırlatma",
      "Görev: ${task.title}",
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // ✅ Zorunlu parametre eklendi
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Takvim")),
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
            print("📅 Checking events for: $normalizedDay");
            print("📌 Tasks for this day: ${_tasksByDate[normalizedDay] ?? []}");
            return _tasksByDate[normalizedDay] ?? [];  // ✅ Ensure it returns a list
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
            child: _tasksByDate[_selectedDay] == null ||
                    _tasksByDate[_selectedDay]!.isEmpty
                ? Center(
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TasksScreen()),
                      );
                    },
                    child: Icon(
                      Icons.add,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(
                              255, 24, 140, 8)), // ✅ HATA DÜZELTİLDİ
                    ),
                  ))
                : ListView.builder(
                    itemCount: _tasksByDate[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      Task task = _tasksByDate[_selectedDay]![index];
                      return Card(
                        color: _getTaskColor(task), //  Color based on Due Date
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

    DateTime dueDate =
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (dueDate.isBefore(today)) {
      return Colors.red.shade300; //  Overdue tasks
    } else if (dueDate.isAtSameMomentAs(today)) {
      return Colors.yellow.shade300; //  Due today
    }
    return Colors.white;
  }

  List<Widget> _buildEventMarkers(DateTime day, List<dynamic> events) {
    if (events.isEmpty) return [];

    return events.map((task) {
      Color markerColor;
      DateTime today = DateTime.now();
      DateTime taskDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

      if (taskDate.isBefore(today)) {
        markerColor = Colors.red; //  Overdue tasks
      } else if (taskDate.isAtSameMomentAs(today)) {
        markerColor = Colors.yellow; //  Tasks due today
      } else {
        markerColor = Colors.green; //  Future tasks
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 1),
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: markerColor, shape: BoxShape.circle),
      );
    }).toList();
  }
}
