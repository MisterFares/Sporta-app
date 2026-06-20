class CommunityPost {
  final String id;
  final String content;
  final List<String>? mediaUrls;
  final Location? location;
  final DateTime createdAt;
  final String formattedTime;
  int likesCount;
  final int commentsCount;
  bool isLikedByCurrentUser;
  final UserInfo user;

  CommunityPost({
    required this.id,
    required this.content,
    this.mediaUrls,
    this.location,
    required this.createdAt,
    required this.formattedTime,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
    required this.user,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    // Extract media URLs from the media array
    final mediaList = json['media'] as List<dynamic>? ?? [];
    final mediaUrls = mediaList
        .map((item) => item['url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    return CommunityPost(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mediaUrls: mediaUrls.isNotEmpty ? mediaUrls : null,
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      formattedTime: _formatTime(DateTime.parse(json['createdAt'].toString())),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      user: UserInfo(
        id: json['authorId']?.toString() ?? '',
        name: json['authorName']?.toString() ?? '',
        avatar: json['authorProfileImage']?.toString(),
        role: json['authorRole']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mediaUrls': mediaUrls,
      'location': location?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'formattedTime': formattedTime,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'user': user.toJson(),
    };
  }
}

class Location {
  final double lat;
  final double lng;
  final String name;

  Location({required this.lat, required this.lng, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'name': name};
  }
}

class UserInfo {
  final String id;
  final String name;
  final String? avatar;
  final String role;

  UserInfo({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar, 'role': role};
  }
}

class CommunityFeedResponse {
  final bool isSuccess;
  final String message;
  final List<CommunityPost> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  CommunityFeedResponse({
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

  factory CommunityFeedResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final itemsList = data['items'] as List<dynamic>? ?? [];

    // Calculate totalPages based on items length if API returns 0
    int totalPages = data['totalPages'] ?? 0;
    if (totalPages == 0 && itemsList.isNotEmpty) {
      totalPages = 1; // Force at least 1 page if there are items
    }

    print("🔴 totalPages from API: ${data['totalPages']}");
    print("🔴 totalCount from API: ${data['totalCount']}");
    print("🔴 items length: ${itemsList.length}");

    return CommunityFeedResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      items: itemsList.map((item) => CommunityPost.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: totalPages,
      pageSize: data['pageSize'] ?? 10,
      totalCount: data['totalCount'] ?? itemsList.length,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage:
          data['hasNextPage'] ?? (itemsList.length >= (data['pageSize'] ?? 10)),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
  if (difference.inDays < 1) return '${difference.inHours} hours ago';
  if (difference.inDays < 7) return '${difference.inDays} days ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
