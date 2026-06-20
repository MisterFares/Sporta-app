import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget S() {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: const Text(
      "S",
      style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F1115)),
    ),
  );
}
