import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class DonationService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getMyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await _dio.get(
        '/Donation/history',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Get donation history error: $e');
    }
    return [];
  }

  // Helper method for testing/admin to add a record
  Future<bool> addDonationRecord(String hospitalName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await _dio.post(
        '/Donation/add',
        data: {
          'hospitalName': hospitalName,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Add donation error: $e');
      return false;
    }
  }
}
