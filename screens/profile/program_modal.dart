import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/models/coach/program.dart';
import 'package:fit/styles/colors.dart';

class ProgramModal extends StatelessWidget {
  final Program? program;
  final VoidCallback onClose;
  final bool isSubscribed;
  final bool isSubscribing;
  final VoidCallback onSubscribe;
  final bool isOwner;

  const ProgramModal({
    super.key,
    required this.program,
    required this.onClose,
    required this.isSubscribed,
    required this.isSubscribing,
    required this.onSubscribe,
    required this.isOwner,
  });

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze': return AppColors.bronze;
      case 'silver': return AppColors.silver;
      case 'gold': return AppColors.gold;
      default: return AppColors.primary;
    }
  }

  String _getTierBadgeText(String tier) {
    switch (tier) {
      case 'bronze': return 'BRONZE';
      case 'silver': return 'SILVER';
      case 'gold': return 'GOLD';
      default: return tier.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (program == null) return const SizedBox.shrink();

    final tierColor = _getTierColor(program!.tier);
    final tierBadgeText = _getTierBadgeText(program!.tier);

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            
            // Content
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        program!.thumbnail,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: AppColors.cardBackground,
                            child: Center(
                              child: Icon(LucideIcons.imageOff, size: 32, color: AppColors.cardTextSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Badges
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Duration badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.clock, size: 10, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(program!.duration, style: const TextStyle(fontSize: 10, color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tier badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tierColor.withOpacity(0.2),
                              border: Border.all(color: tierColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tierBadgeText,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tierColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        program!.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        program!.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INCLUDED DELIVERABLES',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cardTextSecondary),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: program!.features.map((feature) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.check, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(feature, style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bottom bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.cardBorder)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRICE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cardTextSecondary),
                              ),
                              Text(
                                '\$${program!.finalPrice}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          _buildButton(tierColor),
                        ],
                      ),
                    ),
                  ],
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.shield, size: 14, color: AppColors.cardTextSecondary),
            SizedBox(width: 8),
            Text('Owner View', style: TextStyle(fontSize: 12, color: AppColors.cardTextSecondary)),
          ],
        ),
      );
    }
    
    if (isSubscribed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.check, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Subscribed', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
      );
    }
    
    if (!program!.isAllowedToSubscribe) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.1),
          border: Border.all(color: AppColors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.lock, size: 14, color: AppColors.red),
            SizedBox(width: 8),
            Text('Locked', style: TextStyle(fontSize: 12, color: AppColors.red)),
          ],
        ),
      );
    }
    
    return GestureDetector(
      onTap: onSubscribe,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isSubscribing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Text('Subscribe Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}