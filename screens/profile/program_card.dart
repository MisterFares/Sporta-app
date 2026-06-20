import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/models/coach/program.dart';
import 'package:fit/styles/colors.dart';

class ProgramCard extends StatelessWidget {
  final Program program;
  final bool isSubscribed;
  final bool isSubscribing;
  final VoidCallback onSubscribe;
  final VoidCallback onTap;
  final bool isOwner;
  final bool hasAnySubscription;

  const ProgramCard({
    super.key,
    required this.program,
    required this.isSubscribed,
    required this.isSubscribing,
    required this.onSubscribe,
    required this.onTap,
    required this.isOwner,
    required this.hasAnySubscription,
  });

  Color _getTierColor(String tier) {
    switch (tier) {
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

  IconData _getServiceIcon(String serviceType) {
    final type = serviceType.toLowerCase();
    if (type.contains('workout') && type.contains('nutrition'))
      return LucideIcons.zap;
    if (type.contains('nutrition')) return LucideIcons.apple;
    return LucideIcons.dumbbell;
  }

  String _getServiceLabel(String serviceType) {
    final type = serviceType.toLowerCase();
    if (type.contains('workout') && type.contains('nutrition'))
      return 'Workout & Nutrition';
    if (type.contains('nutrition')) return 'Nutrition';
    return 'Workout';
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(program.tier);
    final serviceIcon = _getServiceIcon(program.serviceType);
    final serviceLabel = _getServiceLabel(program.serviceType);

    String textToShow = program.description.isNotEmpty
        ? program.description
        : (program.features.isNotEmpty
              ? program.features.join(' • ')
              : 'Click to view program full details and features.');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    program.thumbnail,
                    height: 112,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 112,
                        color: AppColors.cardBackground,
                        child: Center(
                          child: Icon(
                            LucideIcons.imageOff,
                            size: 24,
                            color: AppColors.cardTextSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.duration,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Service type badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(serviceIcon, size: 10, color: tierColor),
                        const SizedBox(width: 4),
                        Text(
                          serviceLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    textToShow.length > 60
                        ? '${textToShow.substring(0, 60)}...'
                        : textToShow,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.cardTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Price section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRICE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '\$${program.finalPrice}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (program.basePrice is int &&
                                  program.basePrice! > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '\$${program.basePrice}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.cardTextSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (program.discount is int && program.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.2),
                            border: Border.all(
                              color: tierColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${program.discount}% OFF',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: tierColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: _buildButton(tierColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(Color tierColor) {
    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shield,
                size: 14,
                color: AppColors.cardTextSecondary,
              ),
              SizedBox(width: 8),
              Text(
                'Owner View',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cardTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 👇 CHECK SUBSCRIBED FIRST
    if (isSubscribed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.check, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Subscribed',
                style: TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    // 👇 THEN CHECK IF NOT ALLOWED (means has other subscription)
    if (!program.isAllowedToSubscribe) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.1),
          border: Border.all(color: AppColors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.lock, size: 14, color: AppColors.red),
              SizedBox(width: 8),
              Text(
                'Locked',
                style: TextStyle(fontSize: 11, color: AppColors.red),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onSubscribe,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isSubscribing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Subscribe Now',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
