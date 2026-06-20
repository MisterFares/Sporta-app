class Comment {
  final String id;
  String content;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final String formattedTime;
  final int likesCount;
  final bool isLikedByCurrentUser;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.formattedTime,
    required this.likesCount,
    required this.isLikedByCurrentUser,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      authorAvatar: json['authorProfileImage']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      formattedTime: json['formattedTime']?.toString() ?? '',
      likesCount: json['likesCount'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'formattedTime': formattedTime,
      'likesCount': likesCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }
}

class CommentsResponse {
  final bool isSuccess;
  final String message;
  final List<Comment> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  CommentsResponse({
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

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];
    
    return CommentsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList.map((item) => Comment.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 0,
      pageSize: data['pageSize'] ?? 10,
      totalCount: data['totalCount'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}