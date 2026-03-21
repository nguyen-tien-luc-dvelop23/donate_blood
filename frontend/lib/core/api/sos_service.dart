import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class SosService {
  final Dio _dio = ApiClient().dio;

  Future<bool> createSos({
    required String bloodType,
    required String location,
    required String reason,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return false;

      final response = await _dio.post(
        '/Sos',
        data: {
          'bloodType': bloodType,
          'location': location,
          'reason': reason,
          'description': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating SOS: $e');
      return false;
    }
  }

  Future<List<dynamic>> getMyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return [];

      final response = await _dio.get(
        '/Sos/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      print('Error getting SOS history: $e');
    }
    return [];
  }
}
