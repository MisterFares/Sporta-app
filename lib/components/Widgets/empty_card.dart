import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildEmptyCard({
  required IconData icon,
  required String title,
  required String description,
  required String buttonText,
  required bool isPrimary,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 58),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.cardBorder,
        width: 1,
        style: BorderStyle.solid,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Icon Circle
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F0E),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Icon(icon, size: 28, color: AppColors.cardTextSecondary),
        ),

        const SizedBox(height: 20),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 25),

        /// Button
        isPrimary
            ? buildButton(buttonText, null, () {
                // Handle button press
              }, true)
            : buildButton(buttonText, null, () {
                // Handle button press
              }, false),
      ],
    ),
  );
}
