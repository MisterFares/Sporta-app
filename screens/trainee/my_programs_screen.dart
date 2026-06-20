import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/models/trainee/subscribed_coach.dart';
import 'package:fit/screens/messages/chat_room.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/screens/trainee/programs_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyProgramsScreen extends StatefulWidget {
  const MyProgramsScreen({super.key});

  @override
  State<MyProgramsScreen> createState() => _MyProgramsScreenState();
}

class _MyProgramsScreenState extends State<MyProgramsScreen> {
  List<SubscribedCoach> _coaches = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 👇 ADD FILTER STATE
  String _selectedTier = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 👇 ADD FILTERED LIST
  List<SubscribedCoach> get _filteredCoaches {
    return _coaches.where((coach) {
      // Tier filter
      if (_selectedTier != 'All' && coach.tier.toLowerCase() != _selectedTier.toLowerCase()) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        return coach.coach.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               coach.coach.specialization.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSubscribedCoaches();
  }

  Future<void> _loadSubscribedCoaches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coaches = await ApiService.getSubscribedCoaches();
      setState(() {
        _coaches = coaches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCoaches = _filteredCoaches;

    return Scaffold(
      appBar: MyAppBar(drawerIcon: Icons.menu, title: "My Program"),
      drawer: AppDrawer(selectedIndex: 1, role: 'trainee'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              "Choose a scientifically designed system that matches your fitness goals and schedule.",
            ),
            
            const SizedBox(height: 16),

            // 👇 SEARCH INPUT
            buildSearchInput(
              _searchController,
              (val) => setState(() => _searchQuery = val),
              'Search coaches...',
            ),

            const SizedBox(height: 16),

            // 👇 FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedTier == 'All'),
                  _buildFilterChip('Bronze', _selectedTier == 'Bronze'),
                  _buildFilterChip('Silver', _selectedTier == 'Silver'),
                  _buildFilterChip('Gold', _selectedTier == 'Gold'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading programs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.cardTextSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSubscribedCoaches,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredCoaches.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No programs available'
                            : 'No coaches found matching your search',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _searchQuery.isEmpty
                            ? 'You haven\'t subscribed to any programs yet.'
                            : 'Try adjusting your search or filter.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: filteredCoaches.map((coach) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _systemCard(coach: coach),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 👇 FILTER CHIP WIDGET
  Widget _buildFilterChip(String label, bool isSelected) {
    Color getColor() {
      switch (label.toLowerCase()) {
        case 'bronze':
          return AppColors.bronze;
        case 'silver':
          return AppColors.silver;
        case 'gold':
          return AppColors.gold;
        default:
          return AppColors.primary;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedTier = label),
        backgroundColor: AppColors.cardBackground,
        selectedColor: getColor(),
        side: BorderSide(
          color: isSelected ? getColor() : AppColors.cardBorder,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _systemCard({required final SubscribedCoach coach}) {
    // Determine tier color
    Color badgeColor;
    switch (coach.tier.toLowerCase()) {
      case 'gold':
        badgeColor = AppColors.gold;
        break;
      case 'silver':
        badgeColor = AppColors.silver;
        break;
      case 'bronze':
        badgeColor = AppColors.bronze;
        break;
      default:
        badgeColor = AppColors.primary;
    }

    final String avatarUrl =
        ImageUrlHelper.getFullImageUrl(coach.coach.image) ?? '';

    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: badgeColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: badgeColor,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      coach.tier.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoom(
                        userId: coach.coach.id,
                        userName: coach.coach.name,
                        userAvatar: avatarUrl,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.textPrimary),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            '${coach.unreadMessages}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        size: 30,
                        LucideIcons.messageCircle,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileScreen(userProfile: null, isOwner: false),
                    settings: RouteSettings(arguments: coach.coach.id),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                backgroundColor: AppColors.cardBorder,
                child: avatarUrl.isEmpty
                    ? Text(
                        coach.coach.name.isNotEmpty ? coach.coach.name[0] : 'P',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  coach.coach.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    coach.coach.specialization,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: coach.status == 'pendingaction'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: coach.status == 'pendingaction'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  child: Text(
                    _formatStatus(coach.status),
                    style: TextStyle(
                      color: coach.status == 'pendingaction'
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                buildButton('View Program', Icon(Icons.bolt_outlined), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgramsScreen(coachId: coach.coach.id),
                    ),
                  );
                }, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendingaction':
        return 'PENDING ACTION';
      case 'active':
        return 'ACTIVE';
      case 'completed':
        return 'COMPLETED';
      case 'onhold':
        return 'ON HOLD';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}