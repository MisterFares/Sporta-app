import 'dart:async';

import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_dropdown_filter.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/models/trainee/discovery_coach.dart';
import 'package:fit/screens/profile/default_cover.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<DiscoveryCoach> _coaches = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;

  // Filter values
  String _selectedPrice = 'Price: Any';
  String _selectedRating = 'Rating: Any';

  // Price range mapping
  double? _minPrice;
  double? _maxPrice;

  // Debounce search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse price filter
      _parsePriceFilter();

      // Parse rating filter
      double? minRating;
      if (_selectedRating == 'Rating: 4.8+') {
        minRating = 4.8;
      } else if (_selectedRating == 'Rating: 5.0') {
        minRating = 5.0;
      }

      final result = await ApiService.getDiscoveryCoaches(
        pageNumber: _currentPage,
        pageSize: 10,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        minRating: minRating,
        maxPrice: _maxPrice,
        isVerified: null,
      );

      setState(() {
        _coaches = result['coaches'];
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _parsePriceFilter() {
    switch (_selectedPrice) {
      case '\$0 - \$119':
        _minPrice = 0;
        _maxPrice = 119;
        break;
      case '\$120 - \$174':
        _minPrice = 120;
        _maxPrice = 174;
        break;
      case '\$175+':
        _minPrice = 175;
        _maxPrice = null;
        break;
      default:
        _minPrice = null;
        _maxPrice = null;
    }
  }

  void _applyFilters() {
    _currentPage = 1;
    _fetchCoaches();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _currentPage = 1;
      _fetchCoaches();
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchCoaches();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _fetchCoaches();
    }
  }

  // Parse price string to numeric value for comparison
  double _parsePriceValue(String priceString) {
    final match = RegExp(r'[\d.]+').firstMatch(priceString);
    if (match != null) {
      return double.parse(match.group(0)!);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Apply client-side filters for price ranges that the API doesn't support
    final filteredCoaches = _filterCoachesLocally(_coaches);

    return Scaffold(
      appBar: MyAppBar(drawerIcon: Icons.menu, title: 'Coaches'),
      drawer: AppDrawer(selectedIndex: 5, role: 'trainee'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: pageHeader(
                      'Work with certified professionals to accelerate your progress',
                    ),
                  ),
                  SizedBox(height: 8),

                  // Search and Filters
                  _buildSearchAndFilters(),

                  // Results count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${filteredCoaches.length} coaches found on this page',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Content
                  filteredCoaches.isEmpty
                      ? _buildEmptyState()
                      : Padding(
                          padding: EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: filteredCoaches.map((coach) {
                              return SizedBox(
                                width: double.infinity,
                                child: _buildCoachCard(coach),
                              );
                            }).toList(),
                          ),
                        ),

                  // Pagination Controls
                  if (_coaches.isNotEmpty) _buildPaginationControls(),

                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: _currentPage < _totalPages ? _goToNextPage : null,
          ),
        ],
      ),
    );
  }

  List<DiscoveryCoach> _filterCoachesLocally(List<DiscoveryCoach> coaches) {
    return coaches.where((coach) {
      // Search filter (additional local filtering)
      bool matchesSearch = true;
      if (_searchController.text.isNotEmpty) {
        matchesSearch =
            coach.fullName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            coach.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }

      // Price filter (client-side for ranges not supported by API)
      bool matchesPrice = true;
      final priceValue = _parsePriceValue(coach.startingPrice);
      if (_minPrice != null && priceValue < _minPrice!) {
        matchesPrice = false;
      }
      if (_maxPrice != null && priceValue > _maxPrice!) {
        matchesPrice = false;
      }

      return matchesSearch && matchesPrice;
    }).toList();
  }

  Widget _buildErrorState() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load coaches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Please try again',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCoaches,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No coaches found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Search Row
          buildSearchInput(_searchController, (value) {
            setState(() {});
            _onSearchChanged(value);
          }, 'Search coaches...'),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: buildFilterDropdown(
                  _selectedPrice,
                  ['Price: Any', '\$0 - \$119', '\$120 - \$174', '\$175+'],
                  (v) => setState(() {
                    _selectedPrice = v;
                    _applyFilters();
                  }),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: buildFilterDropdown(
                  _selectedRating,
                  ['Rating: Any', 'Rating: 4.8+', 'Rating: 5.0'],
                  (v) => setState(() {
                    _selectedRating = v;
                    _applyFilters();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(DiscoveryCoach coach) {
    // Get full image URLs
    final profileImageUrl = ImageUrlHelper.getFullImageUrl(
      coach.profileImageUrl,
    );
    final coverImageUrl = ImageUrlHelper.getFullImageUrl(coach.coverImageUrl);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image
          Container(
            height: 180,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1F2523), AppColors.cardBackground],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Image with error handling
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: coverImageUrl != null && coverImageUrl.isNotEmpty
                      ? Image.network(
                          coverImageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 180,
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        )
                      : DefaultCover(),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.cardBackground],
                    ),
                  ),
                ),
                // Rating
                Positioned(
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 11, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text(
                            '${coach.rating.toStringAsFixed(1)} (${coach.reviewsCount})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Verified Badge
                if (coach.isVerified)
                  Positioned(
                    left: 0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'VERIFIED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Badge (if any)
                if (coach.badge != null && coach.badge!.isNotEmpty)
                  Positioned(
                    left: coach.isVerified ? 80 : 0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          coach.badge!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Profile Picture
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 4,
                        ),
                        color: AppColors.cardBackground,
                      ),
                      child: ClipOval(
                        child:
                            profileImageUrl != null &&
                                profileImageUrl.isNotEmpty
                            ? Image.network(
                                profileImageUrl,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(
              children: [
                Text(
                  coach.fullName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  coach.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STARTING AT',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            coach.startingPrice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userProfile: null, // Pass null to fetch by ID
                                isOwner: false, // Not the owner
                              ),
                              settings: RouteSettings(
                                arguments: coach.coachId,
                              ), // Pass coach ID
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.border),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
