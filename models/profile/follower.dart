class Follower {
  final String id;
  final String role;
  final String name;
  final String title;
  final String? avatar;
  final String time;

  Follower({
    required this.id,
    required this.role,
    required this.name,
    required this.title,
    this.avatar,
    required this.time,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'title': title,
      'avatar': avatar,
      'time': time,
    };
  }
}

class FollowersResponse {
  final bool isSuccess;
  final String message;
  final int followersCount;
  final List<Follower> followers;
  final String userId;
  final String role;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;

  FollowersResponse({
    required this.isSuccess,
    required this.message,
    required this.followersCount,
    required this.followers,
    required this.userId,
    required this.role,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
  });

  factory FollowersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final List<dynamic> followersList = data['followers'] as List<dynamic>? ?? [];
    
    final List<Follower> followers = [];
    for (final item in followersList) {
      if (item is Map<String, dynamic>) {
        followers.add(Follower.fromJson(item));
      }
    }
    
    return FollowersResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followers: followers,
      userId: data['userId'] ?? '',
      role: data['role'] ?? '',
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      totalCount: data['totalCount'] ?? 0,
    );
  }
}