import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Dio _dio = ApiClient().dio;

  Future<Options> get _auth async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final res = await _dio.get('/Notification', options: await _auth);
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return {'notifications': [], 'unreadCount': 0};
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put('/Notification/read-all', options: await _auth);
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.put('/Notification/$id/read', options: await _auth);
    } catch (_) {}
  }
}
