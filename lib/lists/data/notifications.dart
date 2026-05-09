import 'package:fit/classes/notificaions.dart';
import 'package:flutter/material.dart';

final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'New message from Coach Michael',
      description:
          '"Great work on the squat PR! Let\'s adjust your volume for next week to optimize recovery."',
      time: '10m ago',
      category: 'message',
      icon: Icons.mark_email_unread_outlined,
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      title: 'Someone liked your post',
      description:
          'Seif Ayman liked your post: "Just hit a new PR on deadlifts! 150kg for 3 reps!"',
      time: '2h ago',
      category: 'like',
      icon: Icons.thumb_up_alt_outlined,
      isUnread: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Subscription Successful',
      description: 'Your subscription has been confirmed.',
      time: '5h ago',
      category: 'subscription confirmation',
      icon: Icons.check_circle_outlined,
      isUnread: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Someone commented on your post',
      description: 'John Cena commented on your post: "Impressive dedication! What\'s your secret?"',
      time: '1d ago',
      category: 'comment',
      icon: Icons.message_outlined,
      isUnread: false,
    ),
    NotificationItem(
      id: '5',
      title: 'New Comment on Your Post',
      description:
          'John Cena commented on your post: "Impressive dedication! What\'s your secret?"',
      time: '2d ago',
      category: 'community',
      icon: Icons.group_outlined,
      isUnread: false,
    ),
    NotificationItem(
      id: '6',
      title: 'Someone followed you',
      description: 'Randy Orton started following you.',
      time: '3d ago',
      category: 'follow',
      icon: Icons.person_add_outlined,
      isUnread: false,
    ),
    NotificationItem(
      id: '7',
      title: 'Reminder: Upcoming Workout',
      description: 'You have a scheduled workout tomorrow at 9:00 AM.',
      time: '3d ago',
      category: 'workout reminder',
      icon: Icons.alarm_outlined,
      isUnread: false,
    ),
  ];