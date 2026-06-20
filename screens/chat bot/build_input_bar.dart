import 'package:flutter/material.dart';
import 'package:fit/styles/colors.dart';

Widget buildInputBar({
  required TextEditingController controller,
  required VoidCallback onSend,
  required bool isLoading,
  required bool isProcessing,
  String hintText = 'Type your message...',
}) {
  final bool isDisabled = isLoading || isProcessing;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border(top: BorderSide(color: AppColors.cardBorder)),
    ),
    child: SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: AppColors.textPrimary),
              maxLines: null,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isDisabled ? AppColors.textSecondary : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isDisabled ? null : onSend,
              icon: Icon(
                Icons.send,
                color: isDisabled ? AppColors.textSecondary : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}