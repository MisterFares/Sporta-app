import 'package:fit/models/chat/chat.dart';
import 'package:fit/screens/messages/video_player_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';

class MessageItem extends StatefulWidget {
  final ChatMessage msg;
  final String currentUserId;
  final bool isSelected;
  final int? swipingId;
  final double swipeX;
  final Function(dynamic, String) handleMessageClick;
  final Function(dynamic, int) handleOpenDropdown;
  final Function(dynamic, int) handleTouchStart;
  final Function(dynamic) handleTouchMove;
  final Function(dynamic) handleTouchEnd;
  final int? showMobileReactionsFor;
  final Function(String, String) handleReactToMessage;
  final int? activeDropdown;
  final String dropdownPosition;
  final Function(int?) setActiveDropdown;
  final Function(String) handleInitiateReply;
  final Function(List<int>) handleDeleteMessages;
  final Function(dynamic) handleCopyMessage;
  final Function(int) handleInitiateSelect;
  final Function(int) handleInitiateEdit;
  final bool isSelectionMode;
  final int selectedMessagesCount;
  final String searchQuery;
  final int currentMatchIndex;

  const MessageItem({
    super.key,
    required this.msg,
    required this.isSelected,
    required this.swipingId,
    required this.swipeX,
    required this.handleMessageClick,
    required this.handleOpenDropdown,
    required this.handleTouchStart,
    required this.handleTouchMove,
    required this.handleTouchEnd,
    required this.showMobileReactionsFor,
    required this.handleReactToMessage,
    required this.activeDropdown,
    required this.dropdownPosition,
    required this.setActiveDropdown,
    required this.handleInitiateReply,
    required this.handleDeleteMessages,
    required this.handleCopyMessage,
    required this.handleInitiateSelect,
    required this.handleInitiateEdit,
    required this.isSelectionMode,
    required this.selectedMessagesCount,
    required this.searchQuery,
    required this.currentMatchIndex,
    required this.currentUserId,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final int _initialTextChunk = 1000;
  final int _expansionChunk = 2000;
  int _expandedLength = 1000;
  OverlayEntry? _reactionOverlayEntry;
  final GlobalKey _messageKey = GlobalKey();

  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, bool> _videoInitialized = {};

  final List<Map<String, String>> _reactions = [
    {'emoji': '👍', 'label': 'Thumbs up'},
    {'emoji': '❤️', 'label': 'Heart'},
    {'emoji': '😂', 'label': 'Laugh'},
    {'emoji': '😮', 'label': 'Wow'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '🙏', 'label': 'Pray'},
  ];

  bool get _isLongText => widget.msg.content.length > _initialTextChunk;
  bool get _isFullyExpanded => _expandedLength >= widget.msg.content.length;

  String get _displayedText {
    if (_isFullyExpanded || widget.searchQuery.isNotEmpty) {
      return widget.msg.content;
    }
    if (_isLongText) {
      return '${widget.msg.content.substring(0, _expandedLength)}...';
    }
    return widget.msg.content;
  }

  @override
  void dispose() {
    _removeReactionOverlay();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _removeReactionOverlay() {
    if (_reactionOverlayEntry != null && _reactionOverlayEntry!.mounted) {
      _reactionOverlayEntry!.remove();
      _reactionOverlayEntry = null;
    }
  }

  void _showReactionPickerOverlay() {
    if (widget.isSelectionMode) return;

    final RenderBox? renderBox =
        _messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _reactionOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _removeReactionOverlay(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: position.dy - 50,
            left: (position.dx + (size.width / 2) - 150).clamp(
              8,
              MediaQuery.of(context).size.width - 308,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _reactions.map((reaction) {
                    return GestureDetector(
                      onTap: () {
                        widget.handleReactToMessage(
                          widget.msg.id,
                          reaction['emoji']!,
                        );
                        _removeReactionOverlay();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          reaction['emoji']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_reactionOverlayEntry!);
  }

  void _handleLongPress() {
    if (!widget.isSelectionMode) {
      _showReactionPickerOverlay();
    }
  }

  List<Widget> _renderHighlightedText() {
    if (widget.searchQuery.isEmpty) {
      return [
        Text(
          _displayedText,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: widget.msg.isMine ? Colors.black : AppColors.textPrimary,
          ),
        ),
      ];
    }
    final parts = _displayedText.split(
      RegExp('(${RegExp.escape(widget.searchQuery)})', caseSensitive: false),
    );
    final List<InlineSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              backgroundColor: AppColors.primary,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: parts[i]));
      }
    }
    return [
      RichText(
        text: TextSpan(
          children: spans,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: widget.msg.isMine
                ? AppColors.textPrimary
                : AppColors.primary,
          ),
        ),
      ),
    ];
  }

  Future<Uint8List?> _getVideoThumbnail(String videoUrl) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 50,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  String _getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final isSelected = widget.isSelected;
    final hasAttachment = msg.attachment != null && msg.attachment!.isNotEmpty;
    final fileExtension = hasAttachment
        ? _getFileExtension(msg.attachment!)
        : '';
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ].contains(fileExtension);
    final isVideo = [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
    ].contains(fileExtension);
    final fullAttachmentUrl = hasAttachment
        ? ImageUrlHelper.getFullImageUrl(msg.attachment)
        : null;

    final messageWidget = Container(
      key: _messageKey,
      margin: EdgeInsets.only(bottom: msg.reactions.isNotEmpty ? 16 : 8),
      child: Column(
        crossAxisAlignment: msg.isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: GestureDetector(
                  onLongPress: _handleLongPress,
                  onTap: () => widget.handleMessageClick(null, msg.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMine
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
                        bottomRight: Radius.circular(msg.isMine ? 4 : 16),
                      ),
                      border: msg.isMine
                          ? null
                          : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.parentMessageId != null &&
                            msg.parentMessageId!.isNotEmpty)
                          _buildReplyPreview(msg, msg.isMine),
                        if (hasAttachment)
                          _buildAttachment(
                            fullAttachmentUrl!,
                            isImage,
                            isVideo,
                            fileExtension,
                          ),
                        if (msg.content.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._renderHighlightedText(),
                              if (_isLongText && widget.searchQuery.isEmpty)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (_isFullyExpanded) {
                                      _expandedLength = _initialTextChunk;
                                    } else {
                                      _expandedLength += _expansionChunk;
                                    }
                                  }),
                                  child: Text(
                                    _isFullyExpanded
                                        ? 'Show less'
                                        : 'Read more',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: msg.isMine
                                          ? Colors.black54
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.formattedTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: msg.isMine
                                    ? Colors.black54
                                    : AppColors.cardTextSecondary,
                              ),
                            ),
                            if (msg.isMine && msg.isRead != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  msg.isRead == true
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 14,
                                  color: msg.isRead == true
                                      ? const Color(0xFF3b82f6)
                                      : Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Display all reactions
          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...msg.reactions.map((reaction) {
                  final isMyReaction = reaction.userId == widget.currentUserId;
                  return GestureDetector(
                    onTap: () =>
                        widget.handleReactToMessage(msg.id, reaction.emoji),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        reaction.emoji,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMyReaction
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => _showReactionPickerOverlay(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.isSelectionMode) {
      return Container(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        child: messageWidget,
      );
    }

    return Slidable(
      key: ValueKey('slidable_${msg.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) => widget.handleInitiateReply(msg.id),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            icon: Icons.reply,
            label: 'Reply',
          ),
        ],
      ),
      child: messageWidget,
    );
  }

  Widget _buildAttachment(
    String url,
    bool isImage,
    bool isVideo,
    String extension,
  ) {
    // Check if it's a local file (still uploading)
    final isLocalFile = url.startsWith('/') || url.startsWith('file://');

    if (isLocalFile && isImage) {
      return Container(
        width: 200,
        height: 150,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Uploading...',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Video attachment
    if (isVideo) {
      return GestureDetector(
        onTap: () => _showVideoDialog(url),
        child: Container(
          width: 200,
          height: 150,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video thumbnail (first frame)
              FutureBuilder(
                future: _getVideoThumbnail(url),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  }
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[800],
                  );
                },
              ),
              // Play button overlay
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    extension.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Document attachment
    if (!isImage && !isVideo) {
      final fileName = url.split('/').last;
      return GestureDetector(
        onTap: () => _showDownloadDialog(url, fileName),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, size: 32, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName.length > 20
                          ? '${fileName.substring(0, 20)}...'
                          : fileName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to download',
                      style: TextStyle(
                        color: AppColors.cardTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Image attachment
    return GestureDetector(
      onTap: () => _showImageDialog(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog(String url, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Download File'),
        content: Text('Do you want to download "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to open file'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ChatMessage msg, bool isMe) {
    if (msg.parentMessageId == null || msg.parentMessageId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isMe ? Colors.black12 : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.black : AppColors.primary,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.parentMessageSender ?? 'Reply to message',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.black : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg.parentMessageContent ?? 'Original message',
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe
                          ? Colors.black87
                          : AppColors.cardTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showVideoDialog(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }
}
