class SendMessageRequest {
  final String receiverId;
  final String content;
  final String? parentMessageId;
  final String? attachment;

  SendMessageRequest({
    required this.receiverId,
    required this.content,
    this.parentMessageId,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'content': content,
      if (parentMessageId != null) 'parentMessageId': parentMessageId,
      if (attachment != null) 'attachment': attachment,
    };
  }
}

class Reaction {
  final String userId;
  final String emoji;

  Reaction({required this.userId, required this.emoji});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      userId: json['userId']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  String content;
  final String? attachment;
  final String? parentMessageId;
  final String? parentMessageContent;
  final String? parentMessageSender;
  final DateTime createdAt;
  final String formattedTime;
  final bool isRead;
  final bool isMine;
  List<Reaction> reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.content,
    this.attachment,
    this.parentMessageId,
    required this.createdAt,
    required this.formattedTime,
    required this.isRead,
    required this.isMine,
    required this.reactions,
    this.parentMessageContent,
    this.parentMessageSender,
  });

  String? getMyReaction(String currentUserId) {
    final myReaction = reactions.firstWhere(
      (r) => r.userId == currentUserId,
      orElse: () => Reaction(userId: '', emoji: ''),
    );
    return myReaction.emoji.isNotEmpty ? myReaction.emoji : null;
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final senderId = json['senderId']?.toString() ?? '';
    final reactionsList = json['reactions'] as List<dynamic>? ?? [];

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: senderId,
      senderName: json['senderName']?.toString() ?? '',
      senderAvatar: json['senderAvatar']?.toString(),
      receiverId: json['receiverId']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      receiverAvatar: json['receiverAvatar']?.toString(),
      content: json['content']?.toString() ?? '',
      attachment: json['attachmentUrl']?.toString(),
      parentMessageId: json['parentMessageId']?.toString(),
      parentMessageContent: json['parentMessageContent']?.toString(),
      parentMessageSender: json['parentMessageSender']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      formattedTime: json['formattedTime']?.toString() ?? '',
      isRead: json['isRead'] == true || json['isRead'] == 'true',
      isMine: senderId == currentUserId,
      reactions: reactionsList.map((r) => Reaction.fromJson(r)).toList(),
    );
  }
}

class ChatInboxItem {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String formattedTime;
  final int unreadCount;
  final String? userRole;
  final bool isBlocked;

  ChatInboxItem({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.formattedTime,
    required this.unreadCount,
    this.userRole,
    required this.isBlocked,
  });

  factory ChatInboxItem.fromJson(Map<String, dynamic> json) {
    return ChatInboxItem(
      userId: json['otherUserId']?.toString() ?? '',
      userName: json['otherUserName']?.toString() ?? '',
      userAvatar: json['otherUserProfileImage']?.toString(),
      lastMessage: json['lastMessageContent']?.toString() ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'].toString())
          : DateTime.now(),
      formattedTime: json['formattedTime']?.toString() ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      userRole: json['packageTier']?.toString(),
      isBlocked: json['isMuted'] as bool? ?? false,
    );
  }
}

class InboxResponse {
  final bool isSuccess;
  final String message;
  final List<ChatInboxItem> items;
  final int totalCount;

  InboxResponse({
    required this.isSuccess,
    required this.message,
    required this.items,
    required this.totalCount,
  });

  factory InboxResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];

    return InboxResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList.map((item) => ChatInboxItem.fromJson(item)).toList(),
      totalCount: data['totalCount'] ?? 0,
    );
  }
}

class ChatHistoryResponse {
  final bool isSuccess;
  final String message;
  final List<ChatMessage> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ChatHistoryResponse({
    required this.isSuccess,
    required this.message,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ChatHistoryResponse.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];

    return ChatHistoryResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList
          .map((item) => ChatMessage.fromJson(item, currentUserId))
          .toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 20,
      totalCount: data['totalCount'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}
