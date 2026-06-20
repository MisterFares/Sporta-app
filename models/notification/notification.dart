class AppNotification {
  final String id;
  final String content;
  final String relatedEntityId;
  final DateTime createdAt;
  final String formattedTime;
  bool isRead;
  final String title;
  final String category;
  final String role;

  AppNotification({
    required this.id,
    required this.content,
    required this.relatedEntityId,
    required this.createdAt,
    required this.formattedTime,
    required this.isRead,
    required this.title,
    required this.category,
    required this.role,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      relatedEntityId: json['relatedEntityId']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      formattedTime: json['formattedTime']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'relatedEntityId': relatedEntityId,
      'createdAt': createdAt.toIso8601String(),
      'formattedTime': formattedTime,
      'isRead': isRead,
      'title': title,
      'category': category,
      'role': role,
    };
  }
}

class NotificationsResponse {
  final bool isSuccess;
  final String message;
  final List<AppNotification> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  NotificationsResponse({
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

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];
    
    return NotificationsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList.map((item) => AppNotification.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 15,
      totalCount: data['totalCount'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}