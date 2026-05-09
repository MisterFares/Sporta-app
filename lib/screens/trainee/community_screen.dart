import 'package:fit/classes/community/comments.dart';
import 'package:fit/classes/community/posts.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/lists/data/posts.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final String _currentUserName = 'Bashar Al-Assad';
  final String _currentUserAvatar =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgY-FG_cYDsqC3y_AW-oKvjz-rSWfhUj5XCA&s';

  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  Post? _selectedPostForComments;

  // Sample comments data (in real app, each post would have its own comments list)
  Map<String, List<Comment>> _postComments = {};

  @override
  void initState() {
    super.initState();
    _initializeSampleComments();
  }

  void _initializeSampleComments() {
    for (var post in posts) {
      _postComments[post.id] = [
        Comment(
          id: 'c1',
          postId: post.id,
          authorName: 'John Doe',
          authorAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
          content: 'Great progress! Keep it up! 💪',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Comment(
          id: 'c2',
          postId: post.id,
          authorName: 'Jane Smith',
          authorAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
          content: 'Thanks for sharing this!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        // For web compatibility, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.error_outline, 'Error picking image: $e', AppColors.red),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImagePath = null;
    });
  }

  void _createPost() {
    final content = _postController.text.trim();
    if (content.isEmpty && _selectedImageBytes == null) return;

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: _currentUserName,
      authorAvatar: _currentUserAvatar,
      authorRole: 'Trainee',
      timeAgo: 'Just now',
      content: content,
      likes: 0,
      comments: 0,
      reposts: 0,
      isLiked: false,
      isReposted: false,
      isCoachPost: false,
      imageBytes: _selectedImageBytes,
      imagePath: _selectedImagePath,
    );

    setState(() {
      posts.insert(0, newPost);
      _postComments[newPost.id] = [];
      _postController.clear();
      _selectedImageBytes = null;
      _selectedImagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      snackBar(
        Icons.check_circle_outline_rounded,
        'Post created!',
        AppColors.greeen,
      ),
    );
  }

  void _openImageViewer(Uint8List? imageBytes, String? imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.95),
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: imageBytes != null
                          ? Image.memory(imageBytes, fit: BoxFit.contain)
                          : Image.file(File(imagePath!), fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addComment(Post post) {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: post.id,
      authorName: _currentUserName,
      authorAvatar: _currentUserAvatar,
      content: commentText,
      timestamp: DateTime.now(),
    );

    setState(() {
      if (_postComments[post.id] == null) {
        _postComments[post.id] = [];
      }
      _postComments[post.id]!.insert(0, newComment);
      post.comments = _postComments[post.id]!.length;
      _commentController.clear();
    });
  }

  void _showCommentsSheet(Post post) {
    _commentController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: AppColors.cardBorder),

                  // Comments List
                  Expanded(
                    child: (_postComments[post.id] ?? []).isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: (_postComments[post.id] ?? []).length,
                            itemBuilder: (context, index) {
                              final comment = _postComments[post.id]![index];
                              return _buildCommentTile(comment);
                            },
                          ),
                  ),

                  // Comment Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border(
                        top: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        // User Avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(_currentUserAvatar),
                          backgroundColor: AppColors.cardBorder,
                        ),
                        const SizedBox(width: 12),
                        // Input Field
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.cardBorder.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Send Button
                        GestureDetector(
                          onTap: () {
                            _addComment(post);
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Extra bottom padding for keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Refresh when bottom sheet closes
      setState(() {});
    });
  }

  Widget _buildCommentTile(Comment comment) {
    final isCurrentUser = comment.authorName == _currentUserName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(comment.authorAvatar),
            backgroundColor: AppColors.cardBorder,
            child: comment.authorAvatar.isEmpty
                ? Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0] : 'U',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d, h:mm a').format(comment.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (isCurrentUser)
                      PopupMenuButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            setState(() {
                              _postComments[comment.postId]?.removeWhere(
                                (c) => c.id == comment.id,
                              );
                              final post = posts.firstWhere(
                                (p) => p.id == comment.postId,
                              );
                              post.comments =
                                  _postComments[comment.postId]?.length ?? 0;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBar(
                                Icons.delete_outline,
                                'Comment deleted',
                                AppColors.red,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Community'),
      drawer: AppDrawer(selectedIndex: 4, role: 'trainee'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSearchInput(
                  _searchController,
                  () {},
                  'Search for Trainers, Trainees',
                ),
                const SizedBox(height: 24),
                _buildCreatePostCard(),
                const SizedBox(height: 32),
                ...posts.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildPostCard(post),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      'BA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Share your workout, progress, or question...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // Image Preview
          if (_selectedImageBytes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImageBytes!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeSelectedImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      Icons.image_outlined,
                      'Photo',
                      _pickImage,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.attach_file, 'Link', () {}),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 70,
                  child: buildButton('Post', null, _createPost, true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryBtnText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final isCurrentUser = post.authorName == _currentUserName;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.imgHeader2,
        border: Border.all(
          color: post.isCoachPost
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (post.authorRole == 'Coach') {
                      Navigator.pushNamed(context, '/coaches-profile');
                    }
                  },
                  child: ClipOval(
                    child: Image.network(
                      post.authorAvatar,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 44,
                          height: 44,
                          color: AppColors.cardBorder,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.imgHeader2,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (post.authorRole == 'Coach') ...[
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          _buildRoleBadge(post.authorRole),
                          const Spacer(),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditPostDialog(post);
                                  break;
                                case 'delete':
                                  _showDeleteConfirmationDialog(post);
                                  break;
                                case 'report':
                                  _showReportDialog(post);
                                  break;
                                case 'save':
                                  _savePost(post);
                                  break;
                                case 'hide':
                                  _hidePost(post);
                                  break;
                              }
                            },
                            itemBuilder: (context) {
                              final List<PopupMenuEntry<String>> items = [];
                              if (isCurrentUser) {
                                items.add(
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Edit Post',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                items.add(
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Color(0xFFFF453A),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Delete Post',
                                          style: TextStyle(
                                            color: Color(0xFFFF453A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                items.add(const PopupMenuDivider());
                              }
                              items.add(
                                const PopupMenuItem(
                                  value: 'save',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark_outline,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Save Post',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              items.add(
                                const PopupMenuItem(
                                  value: 'hide',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_off_outlined,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Hide Post',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              items.add(
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: 20,
                                        color: Color(0xFFFF453A),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          color: Color(0xFFFF453A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              return items;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white,
              ),
            ),
          ),

          if (post.imageBytes != null || post.imagePath != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _openImageViewer(post.imageBytes, post.imagePath),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: post.imageBytes != null
                    ? Image.memory(
                        post.imageBytes!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(post.imagePath!),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                _buildPostActionButton(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: post.likes.toString(),
                  isActive: post.isLiked,
                  onTap: () {
                    setState(() {
                      post.isLiked = !post.isLiked;
                      post.isLiked ? post.likes++ : post.likes--;
                    });
                  },
                ),
                const SizedBox(width: 24),
                _buildPostActionButton(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: post.comments.toString(),
                  isActive: false,
                  onTap: () => _showCommentsSheet(post),
                ),
                const SizedBox(width: 24),
                _buildPostActionButton(
                  icon: Icons.repeat_outlined,
                  activeIcon: Icons.repeat,
                  label: post.reposts.toString(),
                  isActive: post.isReposted,
                  onTap: () {
                    setState(() {
                      post.isReposted = !post.isReposted;
                      post.isReposted ? post.reposts++ : post.reposts--;
                    });
                  },
                ),
                const SizedBox(width: 24),
                _buildPostActionButton(
                  icon: Icons.share_outlined,
                  activeIcon: Icons.share,
                  label: 'Share',
                  isActive: false,
                  onTap: () => _sharePost(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isCoach = role == 'Coach';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCoach
            ? AppColors.primary.withOpacity(0.15)
            : const Color(0xFF0B0F0E),
        border: Border.all(
          color: isCoach ? AppColors.primary : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isCoach ? AppColors.primary : AppColors.cardTextSecondary,
        ),
      ),
    );
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 18,
            color: isActive ? AppColors.primary : const Color(0xFF8B949E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primary : const Color(0xFF8B949E),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPostDialog(Post post) {
    final TextEditingController editController = TextEditingController(
      text: post.content,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Edit Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Update your post...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          maxLines: 5,
        ),
        actions: [
          textButton(
            14,
            AppColors.textSecondary,
            'Cancel',
            () => Navigator.pop(context),
          ),
          SizedBox(
            width: 70,
            child: buildButton('Save', null, () {
              setState(() => post.content = editController.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                snackBar(
                  Icons.check_circle_outline,
                  'Post updated!',
                  AppColors.greeen,
                ),
              );
            }, true),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => posts.removeWhere((p) => p.id == post.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted!'),
                  backgroundColor: Color(0xFFFF453A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF453A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Report Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Why are you reporting this post?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thank you for your report. We will review it.',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF453A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _savePost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post saved to bookmarks!'),
        backgroundColor: Color(0xFF32D74B),
      ),
    );
  }

  void _hidePost(Post post) {
    setState(() => posts.removeWhere((p) => p.id == post.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post hidden'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _sharePost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
