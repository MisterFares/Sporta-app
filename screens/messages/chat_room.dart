// screens/chat_room.dart
import 'dart:io';

import 'package:fit/models/chat/chat.dart';
import 'package:fit/screens/messages/chat_header.dart';
import 'package:fit/screens/messages/chat_input.dart';
import 'package:fit/screens/messages/message_item.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;
  final VoidCallback onBack;

  const ChatRoom({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.onBack,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  List<ChatMessage> _messages = [];
  String _inputValue = "";
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  ChatMessage? _editingMessage;
  ChatMessage? _replyingTo;
  bool _isSelectionMode = false;
  bool _isSearchMode = false;
  String _searchQuery = "";
  String _currentUserId = '';
  int _currentMatchIndex = 0;
  final List<String> _selectedMessageIds = [];
  final ScrollController _scrollController = ScrollController();

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageFocusNode.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      _loadMoreMessages();
    }
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> _loadMessages({bool reset = true}) async {
    print("🔴 OTHER USER ID: ${widget.userId}");
    print("🔴 IS EMPTY? ${widget.userId.isEmpty}");
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _messages = [];
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.getChatHistory(
        otherUserId: widget.userId,
        pageNumber: reset ? 1 : _currentPage + 1,
        pageSize: 20,
      );

      setState(() {
        if (reset) {
          _messages = response.items.reversed.toList();
        } else {
          _messages.insertAll(0, response.items.reversed.toList());
        }
        _currentPage = response.currentPage;
        _totalPages = response.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (reset) {
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    await _loadMessages(reset: false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({File? attachment}) async {
    if (_editingMessage != null) {
      await _updateMessage();
      return;
    }

    if (_inputValue.trim().isEmpty && attachment == null) return;

    final String contentToSend = _inputValue.trim();
    final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final replyingToMessage = _replyingTo;

    setState(() {
      _replyingTo = null;
    });

    final tempMessage = ChatMessage(
      id: tempId,
      senderId: _currentUserId,
      senderName: 'You',
      senderAvatar: null,
      receiverId: widget.userId,
      receiverName: widget.userName,
      receiverAvatar: widget.userAvatar,
      content: contentToSend,
      attachment: attachment?.path,
      parentMessageId: replyingToMessage?.id,
      parentMessageContent: replyingToMessage?.content,
      parentMessageSender: replyingToMessage?.senderName,
      createdAt: DateTime.now(),
      formattedTime: _formatTime(DateTime.now()),
      isRead: false,
      isMine: true,
      reactions: [],
    );

    setState(() {
      _messages.add(tempMessage);
      _inputValue = "";
      _inputController.clear();
    });
    _scrollToBottom();

    final result = await ApiService.sendMessage(
      receiverId: widget.userId,
      content: contentToSend,
      parentMessageId: replyingToMessage?.id,
      attachment: attachment,
    );

    if (result['success']) {
      // Message sent successfully, no need to do anything - temp message is already showing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Remove temp message on error
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateMessage() async {
    if (_inputValue.trim().isEmpty || _editingMessage == null) return;

    final oldMessageId = _editingMessage!.id;
    final newContent = _inputValue.trim();

    // Update UI immediately (optimistic update)
    setState(() {
      final index = _messages.indexWhere((m) => m.id == oldMessageId);
      if (index != -1) {
        _messages[index].content = newContent;
      }
      _editingMessage = null;
      _inputValue = "";
      _inputController.clear();
    });

    // Call API in background
    final result = await ApiService.editMessage(
      messageId: oldMessageId,
      content: newContent,
    );

    if (!result['success']) {
      // Revert on error
      setState(() {
        final index = _messages.indexWhere((m) => m.id == oldMessageId);
        if (index != -1) {
          _messages[index].content = _editingMessage?.content ?? newContent;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
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

    // Remove from UI immediately
    setState(() {
      _messages.removeWhere((m) => m.id == messageId);
    });

    // Call API in background
    final result = await ApiService.deleteMessage(messageId: messageId);

    if (!result['success']) {
      // If fails, reload to restore the message
      await _loadMessages(reset: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    if (_currentUserId.isEmpty) return;

    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    // Check if user already has this reaction
    final existingReaction = _messages[index].reactions.firstWhere(
      (r) => r.userId == _currentUserId,
      orElse: () => Reaction(userId: '', emoji: ''),
    );

    final bool isRemoving = existingReaction.emoji == emoji;

    // Update UI immediately
    setState(() {
      final updatedReactions = List<Reaction>.from(_messages[index].reactions);
      if (isRemoving) {
        updatedReactions.removeWhere((r) => r.userId == _currentUserId);
      } else {
        updatedReactions.removeWhere((r) => r.userId == _currentUserId);
        updatedReactions.add(Reaction(userId: _currentUserId, emoji: emoji));
      }
      _messages[index].reactions = updatedReactions;
    });

    // Call API (the same endpoint toggles)
    final result = await ApiService.addMessageReaction(
      messageId: messageId,
      emoji: emoji,
    );

    if (!result['success']) {
      // Revert on error
      setState(() {
        final updatedReactions = List<Reaction>.from(
          _messages[index].reactions,
        );
        if (isRemoving) {
          updatedReactions.add(Reaction(userId: _currentUserId, emoji: emoji));
        } else {
          updatedReactions.removeWhere((r) => r.userId == _currentUserId);
        }
        _messages[index].reactions = updatedReactions;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _clearChat() async {
    print("🔴 STEP 1: _clearChat called");

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    print("🔴 STEP 2: confirm = $confirm");

    if (confirm != true) {
      print("🔴 STEP 3: User cancelled");
      return;
    }

    print("🔴 STEP 4: Showing loading dialog");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    print("🔴 STEP 5: Calling API");
    final result = await ApiService.deleteChatHistory(
      otherUserId: widget.userId,
    );
    print("🔴 STEP 6: API result = $result");

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result['success']) {
      print("🔴 STEP 7: Clearing messages");
      setState(() {
        _messages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("🔴 STEP 8: API failed - ${result['message']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _handleReplyToMessage(String messageId) {
    final message = _messages.firstWhere((msg) => msg.id == messageId);
    setState(() {
      _replyingTo = message;
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
    _messageFocusNode.requestFocus();
  }

  void _clearReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _startEditing(ChatMessage message) {
    if (!message.isMine) return;

    setState(() {
      _editingMessage = message;
      _inputValue = message.content;
      _inputController.text = message.content;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _inputValue = "";
      _inputController.clear();
    });
  }

  void _deleteSelectedMessages() async {
    for (var id in _selectedMessageIds) {
      await _deleteMessage(id);
    }
    setState(() {
      _selectedMessageIds.clear();
      _isSelectionMode = false;
    });
  }

  void _copySelectedMessages() {
    final texts = _selectedMessageIds
        .map((id) => _messages.firstWhere((m) => m.id == id).content)
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: texts));
    setState(() {
      _selectedMessageIds.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Messages copied'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'pm' : 'am'}";
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingTo!.isMine ? "yourself" : widget.userName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.content.length > 50
                      ? '${_replyingTo!.content.substring(0, 50)}...'
                      : _replyingTo!.content,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReply,
            icon: Icon(Icons.close, size: 18, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingPreview() {
    if (_editingMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _editingMessage!.content.length > 50
                      ? '${_editingMessage!.content.substring(0, 50)}...'
                      : _editingMessage!.content,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _cancelEditing,
            icon: Icon(Icons.close, size: 18, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalMatches = 0;
    for (var msg in _messages) {
      if (_searchQuery.isNotEmpty &&
          msg.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
        totalMatches++;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          ChatHeader(
            userName: widget.userName,
            userAvatar: widget.userAvatar,
            onBack: widget.onBack,
            onClearChat: () => _clearChat(),
            onDeleteChat: () async {
              await ApiService.deleteConversation(otherUserId: widget.userId);
              widget.onBack();
            },
            onSelectMode: () => setState(() => _isSelectionMode = true),
            onSearchMode: () => setState(() => _isSearchMode = true),
            isSearchMode: _isSearchMode,
            searchQuery: _searchQuery,
            setSearchQuery: (q) => setState(() => _searchQuery = q),
            onCloseSearch: () => setState(() {
              _isSearchMode = false;
              _searchQuery = "";
            }),
            matchCount: totalMatches,
            currentMatchIndex: _currentMatchIndex,
            onNextMatch: () => setState(
              () =>
                  _currentMatchIndex = (_currentMatchIndex % totalMatches) + 1,
            ),
            onPrevMatch: () => setState(
              () => _currentMatchIndex = _currentMatchIndex > 1
                  ? _currentMatchIndex - 1
                  : totalMatches,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _errorMessage != null
                ? _buildErrorState()
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: AppColors.cardTextSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoadingMore) {
                        return Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final msg = _messages[index];
                      return MessageItem(
                        msg: msg,
                        currentUserId: _currentUserId,
                        isSelected: _selectedMessageIds.contains(msg.id),
                        swipingId: null,
                        swipeX: 0,
                        handleMessageClick: (_, __) {
                          if (_isSelectionMode ||
                              _selectedMessageIds.isNotEmpty) {
                            setState(() {
                              if (_selectedMessageIds.contains(msg.id)) {
                                _selectedMessageIds.remove(msg.id);
                              } else {
                                _selectedMessageIds.add(msg.id);
                              }
                            });
                          }
                        },
                        handleOpenDropdown: (_, __) {},
                        handleTouchStart: (_, __) {},
                        handleTouchMove: (_) {},
                        handleTouchEnd: (_) {},
                        showMobileReactionsFor: null,
                        handleReactToMessage: (id, emoji) =>
                            _addReaction(msg.id, emoji),
                        activeDropdown: null,
                        dropdownPosition: 'down',
                        setActiveDropdown: (_) {},
                        handleInitiateReply: (id) =>
                            _handleReplyToMessage(msg.id),
                        handleDeleteMessages: (ids) => _deleteMessage(msg.id),
                        handleCopyMessage: (_) {},
                        handleInitiateSelect: (id) {},
                        handleInitiateEdit: (id) =>
                            msg.isMine ? _startEditing(msg) : null,
                        isSelectionMode: _isSelectionMode,
                        selectedMessagesCount: _selectedMessageIds.length,
                        searchQuery: _searchQuery,
                        currentMatchIndex: _currentMatchIndex,
                      );
                    },
                  ),
          ),
          if (_isSelectionMode || _selectedMessageIds.isNotEmpty)
            _buildSelectionBar()
          else
            Column(
              children: [
                if (_editingMessage != null) _buildEditingPreview(),
                if (_replyingTo != null && _editingMessage == null)
                  _buildReplyPreview(),
                ChatInput(
                  value: _inputValue,
                  onChange: (v) => setState(() => _inputValue = v),
                  onSend: (attachment) => _sendMessage(attachment: attachment),
                  editMsg: _editingMessage,
                  controller: _inputController,
                  focusNode: _messageFocusNode,
                ),
                const SizedBox(height: 40),
              ],
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
            onPressed: () => _loadMessages(reset: true),
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

  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (_selectedMessageIds.length == 1)
            IconButton(
              onPressed: () {
                final msg = _messages.firstWhere(
                  (m) => m.id == _selectedMessageIds.first,
                );
                if (msg.isMine) {
                  _startEditing(msg);
                }
                setState(() {
                  _isSelectionMode = false;
                  _selectedMessageIds.clear();
                });
              },
              icon: Icon(
                LucideIcons.edit2,
                size: 22,
                color: AppColors.cardTextSecondary,
              ),
            ),
          IconButton(
            onPressed: _copySelectedMessages,
            icon: Icon(
              LucideIcons.copy,
              size: 22,
              color: AppColors.cardTextSecondary,
            ),
          ),
          IconButton(
            onPressed: _deleteSelectedMessages,
            icon: Icon(LucideIcons.trash2, size: 22, color: AppColors.red),
          ),
        ],
      ),
    );
  }
}
