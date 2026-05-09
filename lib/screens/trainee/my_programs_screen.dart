import 'package:fit/classes/coaches_subscribed.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/build_filters.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/lists/data/coaches_subscribed.dart';
import 'package:fit/lists/filters/program_filter.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class MyProgramsScreen extends StatefulWidget {
  const MyProgramsScreen({super.key});

  @override
  State<MyProgramsScreen> createState() => _MyProgramsScreenState();
}

class _MyProgramsScreenState extends State<MyProgramsScreen> {
  // String _selectedFilter = programsFilters[0].id; // Default to the first filter
  // List<CoachesSubscribed> get _filteredPrograms {
  //   if (_selectedFilter == 'all plans') {
  //     return coachList;
  //   } else {
  //     return coachList
  //         .where((p) => p.name.toLowerCase() == _selectedFilter)
  //         .toList();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "My Program"),
      drawer: AppDrawer(selectedIndex: 1, role: 'trainee'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              "Choose a scientifically designed system that matches your fitness goals and schedule.",
            ),

            // const SizedBox(height: 20),

            // buildFilters(programsFilters, _selectedFilter, (filterId) {
            //   setState(() {
            //     _selectedFilter = filterId;
            //   });
            // }),
            const SizedBox(height: 30),

            /// SYSTEM CARDS
            Expanded(
              child: ListView(
                children: coachList.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _systemCard(
                      name: p.name,
                      imageURl: p.imageURL,
                      specializaiton: p.specializaiton,
                      badge: p.badge,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemCard({
    required final String name,
    required final String imageURl,
    required final String specializaiton,
    required final String badge,
  }) {
    final Color badgeColor;
    switch (badge) {
      case 'GOLD':
        badgeColor = AppColors.gold;
        break;
      case 'SILVER':
        badgeColor = AppColors.silver;
        break;
      case 'BRONZE':
        badgeColor = AppColors.bronze;
        break;
      default:
        badgeColor = AppColors.primary;
    }
    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              // Top
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
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(children: [Icon(Icons.message)]),
                  ),
                ],
              ),
            ],
          ),

          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(imageURl),
              backgroundColor: AppColors.cardBorder,
              child: imageURl.isEmpty ? Text('${name[0]}') : null,
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
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
                    specializaiton,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                buildButton('View Program', Icon(Icons.bolt_outlined), () {
                  Navigator.pushNamed(context, '/program-details');
                }, true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
