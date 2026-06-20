import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatAttachmentMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onSelectMedia;
  final VoidCallback onSelectDoc;

  const ChatAttachmentMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onSelectMedia,
    required this.onSelectDoc,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Positioned(
      bottom: 65,
      left: 8,
      child: Row(
        children: [
          Expanded(
            child: _buildMenuItem(
              icon: LucideIcons.image,
              label: 'Photos & Videos',
              color: const Color(0xFF3b82f6),
              onTap: () {
                onClose();
                onSelectMedia();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildMenuItem(
              icon: LucideIcons.fileText,
              label: 'Document',
              color: const Color(0xFF8b5cf6),
              onTap: () {
                onClose();
                onSelectDoc();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
