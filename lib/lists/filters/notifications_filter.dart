// ignore_for_file: non_constant_identifier_names

import 'package:fit/classes/filter_option.dart';
import 'package:flutter/material.dart';

final List<FilterOption> NotificationsFilters = [
  FilterOption(id: 'all', label: 'All', icon: Icons.grid_view_outlined),
  FilterOption(id: 'training', label: 'Training', icon: Icons.fitness_center_outlined),
  FilterOption(id: 'social', label: 'Social', icon: Icons.group),
  FilterOption(id: 'coach', label: 'Coach', icon: Icons.person_2_outlined),
  FilterOption(id: 'store', label: 'Store', icon: Icons.shopping_bag_outlined),
  FilterOption(
    id: 'system',
    label: 'System',
    icon: Icons.settings,
  ),
];
