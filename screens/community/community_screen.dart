import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/screens/community/posts_section.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserAvatar;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserInfo();
  }

  Future<void> _fetchCurrentUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      setState(() {
        _currentUserId = userId;
      });

      print("🔴 Current User ID: $_currentUserId");
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Community', drawerIcon: Icons.menu),
      drawer: AppDrawer(selectedIndex: 4, role: 'trainee'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: buildSearchInput(
                _searchController,
                () {},
                'Search for Trainers, Trainees',
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              // ← THIS IS KEY
              child: PostsSection(
                userId: _currentUserId ?? '',
                isOwner: true,
                mode: PostMode.community,
                currentUserName: _currentUserName,
                currentUserAvatar: _currentUserAvatar,
                currentUserId: _currentUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
