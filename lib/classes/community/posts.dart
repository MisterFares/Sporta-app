import 'dart:typed_data';

class Post {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String authorRole;
  final String timeAgo;
  String content;
  int likes;
  int comments;
  int reposts;
  bool isLiked;
  bool isReposted;
  final bool isCoachPost;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? imagePath;
  
  Post({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.authorRole,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.isLiked,
    required this.isReposted,
    required this.isCoachPost,
    this.imageUrl,
    required this.imageBytes,
    required this.imagePath,
  });
}