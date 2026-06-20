import 'package:fit/components/Widgets/build_glowing_card.dart';
import 'package:fit/models/coach/coach_stats.dart';
import 'package:fit/models/coach/trainee_subscriptions.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildWalletSection(CoachStatsData stats) {
  return Row(
    children: [
      Expanded(
        child: buildGlowingCard(
          icon: LucideIcons.briefcase,
          title: 'Available Balance',
          amount: '\$${stats.withdrawableBalance.toStringAsFixed(2)}',
          subtitle: 'Ready for withdrawal',
          color: AppColors.primary,
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: buildGlowingCard(
          icon: LucideIcons.clock,
          title: 'Pending Escrow',
          amount: '\$${stats.escrowPendingBalance.toStringAsFixed(2)}',
          subtitle: 'Waiting for delivery approval',
          color: Color(0xFFEAB308),
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: buildGlowingCard(
          icon: LucideIcons.dollarSign,
          title: 'Lifetime Earnings',
          amount: '\$${stats.totalLifetimeRevenue.toStringAsFixed(2)}',
          subtitle: 'Total platform earnings',
          color: AppColors.primary,
        ),
      ),
    ],
  );
}

Widget buildOperationalStatsRow(
  List<TraineeSubscription> subscriptions,
  CoachStatsData stats,
) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: buildOperationalStats(
              label: 'TOTAL CUSTOMERS',
              value: '${stats.totalCustomersCount}',
              subTitle: 'ALL TIME',
              icon: LucideIcons.users,
              color: AppColors.cardTextSecondary,
            ),
          ),
          Expanded(
            child: buildOperationalStats(
              label: 'ACTIVE CLIENTS',
              value: '${stats.activeClientsCount}',
              subTitle: 'CURRENTLY ACTIVE',
              icon: LucideIcons.user,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: buildOperationalStats(
              label: 'PENDING CLIENTS',
              value: '${stats.pendingClientsCount}',
              subTitle: 'AWAITING ACTIVE',
              icon: LucideIcons.clock,
              color: AppColors.orange,
            ),
          ),
          Expanded(
            child: buildOperationalStats(
              label: 'GROWTH RATE',
              value: '${stats.growthRatePercentage.toStringAsFixed(1)}%',
              subTitle: 'VS LAST MONTH',
              icon: LucideIcons.trendingUp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget buildOperationalStats({
  required String label,
  required String value,
  required String subTitle,
  required IconData icon,
  required Color color,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4),
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppColors.cardTextSecondary),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.cardTextSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
