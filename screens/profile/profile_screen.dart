import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/models/profile/user_profile.dart';
import 'package:fit/screens/profile/certification_section.dart';
import 'package:fit/screens/community/posts_section.dart';
import 'package:fit/screens/profile/profile_header.dart';
import 'package:fit/screens/profile/programs_section.dart';
import 'package:fit/screens/profile/recommendations_section.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isOwner;

  const ProfileScreen({super.key, this.userProfile, this.isOwner = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _data;
  bool _isLoading = false;
  bool _isOwner = true;
  bool _hasCheckedArguments = false; // Add this flag

  @override
  void initState() {
    super.initState();

    debugPrint('📦 ProfileScreen initState called');

    if (widget.userProfile != null) {
      _data = widget.userProfile!;
      _isOwner = widget.isOwner;
      debugPrint('✅ Successfully assigned passed UserProfile data');
      _hasCheckedArguments = true; // Mark as done
    } else {
      // Temporary initial object
      _data = UserProfile(
        userId: '',
        fullName: 'Loading...',
        email: '',
        role: 'Trainee',
        birthDate: '',
        followersCount: 0,
        followingCount: 0,
        receivedRecommendationsCount: 0,
        givenRecommendationsCount: 0,
        isFollowedByCurrentUser: false,
        isBlockedByCurrentUser: false,
        canMessage: true,
        hasBlockedTarget: false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only check arguments once and if no profile was passed
    if (!_hasCheckedArguments && widget.userProfile == null) {
      _hasCheckedArguments = true;
      _checkForArguments();
    }
  }

  void _checkForArguments() {
    // Get the route and check for arguments (coach ID)
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;

    if (args != null && args is String) {
      debugPrint('📦 User ID from arguments: $args');
      _fetchUserProfileById(args);
    } else {
      // No arguments, fetch current user profile
      _fetchMyUserProfile();
    }
  }

  Future<void> _fetchUserProfileById(String userId) async {
    try {
      setState(() => _isLoading = true);

      final UserProfile profile = await ApiService.getUserProfile(userId);

      // Get current logged-in user ID to determine if this is owner
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId') ?? '';
      final isOwner = currentUserId == userId;

      setState(() {
        _data = profile;
        _isOwner = isOwner;
        _isLoading = false;
      });

      debugPrint(
        '✅ Successfully loaded user profile from server (isOwner: $isOwner)',
      );
    } catch (e) {
      debugPrint('❌ ERROR fetching user profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMyUserProfile() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId') ?? '';

      if (savedUserId.isEmpty) {
        debugPrint(
          '❌ ERROR: Local storage user ID is empty. User might not be logged in.',
        );
        setState(() => _isLoading = false);
        return;
      }

      final UserProfile profile = await ApiService.getUserProfile(savedUserId);

      setState(() {
        _data = profile;
        _isOwner = true;
        _isLoading = false;
      });

      debugPrint('✅ Successfully loaded own profile from server');
    } catch (e) {
      debugPrint('❌ ERROR fetching UserProfile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isTrainer = _data.role.toLowerCase() == 'trainer';

    return Scaffold(
      appBar: _isOwner
          ? MyAppBar(title: 'Profile', drawerIcon: Icons.menu)
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
              title: Text(
                _data.fullName,
                style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
              ),
            ),
      drawer: _isOwner
          ? AppDrawer(selectedIndex: 0, role: _data.role.toLowerCase())
          : null,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ProfileHeader(
                            userProfile: _data,
                            isOwner: _isOwner,
                            onUpdate: (updated) =>
                                setState(() => _data = updated),
                          ),
                          const SizedBox(height: 8),
                          if (isTrainer) ...[
                            CertificationsSection(
                              coachId: _data.userId,
                              isOwner: _isOwner,
                            ),
                            const SizedBox(height: 8),
                            ProgramsSection(
                              isOwner: _isOwner,
                              role: _data.role,
                              userId: _data.userId,
                            ),
                            const SizedBox(height: 8),
                          ],
                          RecommendationsSection(
                            userId: _data.userId,
                            isOwner: _isOwner,
                          ),
                          const SizedBox(height: 8),
                          PostsSection(userId: _data.userId, isOwner: _isOwner),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
