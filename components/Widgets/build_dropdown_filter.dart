import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildFilterDropdown(
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: DropdownButtonFormField<String>(
        icon: Transform.rotate(
          angle: 270 * 3.14159 / 180,
          child: Icon(Icons.arrow_back_ios_new, size: 10),
        ),
        value: value,
        dropdownColor: AppColors.cardBackground,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }