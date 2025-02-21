import 'package:flutter/material.dart';
import 'package:task_manager_app/widgets/menu_drawer.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: MenuDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TasksScreen()),
            );
          },
          child: Text("Go to Tasks"),
        ),
      ),
    );
  }
}
