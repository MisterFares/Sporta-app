import 'package:fit/models/community/community_post.dart';

class ProfilePost {
  final String authorId;
  final String id;
  final String content;
  final List<PostMedia> media; // Change this
  final DateTime createdAt;
  final String formattedTime;
  int likesCount;
  final int commentsCount;
  bool isLikedByCurrentUser;
  final String authorName; // Add this
  final String? authorProfileImage; // Add this
  final Location? location;

  ProfilePost({
    required this.authorId, // Add this
    required this.id,
    required this.content,
    required this.media, // Change this
    required this.createdAt,
    required this.formattedTime,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
    required this.authorName, // Add this
    this.authorProfileImage, // Add this
    this.location,
  });

  factory ProfilePost.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List<dynamic>? ?? [];
    return ProfilePost(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      media: mediaList.map((item) => PostMedia.fromJson(item)).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      formattedTime: _formatTime(DateTime.parse(json['createdAt'].toString())),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      authorProfileImage: json['authorProfileImage']?.toString(),
      location:
          json['location'] !=
              null // 👈 ADD THIS
          ? Location.fromJson(json['location'])
          : null,
    );
  }
}

class PostMedia {
  final String url;
  final String type;

  PostMedia({required this.url, required this.type});

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
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

class ProfilePostsResponse {
  final bool isSuccess;
  final String message;
  final List<ProfilePost> posts;
  final String userId;
  final String role;

  ProfilePostsResponse({
    required this.isSuccess,
    required this.message,
    required this.posts,
    required this.userId,
    required this.role,
  });

  factory ProfilePostsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final postsList = data['posts'] as List<dynamic>? ?? [];

    return ProfilePostsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      posts: postsList.map((item) => ProfilePost.fromJson(item)).toList(),
      userId: data['userId']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
    );
  }
}
