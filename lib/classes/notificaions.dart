import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category;
  final IconData icon;
  bool isUnread;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.icon,
    required this.isUnread,
  });
}