import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>?> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post('/Auth/login', data: {
        'phoneNumber': phoneNumber,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        return data;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<bool> register(String phoneNumber, String password, String? bloodType) async {
    try {
      final response = await _dio.post('/Auth/register', data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'bloodType': bloodType,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
