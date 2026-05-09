// ignore_for_file: deprecated_member_use

import 'package:fit/classes/coaches.dart/coach.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/lists/coaches/coaches.dart';
import 'package:fit/lists/coaches/search_filters.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  // Filter values
  String _selectedPrice = priceOptions[0];
  String _selectedRating = ratingOptions[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Coaches'),
      drawer: AppDrawer(selectedIndex: 5, role: 'trainee'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            pageHeader(
              'Work with certified professionals to accelerate your progress',
            ),

            // Search and Filters
            _buildSearchAndFilters(),

            // Coaches Grid
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ListView.builder(
                shrinkWrap: true, // ✅ Takes only needed height
                physics:
                    const NeverScrollableScrollPhysics(), // ✅ Disables internal scrolling
                itemCount: coaches.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    _buildCoachCard(coaches[index]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.5),
          ],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Search Row
          Row(
            children: [
              Expanded(
                child: buildSearchInput(_searchController, (value) {
                  // Implement search functionality
                  setState(() {});
                }, 'Search coaches...'),
              ),
              const SizedBox(width: 12),
              _buildMobileFilterButton(),
            ],
          ),

          // Filters Row
          Visibility(
            visible: _showFilters,
            child: Column(
              children: [const SizedBox(height: 20), _buildFiltersRow()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFilters = !_showFilters;
        });
      },
      child: Container(
        width: 54,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.tune, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Wrap(
      spacing: 30,
      runSpacing: 12,
      children: [
        _buildFilterDropdown(
          value: _selectedPrice,
          items: priceOptions,
          onChanged: (value) {
            setState(() {
              _selectedPrice = value;
            });
          },
        ),
        _buildFilterDropdown(
          value: _selectedRating,
          items: ratingOptions,
          onChanged: (value) {
            setState(() {
              _selectedRating = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCoachCard(Coach coach) {
    return SizedBox(
      width: 300, // Adjust width as needed
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image
            Container(
              height: 180,
              clipBehavior: Clip.none, // Allow overflow
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                image: coach.coverImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(coach.coverImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1F2523), AppColors.cardBackground],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none, // Allow overflow
                children: [
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
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
                            const Icon(
                              Icons.star,
                              size: 11,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${coach.rating} (${coach.reviewCount})',
                              style: const TextStyle(
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
                  // Profile Picture
                  Positioned(
                    bottom: -40, // Positive value pushes it down
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
                          image: DecorationImage(
                            image: NetworkImage(coach.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body with increased top padding
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                48, // Increased from 16 to accommodate avatar
                20,
                20,
              ),
              child: Column(
                children: [
                  // Name and Verified Badge
                  Text(
                    coach.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer (rest of your code remains the same)
                  Container(
                    padding: const EdgeInsets.only(top: 12),
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
                              '\$${coach.price}/mo',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/coaches-profile');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
