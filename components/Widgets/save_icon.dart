import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget saveIcon(bool isSaving, bool saveSuccess, VoidCallback onPressed) {
  return IconButton(
    onPressed: onPressed,
    icon: isSaving
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            saveSuccess ? Icons.check : Icons.save,
            color: AppColors.primary,
          ),
  );
}
