// ignore_for_file: non_constant_identifier_names

import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget MyAppBar({required String title, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    actions: actions,
  );
}
