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
        final phone = data['user']['phoneNumber'];
        final fullName = data['user']['fullName'] ?? '';
        final bloodType = data['user']['bloodType'] ?? '';
        
        // Save token, phone, name, bloodType
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('phone', phone);
        await prefs.setString('fullName', fullName);
        await prefs.setString('bloodType', bloodType);
        
        return data;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<bool> register(String phoneNumber, String password, String fullName, String? bloodType) async {
    try {
      final response = await _dio.post('/Auth/register', data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'fullName': fullName,
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
    await prefs.remove('phone');
    await prefs.remove('fullName');
    await prefs.remove('bloodType');
  }

  Future<String?> getLoggedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  Future<String?> getLoggedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullName');
  }

  Future<String?> getLoggedBloodType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bloodType');
  }
}
