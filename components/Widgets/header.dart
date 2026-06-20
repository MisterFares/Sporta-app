import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget pageHeader(String description) {
  return Text(
    description,
    style: TextStyle(
      color: AppColors.textSecondary,
    ),
  );
}