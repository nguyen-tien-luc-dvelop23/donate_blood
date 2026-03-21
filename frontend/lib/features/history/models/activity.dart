import 'package:flutter/material.dart';

enum ActivityType { donation, sos }

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final DateTime date;
  final String location;
  final String? bloodType;
  final String? amount;
  final String statusText;
  final Color statusColor;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.location,
    this.bloodType,
    this.amount,
    required this.statusText,
    required this.statusColor,
  });
}
