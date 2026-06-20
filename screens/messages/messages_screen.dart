// screens/messages_screen.dart
import 'package:fit/models/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'chat_room.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatInboxItem> _chats = [];
  String _search = "";
  String? _activeUserId;
  final List<String> _selectedChatIds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getInbox(
        searchTerm: _search.isEmpty ? null : _search,
      );
      print("🔴 INBOX ITEMS: ${response.items.length}");
      for (var item in response.items) {
        print(
          "🔴 User: ${item.userName}, Avatar: ${item.userAvatar}, Last Message: ${item.lastMessage}",
        );
      }
      setState(() {
        _chats = response.items;
        _isLoading = false;
      });
    } catch (e) {
      print("🔴 ERROR: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConversation(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ApiService.deleteConversation(otherUserId: userId);

    if (result['success']) {
      await _loadInbox();
      if (_activeUserId == userId) {
        setState(() => _activeUserId = null);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleBlockUser(String userId, bool isBlocked) async {
    final result = await ApiService.toggleBlockUser(blockedUserId: userId);

    if (result['success']) {
      await _loadInbox();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['isBlocked'] ? 'User blocked' : 'User unblocked',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markMessagesAsRead(String userId) async {
    await ApiService.markMessagesAsRead(otherUserId: userId);
  }

  void _handleDeleteChats(List<String> chatIds) {
    for (var id in chatIds) {
      _deleteConversation(id);
    }
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _handleBlockUsers(List<String> chatIds) {
    for (var id in chatIds) {
      final chat = _chats.firstWhere((c) => c.userId == id);
      _toggleBlockUser(id, !chat.isBlocked);
    }
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _handleChatClick(String userId) {
    print("🔴 CHAT CLICK - UserId: $userId");
    print(
      "🔴 CHAT CLICK - UserName: ${_chats.firstWhere((c) => c.userId == userId).userName}",
    );
    if (_selectedChatIds.isNotEmpty) {
      setState(() {
        if (_selectedChatIds.contains(userId)) {
          _selectedChatIds.remove(userId);
        } else {
          _selectedChatIds.add(userId);
        }
      });
    } else {
      final isMobile = MediaQuery.of(context).size.width < 768;

      // Mark messages as read when opening chat
      _markMessagesAsRead(userId);

      if (isMobile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoom(
              userId: userId,
              userName: _chats.firstWhere((c) => c.userId == userId).userName,
              userAvatar: _chats
                  .firstWhere((c) => c.userId == userId)
                  .userAvatar,
              onBack: () {
                Navigator.pop(context);
                _loadInbox();
                setState(() => _activeUserId = null);
              },
            ),
          ),
        );
      } else {
        setState(() {
          _activeUserId = userId;
        });
      }
    }
  }

  void _handleLongPress(String userId) {
    setState(() {
      if (!_selectedChatIds.contains(userId)) {
        _selectedChatIds.add(userId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedChatIds.clear();
    });
  }

  List<ChatInboxItem> get _filteredChats {
    if (_search.isEmpty) return _chats;
    return _chats
        .where(
          (chat) => chat.userName.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _filteredChats;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: MyAppBar(title: 'Messages', drawerIcon: Icons.menu),
      drawer: AppDrawer(selectedIndex: 6, role: 'trainee'),
      body: Row(
        children: [
          if (!isMobile || _activeUserId == null)
            Container(
              width: isMobile ? MediaQuery.of(context).size.width : 350,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Column(
                children: [
                  if (_selectedChatIds.isNotEmpty)
                    _buildSelectionHeader()
                  else
                    _buildSearchBar(),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _errorMessage != null
                        ? _buildErrorState()
                        : filteredChats.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: filteredChats.length,
                            itemBuilder: (context, index) {
                              final chat = filteredChats[index];
                              return _buildChatListItem(chat);
                            },
                          ),
                  ),
                ],
              ),
            ),
          if (!isMobile || _activeUserId != null)
            Expanded(
              child: _activeUserId != null
                  ? ChatRoom(
                      userId: _activeUserId!,
                      userName: _chats
                          .firstWhere((c) => c.userId == _activeUserId)
                          .userName,
                      userAvatar: _chats
                          .firstWhere((c) => c.userId == _activeUserId)
                          .userAvatar,
                      onBack: () => setState(() => _activeUserId = null),
                    )
                  : _buildPlaceholder(),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Failed to load messages',
            style: TextStyle(color: AppColors.cardTextSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInbox,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _clearSelection,
            icon: Icon(
              Icons.arrow_back,
              size: 22,
              color: AppColors.cardTextSecondary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${_selectedChatIds.length}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _handleDeleteChats(_selectedChatIds);
                  break;
                case 'block':
                  _handleBlockUsers(_selectedChatIds);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(LucideIcons.ban, size: 16, color: AppColors.red),
                    SizedBox(width: 12),
                    Text('Block', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: AppColors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              LucideIcons.moreVertical,
              size: 22,
              color: AppColors.cardTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        style: TextStyle(color: AppColors.textPrimary),
        onChanged: (value) {
          setState(() => _search = value);
          _loadInbox();
        },
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: AppColors.cardTextSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 16,
            color: AppColors.cardTextSecondary,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildChatListItem(ChatInboxItem chat) {
    final isSelected = _selectedChatIds.contains(chat.userId);
    final hasUnread = chat.unreadCount > 0;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final avatarUrl = ImageUrlHelper.getFullImageUrl(chat.userAvatar);

    return GestureDetector(
      onLongPress: () => _handleLongPress(chat.userId),
      child: Container(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        child: isMobile
            ? ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: () => _handleChatClick(chat.userId),
                leading: _buildAvatar(chat.userName, avatarUrl),
                title: Text(
                  chat.userName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      Icons.message,
                      size: 12,
                      color: hasUnread
                          ? AppColors.textPrimary
                          : AppColors.cardTextSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        chat.lastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasUnread
                              ? AppColors.textPrimary
                              : AppColors.cardTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: hasUnread
                            ? AppColors.primary
                            : AppColors.cardTextSecondary,
                      ),
                    ),
                    if (chat.unreadCount > 0)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Slidable(
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  extentRatio: 0.3,
                  children: [
                    SlidableAction(
                      onPressed: (context) => _deleteConversation(chat.userId),
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.textPrimary,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  onTap: () => _handleChatClick(chat.userId),
                  leading: _buildAvatar(chat.userName, avatarUrl),
                  title: Text(
                    chat.userName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.message,
                        size: 12,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.cardTextSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.cardTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat.formattedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.cardTextSecondary,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      backgroundColor: Color(0xFF1A221F),
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFF8B949E)),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(color: AppColors.cardTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Sporta Chat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a conversation to start messaging',
            style: TextStyle(fontSize: 14, color: AppColors.cardTextSecondary),
          ),
        ],
      ),
    );
  }
}
