import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildIcon(IconData iconData) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Icon(
        iconData,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }
