import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/calendar_screen.dart';
//import 'screens/settings_screen.dart';
import 'providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();  // ✅ Initialize Hive
  await Hive.openBox('tasks');  // ✅ Open tasks storage

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,  // Light Mode
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,  // Dark Mode
      ),
      themeMode: ThemeMode.system,  // ✅ Auto-switch based on system settings
      initialRoute: "/login",  // ✅ Varsayılan olarak Login sayfası açılacak
      routes: {
        "/login": (context) => LoginScreen(),
        "/home": (context) => HomeScreen(),
        "/tasks": (context) => TasksScreen(),
        "/calendar": (context) => CalendarScreen(),
       // "/settings": (context) => SettingsScreen(),
      },
    );
  }
}
