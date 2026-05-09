import 'package:fit/components/Widgets/build_filter_chip.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildFilters(List filters, String selectedFilter, Function(String) onFilterSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      border: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = selectedFilter == filter.id;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BuildFilterChip(
              filter: filter,
              isActive: isActive,
              onFilterSelected: onFilterSelected,
            ),
          );
        }).toList(),
      ),
    ),
  );
}