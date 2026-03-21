import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;
  List<Activity> get donations => _activities.where((a) => a.type == ActivityType.donation).toList();
  List<Activity> get sosRequests => _activities.where((a) => a.type == ActivityType.sos).toList();

  Future<void> fetchActivities() async {
    // Mock fetch
    _activities = [
      Activity(
        id: '1',
        type: ActivityType.donation,
        title: 'Hiến máu tình nguyện',
        date: DateTime.now().subtract(const Duration(days: 10)),
        location: 'Viện Huyết học Truyền máu TW',
        amount: '350ml',
        statusText: 'Thành công',
        statusColor: Colors.green,
      ),
      Activity(
        id: '2',
        type: ActivityType.sos,
        title: 'Kêu gọi khẩn cấp',
        date: DateTime.now().subtract(const Duration(days: 2)),
        location: 'Bệnh viện Bạch Mai',
        bloodType: 'O+',
        statusText: 'Đã hoàn thành',
        statusColor: Colors.blue,
      ),
    ];
    notifyListeners();
  }

  void deleteActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
