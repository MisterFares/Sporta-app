import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/models/community/community_post.dart';
import 'package:fit/models/profile/profile_posts.dart';
import 'package:fit/screens/community/location_picker_screen.dart';
import 'package:fit/screens/community/post_card.dart';
import 'package:fit/screens/community/video_preview_widget.dart';
import 'package:fit/screens/profile/app_avatar.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

enum PostMode {
  profile, // Uses /api/Profile/{id}/posts
  community, // Uses /api/Community/posts/feed
}

class PostsSection extends StatefulWidget {
  final String userId;
  final bool isOwner;
  final PostMode mode;
  final String? currentUserName;
  final String? currentUserAvatar;
  final String? currentUserId;

  const PostsSection({
    super.key,
    required this.userId,
    required this.isOwner,
    this.mode = PostMode.profile,
    this.currentUserName,
    this.currentUserAvatar,
    this.currentUserId,
  });

  @override
  State<PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends State<PostsSection> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  Location? _selectedLocation;
  String _locationName = '';

  // Pagination for community
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Create post
  final TextEditingController _postController = TextEditingController();
  final List<XFile> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    if (widget.mode == PostMode.community) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    print(
      "🔴 SCROLLING - position: ${_scrollController.position.pixels}, max: ${_scrollController.position.maxScrollExtent}",
    );
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      print("🔴 TRIGGER LOAD MORE");
      _loadMorePosts();
    }
  }

  void _pickLocation(Function setModalState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          onLocationSelected: (lat, lng, name) {
            print("📍 Location selected: $name ($lat, $lng)"); // Debug
            setModalState(() {
              _selectedLocation = Location(lat: lat, lng: lng, name: name);
              _locationName = name;
            });
            print("📌 _locationName is now: $_locationName"); // Debug
          },
        ),
      ),
    );
  }

  Future<void> _loadPosts({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _posts = [];
        _currentPage = 1;
      });
    }

    try {
      if (widget.mode == PostMode.profile) {
        final response = await ApiService.getUserProfilePosts(
          userId: widget.userId,
        );
        print("🔴 LOADING POSTS - Mode: ${widget.mode}");
        print("🔴 USER ID: ${widget.userId}");
        print("🔴 POSTS RECEIVED: ${_posts.length}");

        setState(() {
          _posts = response.posts;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        final response = await ApiService.getCommunityFeed(
          pageNumber: reset ? 1 : _currentPage + 1,
          pageSize: 10,
        );
        setState(() {
          if (reset) {
            _posts = response.items;
          } else {
            _posts.addAll(response.items);
          }
          _currentPage = response.currentPage;
          _totalPages = response.totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });

      print(
        "🔴 LOAD MORE - CurrentPage: $_currentPage, TotalPages: $_totalPages",
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    await _loadPosts(reset: false);
  }

  Future<void> _toggleLike(dynamic post, int index) async {
    final result = await ApiService.toggleCommunityPostLike(postId: post.id);

    if (result['success']) {
      setState(() {
        if (widget.mode == PostMode.profile) {
          (_posts[index] as ProfilePost).isLikedByCurrentUser =
              !(_posts[index] as ProfilePost).isLikedByCurrentUser;
          (_posts[index] as ProfilePost).likesCount +=
              (_posts[index] as ProfilePost).isLikedByCurrentUser ? 1 : -1;
        } else {
          (_posts[index] as CommunityPost).isLikedByCurrentUser =
              !(_posts[index] as CommunityPost).isLikedByCurrentUser;
          (_posts[index] as CommunityPost).likesCount +=
              (_posts[index] as CommunityPost).isLikedByCurrentUser ? 1 : -1;
        }
      });
    }
  }

  Future<void> _deletePost(dynamic post, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Use the same delete endpoint for both profile and community
    final result = await ApiService.deleteCommunityPost(postId: post.id);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result['success']) {
      setState(() {
        _posts.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _sharePost(dynamic post) async {
    try {
      // Generate the post link (you need to build the full URL)
      final String postLink = 'https://sporta.com/posts/${post.id}';

      // Create share text with the link
      String shareText = post.content.isNotEmpty ? '${post.content}\n\n' : '';
      if (widget.mode == PostMode.community) {
        shareText += 'Shared by: ${post.user.name}\n';
      }
      shareText += '\n$postLink\n';
      shareText += '\n⬇️ Download the app to see more!';

      await Share.share(shareText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post link copied!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  void _showEditPostModal(dynamic post, int index) {
    final String postId = post.id;
    final String currentContent = post.content;
    final TextEditingController editController = TextEditingController(
      text: currentContent,
    );

    // Get existing media URLs from the post
    List<String> existingMediaUrls = [];
    if (widget.mode == PostMode.profile) {
      existingMediaUrls = (post as ProfilePost).media
          .map((m) => m.url)
          .toList();
    } else {
      existingMediaUrls = (post as CommunityPost).mediaUrls ?? [];
    }

    List<File> newMediaFiles = [];
    List<String> deletedMediaUrls = [];
    List<String> currentMediaUrls = List.from(existingMediaUrls);
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Edit Post',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.cardTextSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: editController,
                        maxLines: 5,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.cardTextSecondary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Display current media
                      if (currentMediaUrls.isNotEmpty ||
                          newMediaFiles.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                currentMediaUrls.length + newMediaFiles.length,
                            itemBuilder: (context, i) {
                              final isNewFile = i >= currentMediaUrls.length;
                              final indexInList = isNewFile
                                  ? i - currentMediaUrls.length
                                  : i;

                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.cardBorder,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: isNewFile
                                          ? Image.file(
                                              newMediaFiles[indexInList],
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  ImageUrlHelper.getFullImageUrl(
                                                    currentMediaUrls[indexInList],
                                                  ) ??
                                                  '',
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) =>
                                                  Icon(Icons.broken_image),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (isNewFile) {
                                            newMediaFiles.removeAt(indexInList);
                                          } else {
                                            final urlToDelete =
                                                currentMediaUrls[indexInList];
                                            deletedMediaUrls.add(urlToDelete);

                                            // 👇 ADD THESE TWO LINES RIGHT HERE 👇
                                            print(
                                              "🗑️ DELETING THIS URL: $urlToDelete",
                                            );
                                            print(
                                              "🗑️ TOTAL URLs TO DELETE: ${deletedMediaUrls.length}",
                                            );

                                            currentMediaUrls.removeAt(
                                              indexInList,
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.textPrimary,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                      ],

                      // Add media buttons
                      Row(
                        children: [
                          _mediaButton(
                            icon: Icons.image_outlined,
                            label: 'Add Image',
                            onTap: () async {
                              final images = await picker.pickMultiImage();
                              if (images.isNotEmpty) {
                                setModalState(() {
                                  for (var img in images) {
                                    newMediaFiles.add(File(img.path));
                                  }
                                });
                              }
                            },
                          ),
                          SizedBox(width: 12),
                          _mediaButton(
                            icon: Icons.videocam_outlined,
                            label: 'Add Video',
                            onTap: () async {
                              final video = await picker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (video != null) {
                                setModalState(() {
                                  newMediaFiles.add(File(video.path));
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final newContent = editController.text.trim();

                            if (newContent.isEmpty &&
                                currentMediaUrls.isEmpty &&
                                newMediaFiles.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Post cannot be empty'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (newContent == currentContent &&
                                newMediaFiles.isEmpty &&
                                deletedMediaUrls.isEmpty) {
                              Navigator.pop(context);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()),
                            );

                            final result = await ApiService.updateCommunityPost(
                              postId: postId,
                              content: newContent,
                              newMediaFiles: newMediaFiles.isEmpty
                                  ? null
                                  : newMediaFiles,
                              deletedMediaUrls: deletedMediaUrls.isEmpty
                                  ? null
                                  : deletedMediaUrls,
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            if (result['success']) {
                              await _loadPosts(reset: true);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Post updated!'),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write something or add media')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      List<File> imageFiles = [];
      for (var media in _selectedMedia) {
        imageFiles.add(File(media.path));
      }

      final result = await ApiService.createCommunityPost(
        content: _postController.text,
        mediaFiles: imageFiles,
        location: _selectedLocation,
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (result['success']) {
        print("✅ POST CREATED - ID: ${result['data']?['id']}");
        await _loadPosts(reset: true);
        print("✅ POSTS COUNT AFTER REFRESH: ${_posts.length}");
        _postController.clear();
        _selectedMedia.clear();

        // Close the modal
        if (context.mounted) {
          Navigator.pop(context); // This closes the create post modal
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created!'),
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isProfileMode = widget.mode == PostMode.profile;

    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              widget.mode == PostMode.profile ? 'Posts' : 'Community Feed',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (widget.isOwner) ...[SizedBox(height: 12), _createPostBox()],
          SizedBox(height: 8),

          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_posts.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No posts yet',
                style: GoogleFonts.inter(
                  color: AppColors.cardTextSecondary,
                  fontSize: 14,
                ),
              ),
            )
          else if (isProfileMode)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.cardBorder, height: 1, thickness: 1),
              itemBuilder: (context, index) {
                final post = _posts[index];
                if (widget.mode == PostMode.profile) {
                  final profilePost = post as ProfilePost;
                  final imageUrls = profilePost.media
                      .where((m) => m.type == 'image')
                      .map((m) => m.url)
                      .toList();
                  final videoUrl = profilePost.media
                      .where((m) => m.type == 'video')
                      .firstOrNull
                      ?.url;

                  return postCard(
                    id: profilePost.id,
                    authorId: profilePost.authorId,
                    currentUserId: widget.currentUserId ?? '',
                    authorName: profilePost.authorName,
                    authorAvatar: profilePost.authorProfileImage,
                    content: profilePost.content,
                    mediaUrls: videoUrl != null ? [videoUrl] : imageUrls,
                    type: videoUrl != null
                        ? 'video'
                        : (imageUrls.isNotEmpty ? 'image' : 'text'),
                    likesCount: profilePost.likesCount,
                    commentsCount: profilePost.commentsCount,
                    isLiked: profilePost.isLikedByCurrentUser,
                    formattedTime: profilePost.formattedTime,
                    isOwner: widget.isOwner,
                    onLike: () => _toggleLike(profilePost, index),
                    onDelete: () => _deletePost(profilePost, index),
                    onShare: () => _sharePost(profilePost),
                    context: context,
                    location: profilePost.location,
                    onEdit: widget.isOwner
                        ? () => _showEditPostModal(profilePost, index)
                        : null,
                  );
                } else {
                  final communityPost = post as CommunityPost;
                  final imageUrls = communityPost.mediaUrls ?? [];
                  final videoUrl = imageUrls.firstWhere(
                    (url) =>
                        url.toLowerCase().endsWith('.mp4') ||
                        url.toLowerCase().endsWith('.mov'),
                    orElse: () => '',
                  );

                  return postCard(
                    id: communityPost.id,
                    authorId: communityPost.user.id,
                    currentUserId: widget.currentUserId ?? '',
                    authorName: communityPost.user.name,
                    authorAvatar: communityPost.user.avatar,
                    content: communityPost.content,
                    mediaUrls: videoUrl.isNotEmpty ? [videoUrl] : imageUrls,
                    type: videoUrl.isNotEmpty
                        ? 'video'
                        : (imageUrls.isNotEmpty ? 'image' : 'text'),
                    likesCount: communityPost.likesCount,
                    commentsCount: communityPost.commentsCount,
                    isLiked: communityPost.isLikedByCurrentUser,
                    formattedTime: communityPost.formattedTime,
                    isOwner: widget.currentUserId == communityPost.user.id,
                    onLike: () => _toggleLike(communityPost, index),
                    onDelete: () => _deletePost(communityPost, index),
                    onShare: () => _sharePost(communityPost),
                    context: context,
                    location: communityPost.location,
                    onEdit: widget.currentUserId == communityPost.user.id
                        ? () => _showEditPostModal(communityPost, index)
                        : null,
                  );
                }
              },
            )
          else
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.cardBorder,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  if (index == _posts.length && _isLoadingMore) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  final post = _posts[index];
                  final communityPost = post as CommunityPost;
                  print("🔴 CURRENT USER ID: '${widget.currentUserId}'");
                  print("🔴 POST AUTHOR ID: '${communityPost.user.id}'");
                  print(
                    "🔴 ARE EQUAL: ${widget.currentUserId == communityPost.user.id}",
                  );
                  final imageUrls = communityPost.mediaUrls ?? [];
                  final videoUrl = imageUrls.firstWhere(
                    (url) =>
                        url.toLowerCase().endsWith('.mp4') ||
                        url.toLowerCase().endsWith('.mov'),
                    orElse: () => '',
                  );
                  return postCard(
                    id: communityPost.id,
                    authorId: communityPost.user.id,
                    currentUserId: widget.currentUserId ?? '',
                    authorName: communityPost.user.name,
                    authorAvatar: communityPost.user.avatar,
                    content: communityPost.content,
                    mediaUrls: videoUrl.isNotEmpty ? [videoUrl] : imageUrls,
                    type: videoUrl.isNotEmpty
                        ? 'video'
                        : (imageUrls.isNotEmpty ? 'image' : 'text'),
                    likesCount: communityPost.likesCount,
                    commentsCount: communityPost.commentsCount,
                    isLiked: communityPost.isLikedByCurrentUser,
                    formattedTime: communityPost.formattedTime,
                    isOwner: widget.currentUserId == communityPost.user.id,
                    onLike: () => _toggleLike(communityPost, index),
                    onDelete: () => _deletePost(communityPost, index),
                    onShare: () => _sharePost(communityPost),
                    context: context,
                    onEdit: widget.currentUserId == communityPost.user.id
                        ? () => _showEditPostModal(communityPost, index)
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showCreatePostModal() {
    _postController.clear();
    _selectedMedia.clear();
    _selectedLocation = null;
    _locationName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Create Post',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.cardTextSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _postController,
                        maxLines: 5,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.cardTextSecondary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      if (_selectedMedia.isNotEmpty) ...[
                        SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedMedia.length,
                            itemBuilder: (context, index) {
                              final file = _selectedMedia[index];
                              final isVideo = _isVideoFile(file.path);

                              return Container(
                                width: 180,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: isVideo
                                          ? VideoPreviewWidget(videoFile: file)
                                          : Image.file(
                                              File(file.path),
                                              width: 180,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: AppColors.cardBorder,
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            _selectedMedia.removeAt(index);
                                            if (_selectedMedia.isEmpty) {}
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: AppColors.textPrimary,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isVideo)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'VIDEO',
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (!isVideo && _selectedMedia.length > 1)
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${index + 1}/${_selectedMedia.length}',
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _uploadButton(
                            icon: LucideIcons.image,
                            label: 'Images',
                            onTap: () => _pickImages(setModalState),
                          ),
                          SizedBox(width: 12),
                          _uploadButton(
                            icon: LucideIcons.video,
                            label: 'Video',
                            onTap: () => _pickVideo(setModalState),
                          ),
                          SizedBox(width: 12),
                          _uploadButton(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            onTap: () => _pickLocation(setModalState),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      buildButton('Post', null, _createPost, true),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isVideoFile(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi') ||
        path.toLowerCase().endsWith('.mkv');
  }

  Widget _uploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages(Function setModalState) async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setModalState(() {
          _selectedMedia.addAll(images);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _pickVideo(Function setModalState) async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setModalState(() {
          _selectedMedia.clear();
          _selectedMedia.add(video);
        });
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Widget _createPostBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _showCreatePostModal,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppAvatar(src: widget.currentUserAvatar, size: 38),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "What's on your mind?",
                  style: GoogleFonts.inter(
                    color: AppColors.cardTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.image_outlined,
                color: AppColors.cardTextSecondary,
                size: 22,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.videocam_outlined,
                color: AppColors.cardTextSecondary,
                size: 22,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.location_on_outlined,
                color: AppColors.cardTextSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load posts',
              style: GoogleFonts.inter(color: AppColors.cardTextSecondary),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPosts(reset: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
