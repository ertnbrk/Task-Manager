import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5270/api/auth";

  /// Register User
  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 200;
  }

  /// Login User
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeToken(data['token']);
      print("TOKEN => ${data['token']}");

      return true;
    }
    return false;
  }

  /// Change password
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: headers,
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  /// Store JWT Token
  static Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  /// Retrieve JWT Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  /// Get Auth Headers
  static Future<Map<String, String>> getAuthHeaders() async {
    String? token = await getToken();
    print("TOKEN => ${token}");
    if (token == null) {
      return {"Content-Type": "application/json"};
    }
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
  }



  /// Delete User
  static Future<bool> deleteUser() async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  /// Logout User
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }
}
