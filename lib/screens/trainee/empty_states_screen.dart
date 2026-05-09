import 'package:fit/components/Widgets/empty_card.dart';
import 'package:flutter/material.dart';

class EmptyStatesScreen extends StatelessWidget {
  const EmptyStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                childAspectRatio: 1,
                children: [
                  buildEmptyCard(
                    icon: Icons.fitness_center,
                    title: "No programs created",
                    description:
                        "Start building your first workout or nutrition plan to share with your trainees.",
                    buttonText: "Create Program",
                    isPrimary: true,
                  ),
                  buildEmptyCard(
                    icon: Icons.group,
                    title: "No active subscribers",
                    description:
                        "Share your profile link to start attracting athletes and growing your team.",
                    buttonText: "Copy Profile Link",
                    isPrimary: false,
                  ),
                  buildEmptyCard(
                    icon: Icons.notifications_off,
                    title: "All caught up",
                    description:
                        "You have no new notifications at the moment. Check back later for updates.",
                    buttonText: "Refresh",
                    isPrimary: false,
                  ),
                  buildEmptyCard(
                    icon: Icons.dashboard_outlined,
                    title: "Feed is empty",
                    description:
                        "Your coaches haven't posted anything yet. Explore other coaches to see more content.",
                    buttonText: "Explore Coaches",
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
