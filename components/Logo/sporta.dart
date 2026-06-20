import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget sportaLogo() {
  return Row(
    children: [
      Text(
        "SPORTA",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        ".",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 22,
          color: AppColors.primary,
        ),
      ),
    ],
  );
}
