// ignore_for_file: deprecated_member_use

import 'package:fit/classes/notificaions.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_filters.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/lists/filters/notifications_filter.dart';
import 'package:fit/lists/data/notifications.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter =
      NotificationsFilters[0].id; // This is the state variable

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return notifications; // Return everything
    }
    return notifications.where((n) => n.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED the redeclaration: String _selectedFilter = 'all';

    return Scaffold(
      appBar: MyAppBar(title: 'Notifications'),
      drawer: AppDrawer(selectedIndex: 3, role: 'trainee'),
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: pageHeader(
                'Stay updated with your training, orders, and coach messages.',
              ),
            ),

            // Filters (Sticky on scroll)
            buildFilters(NotificationsFilters, _selectedFilter, (filterId) {
              setState(() {
                _selectedFilter = filterId;
              });
            }),

            // Notifications List or Empty State
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        if (notification.isUnread) {
          setState(() {
            notification.isUnread = false;
          });
        }
        // Handle notification tap
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: notification.isUnread
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.primary, Color(0xFF161C1A)],
                  stops: [0.0, 0.01],
                )
              : null,
          color: notification.isUnread ? null : const Color(0xFF161C1A),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.isUnread
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.white.withOpacity(0.03),
                border: Border.all(
                  color: notification.isUnread
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                notification.icon,
                size: 20,
                color: notification.isUnread
                    ? AppColors.primary
                    : const Color(0xFF8B949E),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isUnread
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: notification.isUnread
                          ? Colors.white
                          : const Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B949E),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time and Unread Dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B949E),
                  ),
                ),
                const SizedBox(height: 8),
                if (notification.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC7F000),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: const Color(0xFF232B28),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found in this category.',
            style: TextStyle(fontSize: 14, color: const Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }
}
