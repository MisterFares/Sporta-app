import 'package:fit/models/coach/program_model.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget buildProgramsSection(
  List<ProgramData> filteredPrograms,
  VoidCallback onCreateProgram,
  Function(ProgramData) onEditProgram,
  Function(String) onDeleteProgram, // Change int to String
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Active Programs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${filteredPrograms.length} Live',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 170,
            child: buildButton(
              'Create New Program',
              Icon(LucideIcons.plus, color: Colors.black),
              onCreateProgram,
              true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      if (filteredPrograms.isEmpty)
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.package,
                size: 48,
                color: AppColors.cardTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No programs found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click "Create New Program" to get started',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cardTextSecondary,
                ),
              ),
            ],
          ),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.1,
          ),
          itemCount: filteredPrograms.length,
          itemBuilder: (context, index) => buildProgramCard(
            filteredPrograms[index],
            onEditProgram,
            onDeleteProgram,
          ),
        ),
      if (filteredPrograms.isEmpty) const SizedBox(height: 8),
    ],
  );
}

Widget buildProgramCard(
  ProgramData prog,
  Function(ProgramData) onEditProgram,
  Function(String) onDeleteProgram, // Change int to String
) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    prog.thumbnailImage != null &&
                        prog.thumbnailImage!.isNotEmpty
                    ? Image.network(
                        prog.thumbnailImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.cardBackground,
                          child: Icon(
                            LucideIcons.image,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppColors.cardBackground,
                        child: Icon(
                          LucideIcons.dumbbell,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prog.status == 'Published'
                      ? AppColors.primary.withOpacity(0.08)
                      : const Color(0xFF484F58).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  prog.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: prog.status == 'Published'
                        ? AppColors.primary
                        : AppColors.cardTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prog.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    LucideIcons.target,
                    size: 14,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      prog.serviceType == 'WorkoutOnly'
                          ? 'Workout'
                          : prog.serviceType == 'NutritionOnly'
                          ? 'Nutrition'
                          : 'Workout + Nutrition',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.cardTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${prog.durationInWeeks} Weeks',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          Row(
            children: [
              buildStatBox('Sales', _formatNumber(prog.totalSales)),
              const Spacer(),
              buildStatBox('Revenue', _formatCurrency(prog.netRevenue.toInt())),
              const Spacer(),
              buildStatBox('Users', _formatNumber(prog.activeUsers)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prog.discount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '\$${prog.basePrice.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cardTextSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  Text(
                    '\$${((prog.basePrice * (1 - prog.discount / 100)).toInt())}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  buildActionButton(
                    LucideIcons.edit3,
                    () => onEditProgram(prog),
                  ),
                  const SizedBox(width: 8),
                  buildActionButton(
                    LucideIcons.trash2,
                    () => onDeleteProgram(prog.id),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildStatBox(String label, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.cardTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget buildActionButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, size: 18, color: AppColors.cardTextSecondary),
    ),
  );
}

// Helper formatting functions
String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

String _formatCurrency(int amount) {
  if (amount >= 1000000) {
    return '\$${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '\$$amount';
}
