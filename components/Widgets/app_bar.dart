// ignore_for_file: non_constant_identifier_names

import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget MyAppBar({
  required String title,
  List<Widget>? actions,
  IconData? drawerIcon, // Add this parameter
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(
          drawerIcon ?? Icons.menu, // Use custom icon or default menu
          color: AppColors.textPrimary,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    actions: actions,
  );
}
