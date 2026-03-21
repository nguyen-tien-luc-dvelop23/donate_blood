import 'package:flutter/material.dart';
import 'models/activity.dart';

class ActivityFormScreen extends StatelessWidget {
  final Activity? activity;
  
  const ActivityFormScreen({super.key, this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(activity == null ? 'Thêm hoạt động' : 'Sửa hoạt động')),
      body: const Center(child: Text('Chức năng đang phát triển...')),
    );
  }
}
