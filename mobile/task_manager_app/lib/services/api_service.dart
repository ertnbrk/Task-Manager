import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5270/api/tasks";

  ///  Fetch tasks with authentication
  static Future<List<dynamic>> fetchTasks() async {
    String? token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );
    
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  ///  Add a new task
  static Future<bool> addTask(String title, String description, DateTime? dueDate) async {
    String? token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      print("❌ Error: Token is null or empty.");
      return false;
    }

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "title": title,
      "description": description,
      "isCompleted": false,
      "dueDate": dueDate?.toUtc().toIso8601String(),
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        print("✅ Task added successfully!");
        return true;
      } else {
        print("❌ Failed to add task. Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error in addTask: $e");
      return false;
    }
  }

  ///  Delete a task
  static Future<bool> deleteTask(String id) async {
    String? token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 204;
  }

  /// Get User Profile
 static Future<Map<String, dynamic>?> getUserProfile() async {
  String? token = await AuthService.getToken();

  if (token == null || token.isEmpty) {
    print("No token found.");
    return null;
  }

  final headers = {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  final response = await http.get(
    Uri.parse('http://10.0.2.2:5270/api/users/user'), // Doğru endpoint
    headers: headers,
  );

  print("STATUS: ${response.statusCode}");
  print("Headers: ${headers}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("Failed to fetch user profile. Status code: ${response.statusCode}");
    return null;
  }
}


  /// Update User Profile
  static Future<bool> updateUserProfile(String name, String email, String phone) async {
    String? token = await AuthService.getToken();

    if (token == null) {
      print("No token found.");
      return false;
    }

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
      }),
    );

    return response.statusCode == 200;
  }
}
