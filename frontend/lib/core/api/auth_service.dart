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
        final String avatarUrl = data['user']['avatarUrl'] ?? '';
        final double bloodVolume = (data['user']['bloodVolume'] ?? 0).toDouble();
        final int donationCount = data['user']['donationCount'] ?? 0;
        
        // Save token, phone, name, bloodType, stats, avatar
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('phone', phone);
        await prefs.setString('fullName', fullName);
        await prefs.setString('bloodType', bloodType);
        await prefs.setString('avatarUrl', avatarUrl);
        await prefs.setDouble('bloodVolume', bloodVolume);
        await prefs.setInt('donationCount', donationCount);
        await prefs.setString('userId', data['user']['id'] ?? '');
        
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

  Future<bool> updateProfile({String? fullName, String? bloodType, String? avatarUrl}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (bloodType != null) data['bloodType'] = bloodType;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      final response = await _dio.put('/Auth/profile', 
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        if (fullName != null) await prefs.setString('fullName', fullName);
        if (bloodType != null) await prefs.setString('bloodType', bloodType);
        if (avatarUrl != null) await prefs.setString('avatarUrl', avatarUrl);
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone');
    await prefs.remove('fullName');
    await prefs.remove('bloodType');
    await prefs.remove('bloodVolume');
    await prefs.remove('donationCount');
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

  Future<String?> getLoggedAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarUrl');
  }

  Future<double> getLoggedBloodVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('bloodVolume') ?? 0.0;
  }

  Future<int> getLoggedDonationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('donationCount') ?? 0;
  }
}
