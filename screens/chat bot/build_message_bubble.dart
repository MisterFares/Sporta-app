import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fit/models/bot/chat_message.dart';
import 'package:fit/styles/colors.dart';

Widget buildMessageBubble(ChatMessage message, BuildContext context) {
  final isUser = message.isUser;

  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.cardBorder,
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('h:mm a').format(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}