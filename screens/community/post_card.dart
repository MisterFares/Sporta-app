import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit/models/community/comment.dart';
import 'package:fit/models/community/community_post.dart';
import 'package:fit/screens/community/video_player_widget.dart';
import 'package:fit/screens/profile/app_avatar.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

Widget postCard({
  required String id,
  required String authorId,
  required String authorName,
  required String? authorAvatar,
  required String content,
  required List<String>? mediaUrls,
  required String type,
  required int likesCount,
  required int commentsCount,
  required bool isLiked,
  required String formattedTime,
  required bool isOwner,
  required VoidCallback onLike,
  required VoidCallback onDelete,
  required VoidCallback onShare,
  required BuildContext context,
  required String currentUserId,
  VoidCallback? onEdit,
  Location? location,
}) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(userProfile: null, isOwner: false),
                settings: RouteSettings(arguments: authorId),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(src: authorAvatar, size: 44),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: AppColors.cardTextSecondary,
                  size: 20,
                ),
                color: Color(0xFF0F1412),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.cardBorder),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else if (value == 'edit' && onEdit != null) {
                    onEdit();
                  }
                },
                itemBuilder: (context) => [
                  if (isOwner && onEdit != null) ...[
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.cardTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isOwner) ...[
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  if (!isOwner)
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 10),
                          Text('Report'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        if (content.isNotEmpty) ...[
          SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              color: AppColors.cardTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],

        if (location != null) ...[
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showLocationMap(location!, context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location!.name,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.cardTextSecondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (mediaUrls != null && mediaUrls.isNotEmpty) ...[
          SizedBox(height: 12),
          if (type == 'video')
            VideoPlayerWidget(
              videoPath:
                  ImageUrlHelper.getFullImageUrl(mediaUrls.first) ??
                  mediaUrls.first,
            )
          else
            _buildMediaGallery(mediaUrls, context),
        ],

        if (likesCount > 0 || commentsCount > 0) ...[
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 11,
                    ),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _showLikers(id, context, likesCount),
                    child: Text(
                      '$likesCount ${likesCount == 1 ? "like" : "likes"}',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    _showComments(id, context, authorId, currentUserId),
                child: Text(
                  '$commentsCount ${commentsCount == 1 ? "comment" : "comments"}',
                  style: GoogleFonts.inter(
                    color: AppColors.cardTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 8),
        Divider(color: AppColors.cardBorder, height: 1),
        SizedBox(height: 4),
        Row(
          children: [
            _actionBtn(
              isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              'Like',
              isLiked,
              onLike,
            ),
            _actionBtn(
              Icons.chat_bubble_outline_rounded,
              'Comment',
              false,
              () => _showComments(id, context, authorId, currentUserId),
            ),
            _actionBtn(Icons.share_outlined, 'Share', false, onShare),
          ],
        ),
      ],
    ),
  );
}

void _showLikers(String postId, BuildContext context, int likesCount) async {
  if (likesCount == 0) return;

  try {
    final response = await ApiService.getPostLikers(postId: postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Liked by (${response.totalCount})',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: response.items.length,
                itemBuilder: (context, index) {
                  final liker = response.items[index];
                  final avatarUrl = ImageUrlHelper.getFullImageUrl(
                    liker.profileImageUrl,
                  );
                  return ListTile(
                    leading: AppAvatar(src: avatarUrl, size: 40),
                    title: Text(
                      liker.fullName,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: liker.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    print('Error showing likers: $e');
  }
}

void _showComments(
  String postId,
  BuildContext context,
  String postAuthorId,
  String currentUserId,
) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsSheet(
      postId: postId,
      currentUserId: currentUserId,
      postAuthorId: postAuthorId,
    ),
  );
}

void _showLocationMap(Location location, context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location.name,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(location.lat, location.lng),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fit',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(location.lat, location.lng),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMediaGallery(List<String> mediaUrls, BuildContext context) {
  final imageUrls = mediaUrls
      .where(
        (url) =>
            url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.jpeg'),
      )
      .toList();

  if (imageUrls.isEmpty) return SizedBox.shrink();

  if (imageUrls.length == 1) {
    return GestureDetector(
      onTap: () => _showFullMediaViewer(imageUrls, context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(height: 250, child: _buildImage(imageUrls.first)),
      ),
    );
  }

  return GestureDetector(
    onTap: () => _showFullMediaViewer(imageUrls, context),
    child: GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        childAspectRatio: 1.5,
      ),
      itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
      itemBuilder: (_, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(imageUrls[index]),
            ),
            if (index == 3 && imageUrls.length > 4)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    '+${imageUrls.length - 4}',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

void _showFullMediaViewer(List<String> mediaPaths, BuildContext context) {
  final fullUrls = mediaPaths
      .map((path) => ImageUrlHelper.getFullImageUrl(path) ?? path)
      .toList();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.95),
        child: Stack(
          children: [
            Center(
              child: PageView.builder(
                itemCount: fullUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: fullUrls[index],
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.cardBorder,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildImage(String path) {
  final fullUrl = ImageUrlHelper.getFullImageUrl(path);
  return CachedNetworkImage(
    imageUrl: fullUrl ?? path,
    fit: BoxFit.contain,
    width: double.infinity,
    height: double.infinity,
    errorWidget: (_, __, ___) => Container(
      color: AppColors.cardBorder,
      child: Icon(Icons.broken_image, color: AppColors.textPrimary),
    ),
  );
}

Widget _actionBtn(
  IconData icon,
  String label,
  bool active,
  VoidCallback onTap,
) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.border : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.cardTextSecondary,
              size: 18,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: active ? AppColors.primary : AppColors.cardTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Comments Sheet Widget
class CommentsSheet extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final String postAuthorId;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.postAuthorId,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  List<Comment> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  Future<void> _loadComments({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _comments = [];
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.getPostComments(
        postId: widget.postId,
        pageNumber: reset ? 1 : _currentPage + 1,
        pageSize: 20,
      );

      setState(() {
        if (reset) {
          _comments = response.items;
        } else {
          _comments.addAll(response.items);
        }
        _currentPage = response.currentPage;
        _totalPages = response.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    await _loadComments(reset: false);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final result = await ApiService.addComment(
      postId: widget.postId,
      content: _commentController.text.trim(),
    );

    if (result['success']) {
      final newComment = Comment.fromJson(result['data']);
      setState(() {
        _comments.insert(0, newComment);
      });
      _commentController.clear();
      // Scroll to top to show new comment
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editComment(String commentId, String oldContent) async {
    final TextEditingController editController = TextEditingController(
      text: oldContent,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Edit Comment'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            hintStyle: TextStyle(color: AppColors.cardTextSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (editController.text.trim().isEmpty) return;

              Navigator.pop(context);

              final result = await ApiService.updateComment(
                commentId: commentId,
                content: editController.text.trim(),
              );

              if (result['success']) {
                setState(() {
                  final index = _comments.indexWhere((c) => c.id == commentId);
                  if (index != -1) {
                    _comments[index].content = editController.text.trim();
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comment updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ApiService.deleteComment(commentId: commentId);

    if (result['success']) {
      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Comments (${_comments.length})',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _comments.length && _isLoadingMore) {
                        return Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final comment = _comments[index];
                      final avatarUrl = ImageUrlHelper.getFullImageUrl(
                        comment.authorAvatar,
                      );
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppAvatar(src: avatarUrl, size: 32),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.authorName,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    comment.content,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    comment.formattedTime,
                                    style: GoogleFonts.inter(
                                      color: AppColors.cardTextSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_horiz,
                                color: AppColors.cardTextSecondary,
                                size: 18,
                              ),
                              color: AppColors.cardBackground,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(comment.id, comment.content);
                                } else if (value == 'delete') {
                                  _deleteComment(comment.id);
                                } else if (value == 'report') {
                                  // Add report functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Comment reported'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) {
                                final isCommentOwner =
                                    comment.authorId == widget.currentUserId;
                                final isPostOwner =
                                    widget.postAuthorId == widget.currentUserId;

                                if (isCommentOwner) {
                                  // I own the comment - can edit and delete
                                  return [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                } else if (isPostOwner) {
                                  // I own the post - can delete anyone's comment
                                  return [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Report'),
                                        ],
                                      ),
                                    ),
                                  ];
                                } else {
                                  // I don't own the comment or the post - can only report
                                  return [
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Report'),
                                        ],
                                      ),
                                    ),
                                  ];
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
