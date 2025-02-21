import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _drawerItem(Icons.home, "Home", context, "/home"),
          _drawerItem(Icons.calendar_today, "Calendar", context, "/calendar"),
          _drawerItem(Icons.task, "Tasks", context, "/tasks"),
          _drawerItem(Icons.settings, "Settings", context, "/settings"),
        ],
      ),
    );
  }

  /// Helper method to create drawer items
  Widget _drawerItem(IconData icon, String title, BuildContext context, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
