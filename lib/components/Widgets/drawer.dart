import 'package:fit/components/Widgets/drawer_item.dart';
import 'package:fit/components/Logo/sporta.dart';
import 'package:fit/screens/coach/coach_profile_screen.dart';
import 'package:fit/screens/coach/dashboard_screen.dart';
import 'package:fit/screens/coach/my_trainees_screen.dart';
import 'package:fit/screens/coach/program_management_screen.dart';
import 'package:fit/screens/trainee/ai_assistant_screen.dart';
import 'package:fit/screens/trainee/coaches_screen.dart';
import 'package:fit/screens/trainee/community_screen.dart';
import 'package:fit/screens/trainee/notifications_screen.dart';
import 'package:fit/screens/trainee/messages_screen.dart';
import 'package:fit/screens/trainee/profile_screen.dart';
import 'package:fit/screens/trainee/store_screen.dart';
import 'package:fit/screens/trainee/my_programs_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final String role;

  const AppDrawer({super.key, required this.selectedIndex, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          if (role == "trainee") ...[
            

            DrawerItem(
              Icons.fitness_center_outlined,
              "My Program",
              active: selectedIndex == 1,
              onTap: () => _navigate(context, const MyProgramsScreen()),
            ),

            DrawerItem(
              Icons.shopping_cart_outlined,
              "Store",
              active: selectedIndex == 2,
              onTap: () => _navigate(context, const StoreScreen()),
            ),

            DrawerItem(
              Icons.notifications_outlined,
              "Notifications",
              active: selectedIndex == 3,
              onTap: () => _navigate(context, const NotificationsScreen()),
            ),

            DrawerItem(
              Icons.group_outlined,
              "Community",
              active: selectedIndex == 4,
              onTap: () => _navigate(context, const CommunityScreen()),
            ),

            DrawerItem(
              Icons.sports_gymnastics_outlined,
              "Coaches",
              active: selectedIndex == 5,
              onTap: () => _navigate(context, const CoachesScreen()),
            ),

            DrawerItem(
              Icons.message_outlined,
              "Messages",
              active: selectedIndex == 6,
              onTap: () => _navigate(context, const MessagesScreen()),
            ),

            DrawerItem(
              Icons.smart_toy_outlined,
              "AI Assistant",
              active: selectedIndex == 7,
              onTap: () => _navigate(context, const AiAssistantScreen()),
            ),
          ],
          if (role == "coach") ...[
            DrawerItem(
              Icons.person_outline,
              "Profile",
              active: selectedIndex == 0,
              onTap: () => _navigate(context, const CoachProfileScreen()),
            ),

            DrawerItem(
              Icons.fitness_center_outlined,
              "My Trainees",
              active: selectedIndex == 1,
              onTap: () => _navigate(context, const MyTraineesScreen()),
            ),

            DrawerItem(
              Icons.manage_accounts_outlined,
              "Program Management",
              active: selectedIndex == 2,
              onTap: () => _navigate(context, const ProgramManagementScreen()),
            ),

            DrawerItem(
              Icons.store_outlined,
              "Store",
              active: selectedIndex == 3,
              onTap: () => _navigate(context, const StoreScreen()),
            ),

            DrawerItem(
              Icons.dashboard_outlined,
              "Dashboard",
              active: selectedIndex == 4,
              onTap: () => _navigate(context, DashboardScreen()),
            ),

            DrawerItem(
              Icons.group_outlined,
              "Community",
              active: selectedIndex == 5,
              onTap: () => _navigate(context, const CommunityScreen()),
            ),

            DrawerItem(
              Icons.message_outlined,
              "Messages",
              active: selectedIndex == 6,
              onTap: () => _navigate(context, const MessagesScreen()),
            ),

            DrawerItem(
              Icons.notifications_outlined,
              "Notifications",
              active: selectedIndex == 7,
              onTap: () => _navigate(context, const NotificationsScreen()),
            ),

            DrawerItem(
              Icons.smart_toy_outlined,
              "AI Assistant",
              active: selectedIndex == 8,
              onTap: () => _navigate(context, const AiAssistantScreen()),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
