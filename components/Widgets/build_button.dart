import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildButton(
  String text,
  Icon? icon,
  VoidCallback onPressed,
  bool isPrimary,
) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.transparent,
        foregroundColor: isPrimary ? Colors.black : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: isPrimary ? Colors.transparent : AppColors.cardBorder,
        ),
      ),
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(text, style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            )
          : Text(text, style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
