// In your buildInput widget, add these parameters:
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildInput(
  String? label,
  String? hint, {
  bool obscure = false,
  TextEditingController? controller,
  Function(String)? onChanged,
  VoidCallback? onSuffixIconPressed,
  IconData? suffixIcon,
  bool showSuffixIcon = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
      ],
      TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          suffixIcon: showSuffixIcon
              ? IconButton(
                  icon: Icon(
                    suffixIcon ?? Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onSuffixIconPressed,
                )
              : null,
        ),
      ),
    ],
  );
}
