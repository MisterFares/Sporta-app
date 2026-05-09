// classes/community/comment.dart
class Comment {
  final String id;
  final String postId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime timestamp;
  final int? likes;

  Comment({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.likes,
  });
}