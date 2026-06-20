import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatHeader extends StatelessWidget {
  final String userName;
  final String? userAvatar;
  final VoidCallback onBack;
  final VoidCallback onClearChat;
  final VoidCallback onDeleteChat;
  final VoidCallback onSelectMode;
  final VoidCallback onSearchMode;
  final bool isSearchMode;
  final String searchQuery;
  final Function(String) setSearchQuery;
  final VoidCallback onCloseSearch;
  final int matchCount;
  final int currentMatchIndex;
  final VoidCallback onNextMatch;
  final VoidCallback onPrevMatch;
  final bool? isOnline; // Optional for now

  const ChatHeader({
    super.key,
    required this.userName,
    this.userAvatar,
    required this.onBack,
    required this.onClearChat,
    required this.onDeleteChat,
    required this.onSelectMode,
    required this.onSearchMode,
    required this.isSearchMode,
    required this.searchQuery,
    required this.setSearchQuery,
    required this.onCloseSearch,
    required this.matchCount,
    required this.currentMatchIndex,
    required this.onNextMatch,
    required this.onPrevMatch,
    this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearchMode) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onCloseSearch,
              icon: Icon(
                Icons.arrow_back,
                size: 22,
                color: AppColors.cardTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                autofocus: true,
                style: TextStyle(color: AppColors.textPrimary),
                onChanged: setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search in chat...',
                  hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              Row(
                children: [
                  Text(
                    '${currentMatchIndex > 0 ? currentMatchIndex : 0} of $matchCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: matchCount > 0 ? onPrevMatch : null,
                    icon: Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: matchCount > 0 ? onNextMatch : null,
                    icon: Icon(
                      Icons.arrow_downward,
                      size: 18,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setSearchQuery(''),
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    final avatarUrl = ImageUrlHelper.getFullImageUrl(userAvatar);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          // Back button for mobile
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              size: 22,
              color: AppColors.cardTextSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: const Color(0xFF1A221F),
                child: avatarUrl == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (isOnline == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.cardBackground, width: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Name and status
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isOnline == true ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cardTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          IconButton(
            onPressed: onSearchMode,
            icon: Icon(
              LucideIcons.search,
              size: 20,
              color: AppColors.cardTextSecondary,
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'search',
                child: Text('Search'),
              ),
              const PopupMenuItem(
                value: 'select',
                child: Text('Select'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete chat', style: TextStyle(color: Colors.red)),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block', style: TextStyle(color: Colors.red)),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'search':
                  onSearchMode();
                  break;
                case 'select':
                  onSelectMode();
                  break;
                case 'clear':
                  onClearChat();
                  break;
                case 'delete':
                  onDeleteChat();
                  break;
                case 'block':
                  onClearChat(); // You can implement block logic here
                  break;
                case 'report':
                  break;
              }
            },
            child: Icon(
              LucideIcons.moreVertical,
              size: 20,
              color: AppColors.cardTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}