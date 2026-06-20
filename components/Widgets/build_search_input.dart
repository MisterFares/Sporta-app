import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildSearchInput(
  TextEditingController searchController,
  Function onChanged,
  String hintText,
) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: searchController,
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: Icon(
          Icons.search_outlined,
          size: 18,
          color: AppColors.cardTextSecondary,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: (value) {
        // Implement search functionality
        onChanged(value);
      },
    ),
  );
}
