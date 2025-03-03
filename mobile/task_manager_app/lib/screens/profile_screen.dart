import 'package:flutter/material.dart';
import 'package:task_manager_app/services/api_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _email = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ApiService.getUserProfile();
      String? token = await AuthService.getToken();
      print("JWT Token: $token");

      setState(() {
        _fullName = profileData?['fullName'];
        _email = profileData?['email'];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name: $_fullName', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Email: $_email', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/change_password'),
                    child: Text('Change Password'),
                  )
                ],
              ),
            ),
    );
  }
}
