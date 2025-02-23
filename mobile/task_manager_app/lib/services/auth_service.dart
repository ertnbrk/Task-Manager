import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5270/api/auth"; 

  ///  Register User
  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 200;
  }

  ///  Login User
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeToken(data['token']);
      return true;
    }
    return false;
  }
 /// Change password
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    String? token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  

  ///  Store JWT Token
  static Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  ///  Retrieve JWT Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  ///  Logout User
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

   /// Get User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    String? token = await getToken();

    if (token == null) {
      print("No token found.");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch user profile. Status code: ${response.statusCode}");
      return null;
    }
  }

  /// Update User Profile
  static Future<bool> updateUserProfile(String name, String email, String phone) async {
    String? token = await getToken();

    if (token == null) {
      print("No token found.");
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
      }),
    );

    return response.statusCode == 200;
  }

  /// Delete User
  static Future<bool> deleteUser() async {
    String? token = await getToken();

    if (token == null) {
      print("No token found.");
      return false;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/user'),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 204;
  }
}
