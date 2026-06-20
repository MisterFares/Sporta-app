// subscriptions_grid.dart
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/models/coach/trainee_subscriptions.dart';
import 'package:fit/screens/messages/chat_room.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

String _formatReviewTimer(int hours) {
  if (hours <= 0) return 'No review pending';

  if (hours < 24) {
    return '${hours}h remaining';
  } else if (hours < 48) {
    return '${hours ~/ 24} day remaining';
  } else if (hours < 168) {
    // Less than 7 days
    return '${hours ~/ 24} days remaining';
  } else {
    return '${hours ~/ 24} days remaining';
  }
}

Widget buildSubscriptionsGrid(
  BuildContext context,
  List<TraineeSubscription> subscriptions,
  Function(TraineeSubscription) onUploadPressed,
) {
  final subs = subscriptions;
  final deviceWidth = MediaQuery.of(context).size.width;

  if (subs.isEmpty) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.cardTextSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No subscriptions found',
              style: TextStyle(color: AppColors.cardTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  return LayoutBuilder(
    builder: (context, raints) {
      int crossAxisCount = 1;
      if (raints.maxWidth > 700) crossAxisCount = 2;
      if (raints.maxWidth > 1100) crossAxisCount = 3;

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: deviceWidth >= 400 ? 1.0 : 0.85,
        ),
        itemCount: subs.length,
        itemBuilder: (context, index) =>
            buildSubscriptionCard(subs[index], context, onUploadPressed),
      );
    },
  );
}

Widget buildSubscriptionCard(
  TraineeSubscription sub,
  BuildContext context,
  Function(TraineeSubscription) onUploadPressed,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isGrid = screenWidth > 700;

  Color getTierColor() {
    switch (sub.tier) {
      case 'Gold':
        return AppColors.gold;
      case 'Silver':
        return AppColors.silver;
      default:
        return AppColors.bronze;
    }
  }

  String getStatusText() {
    switch (sub.subscriptionStatus) {
      case 'active':
        return '${sub.daysRemaining} days remaining';
      case 'pending':
        return 'Pending upload';
      case 'awaitingpayment':
        return 'Awaiting payment';
      case 'expired':
        return 'Subscription expired';
      default:
        return 'Refund requested';
    }
  }

  return Container(
    constraints: isGrid ? BoxConstraints(minWidth: 300, maxWidth: 400) : null,
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(sub.traineeAvatar),
                    backgroundColor: AppColors.cardBorder,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.traineeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          sub.traineeEmail,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.cardTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getTierColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sub.tier,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: getTierColor(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                sub.programTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sub.subscriptionStatus == 'active'
                          ? AppColors.primary
                          : (sub.subscriptionStatus == 'pending' ||
                                    sub.subscriptionStatus == 'awaitingpayment'
                                ? AppColors.orange
                                : AppColors.red),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (sub.reviewTimer > 0) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.cardTextSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Review: ${_formatReviewTimer(sub.reviewTimer)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 12),
              if (sub.hasWorkoutPlan)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.hexagon,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'WORKOUT INCLUDED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (sub.workoutUploaded) ...[
                        SizedBox(width: 13),
                        Icon(
                          LucideIcons.checkCircle2,
                          color: AppColors.primary,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                ),
              SizedBox(height: 8),
              if (sub.hasNutritionPlan)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'NUTRITION INCLUDED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (sub.nutritionUploaded) ...[
                        SizedBox(width: 10),
                        Icon(
                          LucideIcons.checkCircle2,
                          color: AppColors.primary,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.cardBorder),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: buildButton('Profile', Icon(Icons.person), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileScreen(userProfile: null, isOwner: false),
                        settings: RouteSettings(arguments: sub.traineeId),
                      ),
                    );
                  }, false),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 45,
                      child: buildButton(
                        'Chat',
                        Icon(Icons.chat_bubble_outline),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                userId: sub.traineeId,
                                userName: sub.traineeName,
                                userAvatar: sub.traineeAvatar,
                                onBack: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                        false,
                      ),
                    ),
                    if (sub.unreadMessages > 0)
                      Positioned(
                        right: 0,
                        top: -1,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            sub.unreadMessages.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: sub.subscriptionStatus != 'expired'
                ? SizedBox(
                    height: 45,
                    child: buildButton(
                      sub.refundLocked ? 'Locked' : 'Upload Program',
                      Icon(
                        sub.refundLocked ? Icons.lock : Icons.upload,
                        size: 14,
                      ),
                      sub.refundLocked ? () {} : () => onUploadPressed(sub),
                      true,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.025),
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.checkCircle2,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
