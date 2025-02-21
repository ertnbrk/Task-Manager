import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  /// ✅ Hive veya API'den görevleri yükle
  void _loadTasks() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _tasksByDate.clear();

    for (var task in taskProvider.tasks) {
      DateTime taskDate = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
      if (_tasksByDate[taskDate] == null) {
        _tasksByDate[taskDate] = [];
      }
      _tasksByDate[taskDate]!.add(task);
      _scheduleNotification(task); // 🔔 Zamanı geldiğinde bildirim gönder
    }
    setState(() {});
  }

  /// ✅ Bildirimleri ayarla
  void _initializeNotifications() {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// 🔔 Görev zamanı geldiğinde bildirim gönder
  void _scheduleNotification(Task task) async {
    final scheduledDate = tz.TZDateTime.from(task.createdAt, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_notifications', // Kanal ID
      'Task Notifications', // Kanal Adı
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      "Görev Hatırlatma",
      "Görev: ${task.title}",
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Zorunlu parametre eklendi
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Takvim")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _tasksByDate[day] ?? [],
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
          ),
          SizedBox(height: 10),
          Expanded(
            child: _tasksByDate[_selectedDay] == null || _tasksByDate[_selectedDay]!.isEmpty
                ? Center(child: Text("Bu tarihte görev yok"))
                : ListView.builder(
                    itemCount: _tasksByDate[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      Task task = _tasksByDate[_selectedDay]![index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        leading: Icon(Icons.check_circle, color: task.isCompleted ? Colors.green : Colors.grey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
