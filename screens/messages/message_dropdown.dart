import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MessageDropdown extends StatelessWidget {
  final bool isMe;
  final VoidCallback onClose;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final Function(String) onReact;
  final VoidCallback onCopy;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;
  final bool isSelectionMode;
  final String? currentReaction;

  MessageDropdown({
    super.key,
    required this.isMe,
    required this.onClose,
    required this.onReply,
    required this.onDelete,
    required this.onReact,
    required this.onCopy,
    required this.onSelect,
    this.onEdit,
    required this.isSelectionMode,
    this.currentReaction,
  });

  final List<String> _standardEmojis = [
    "👍",
    "👎",
    "❤️",
    "😂",
    "😯",
    "😢",
    "😡",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _standardEmojis.map((emoji) {
                final isSelected = currentReaction == emoji;
                return GestureDetector(
                  onTap: () => onReact(emoji),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected ? Colors.white10 : Colors.transparent,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ),
          // Actions
          _buildMenuItem(
            icon: LucideIcons.cornerUpLeft,
            label: 'Reply',
            onTap: onReply,
          ),
          if (isMe && onEdit != null)
            _buildMenuItem(
              icon: LucideIcons.edit2,
              label: 'Edit',
              onTap: onEdit!,
            ),
          _buildMenuItem(icon: LucideIcons.copy, label: 'Copy', onTap: onCopy),
          _buildMenuItem(
            icon: LucideIcons.checkSquare,
            label: 'Select',
            onTap: onSelect,
          ),
          _buildMenuItem(
            icon: LucideIcons.trash2,
            label: 'Delete',
            onTap: onDelete,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDanger
                  ? AppColors.red
                  : AppColors.cardTextSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDanger
                    ? AppColors.red
                    : AppColors.cardTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
