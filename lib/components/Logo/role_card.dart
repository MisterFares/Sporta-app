import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildRoleCard({
  required String role,
  required String? selectedRole,
  required IconData icon,
  required String title,
  required String description,
  required List<String> benefits,
}) {

  final bool isSelected = selectedRole == role;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.cardBorder,
        width: 1.5,
      ),
      boxShadow: [
        if (isSelected)
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
          ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 40, color: AppColors.primary),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(
            color: AppColors.cardTextSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        // Benefits List
        ...benefits.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}