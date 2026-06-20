import 'package:fit/components/Widgets/drawer_item.dart';
import 'package:fit/components/Logo/sporta.dart';
import 'package:fit/screens/coach/subscriptions_screen.dart';
import 'package:fit/screens/coach_programs/my_programs_screen2.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/screens/chat%20bot/sporta_ai_screen.dart';
import 'package:fit/screens/trainee/coaches_screen.dart';
import 'package:fit/screens/community/community_screen.dart';
import 'package:fit/screens/messages/messages_screen.dart';
import 'package:fit/screens/settings/settings_screen.dart';
import 'package:fit/screens/store/store_screen.dart';
import 'package:fit/screens/trainee/my_programs_screen.dart';
import 'package:fit/screens/notifications/notifications_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final int? selectedIndex;
  final String? role;

  const AppDrawer({super.key, this.selectedIndex, required this.role});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await ApiService.getNotifications(
        pageNumber: 1,
        pageSize: 100,
      );
      final unreadCount = response.items.where((n) => !n.isRead).length;
      setState(() {
        _unreadCount = unreadCount;
      });
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          if (widget.role == "trainee") ...[
            DrawerItem(
              Icons.person,
              "Profile",
              active: widget.selectedIndex == 0,
              onTap: () => _navigate(context, const ProfileScreen()),
            ),
            DrawerItem(
              Icons.fitness_center_outlined,
              "My Program",
              active: widget.selectedIndex == 1,
              onTap: () => _navigate(context, const MyProgramsScreen()),
            ),

            DrawerItem(
              Icons.shopping_cart_outlined,
              "Store",
              active: widget.selectedIndex == 2,
              onTap: () => _navigate(context, StoreScreen(role: widget.role)),
            ),

            DrawerItem(
              Icons.notifications_outlined,
              "Notifications",
              active: widget.selectedIndex == 3,
              onTap: () => _navigate(
                context,
                NotificationsScreen(role: widget.role ,onNotificationsChanged: _fetchUnreadCount),
              ),
              badgeCount: _unreadCount,
            ),

            DrawerItem(
              Icons.group_outlined,
              "Community",
              active: widget.selectedIndex == 4,
              onTap: () => _navigate(context, const CommunityScreen()),
            ),

            DrawerItem(
              Icons.sports_gymnastics_outlined,
              "Coaches",
              active: widget.selectedIndex == 5,
              onTap: () => _navigate(context, const CoachesScreen()),
            ),

            DrawerItem(
              Icons.message_outlined,
              "Messages",
              active: widget.selectedIndex == 6,
              onTap: () => _navigate(context, const MessagesScreen()),
            ),

            DrawerItem(
              Icons.smart_toy_outlined,
              "Sporta AI",
              active: widget.selectedIndex == 7,
              onTap: () => _navigate(context, const SportaAIScreen()),
            ),
            DrawerItem(
              Icons.settings,
              "Settings",
              active: widget.selectedIndex == 8,
              onTap: () => _navigate(context, SettingsScreen(role: widget.role,)),
            ),
          ],
          if (widget.role == "trainer") ...[
            DrawerItem(
              Icons.person_outline,
              "Profile",
              active: widget.selectedIndex == 0,
              onTap: () => _navigate(context, const ProfileScreen()),
            ),

            DrawerItem(
              Icons.fitness_center_outlined,
              "Subscriptions",
              active: widget.selectedIndex == 1,
              onTap: () => _navigate(context, const SubscriptionsScreen()),
            ),

            DrawerItem(
              Icons.manage_accounts_outlined,
              "My Programs",
              active: widget.selectedIndex == 2,
              onTap: () => _navigate(context, const MyProgramsScreen2()),
            ),

            DrawerItem(
              Icons.store_outlined,
              "Store",
              active: widget.selectedIndex == 3,
              onTap: () => _navigate(context, StoreScreen(role: widget.role,)),
            ),

            DrawerItem(
              Icons.group_outlined,
              "Community",
              active: widget.selectedIndex == 4,
              onTap: () => _navigate(context, const CommunityScreen()),
            ),

            DrawerItem(
              Icons.message_outlined,
              "Messages",
              active: widget.selectedIndex == 5,
              onTap: () => _navigate(context, const MessagesScreen()),
            ),

            DrawerItem(
              Icons.notifications_outlined,
              "Notifications",
              active: widget.selectedIndex == 6,
              onTap: () => _navigate(
                context,
                NotificationsScreen(onNotificationsChanged: _fetchUnreadCount, role: widget.role,),
              ),
              badgeCount: _unreadCount,
            ),

            DrawerItem(
              Icons.smart_toy_outlined,
              "Sporta AI",
              active: widget.selectedIndex == 7,
              onTap: () => _navigate(context, const SportaAIScreen()),
            ),
            DrawerItem(
              Icons.settings,
              "Settings",
              active: widget.selectedIndex == 8,
              onTap: () => _navigate(context, SettingsScreen(role: widget.role,)),
            ),
          ],
          const SizedBox(height: 20),
          sportaLogo(),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
