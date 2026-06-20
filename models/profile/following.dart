class FollowingUser {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final String time;
  bool isFollowedByCurrentUser;
  final String role;

  FollowingUser({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    required this.time,
    required this.isFollowedByCurrentUser,
    required this.role,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      time: json['time']?.toString() ?? '',
      isFollowedByCurrentUser: json['isFollowedByCurrentUser'] ?? false,
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'time': time,
      'isFollowedByCurrentUser': isFollowedByCurrentUser,
      'role': role,
    };
  }
}

class FollowingResponse {
  final bool isSuccess;
  final String message;
  final List<FollowingUser> following;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  FollowingResponse({
    required this.isSuccess,
    required this.message,
    required this.following,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory FollowingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final List<dynamic> itemsList = data['items'] as List<dynamic>? ?? [];
    
    final List<FollowingUser> following = [];
    for (final item in itemsList) {
      if (item is Map<String, dynamic>) {
        following.add(FollowingUser.fromJson(item));
      }
    }
    
    return FollowingResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      following: following,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      totalCount: data['totalCount'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}