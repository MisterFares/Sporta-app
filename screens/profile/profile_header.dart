import 'dart:io';

import 'package:fit/models/profile/follower.dart';
import 'package:fit/models/profile/following.dart';
import 'package:fit/models/profile/user_profile.dart';
import 'package:fit/screens/messages/chat_room.dart';
import 'package:fit/screens/profile/app_avatar.dart';
import 'package:fit/screens/profile/base_sheet.dart';
import 'package:fit/screens/profile/cover_section.dart';
import 'package:fit/screens/profile/default_cover.dart';
import 'package:fit/screens/profile/outline_button.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile userProfile;
  final bool isOwner;
  final ValueChanged<UserProfile> onUpdate;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.isOwner,
    required this.onUpdate,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // Followers/Following state
  List<Follower> _followers = [];
  List<FollowingUser> _following = [];
  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;
  int _followersPage = 1;
  int _followingPage = 1;
  int _followersTotalPages = 1;
  int _followingTotalPages = 1;
  String _followersRoleFilter = 'All';
  String _followingRoleFilter = 'All';
  String _followersSearchQuery = '';
  String _followingSearchQuery = '';
  bool _bioExpanded = false;
  String? _localAvatarPath;
  final ImagePicker _picker = ImagePicker();
  static const _maxBio = 180;

  Future<void> _uploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      final File imageFile = File(image.path);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final result = await ApiService.uploadProfileImage(imageFile);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success']) {
        // Refresh profile data from server
        final updatedProfile = await ApiService.getUserProfile(
          widget.userProfile.userId,
        );

        if (context.mounted) {
          setState(() {
            _localAvatarPath = null; // Clear local preview
          });
          widget.onUpdate(updatedProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Avatar updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading avatar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteAvatar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F1412),
        title: Text('Delete Avatar'),
        content: Text('Are you sure you want to remove your avatar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog
              Navigator.pop(ctx);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              try {
                // Call API to delete profile image
                final result = await ApiService.deleteProfileImage();

                if (!context.mounted) return;
                Navigator.pop(context); // Close loading

                if (result['success']) {
                  // Refresh profile data
                  final updatedProfile = await ApiService.getUserProfile(
                    widget.userProfile.userId,
                  );

                  if (context.mounted) {
                    setState(() {
                      _localAvatarPath = null;
                    });
                    widget.onUpdate(updatedProfile);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Avatar deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fetch followers with pagination and filters
  Future<void> _fetchFollowers({bool loadMore = false}) async {
    if (_isLoadingFollowers) return;
    if (loadMore && _followersPage >= _followersTotalPages) return;

    setState(() {
      _isLoadingFollowers = true;
    });

    try {
      final response = await ApiService.getUserFollowers(
        userId: widget.userProfile.userId,
        pageNumber: loadMore ? _followersPage + 1 : 1,
        pageSize: 20,
      );

      setState(() {
        if (loadMore) {
          _followers.addAll(response.followers);
          _followersPage = response.currentPage;
        } else {
          _followers = response.followers;
          _followersPage = response.currentPage;
        }
        _followersTotalPages = response.totalPages;
        _isLoadingFollowers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFollowers = false;
      });
      print('Error fetching followers: $e');
    }
  }

  // Fetch following with pagination and filters
  Future<void> _fetchFollowing({bool loadMore = false}) async {
    if (_isLoadingFollowing) return;
    if (loadMore && _followingPage >= _followingTotalPages) return;

    setState(() {
      _isLoadingFollowing = true;
    });

    try {
      final response = await ApiService.getUserFollowing(
        userId: widget.userProfile.userId,
        pageNumber: loadMore ? _followingPage + 1 : 1,
        pageSize: 20,
      );

      setState(() {
        if (loadMore) {
          _following.addAll(response.following);
          _followingPage = response.currentPage;
        } else {
          _following = response.following;
          _followingPage = response.currentPage;
        }
        _followingTotalPages = response.totalPages;
        _isLoadingFollowing = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFollowing = false;
      });
      print('Error fetching following: $e');
    }
  }

  // Get filtered followers
  List<Follower> get _filteredFollowers {
    return _followers.where((follower) {
      // Role filter
      if (_followersRoleFilter != 'All' &&
          follower.role.toLowerCase() != _followersRoleFilter.toLowerCase()) {
        return false;
      }
      // Search filter
      if (_followersSearchQuery.isNotEmpty) {
        return follower.name.toLowerCase().contains(
          _followersSearchQuery.toLowerCase(),
        );
      }
      return true;
    }).toList();
  }

  // Get filtered following
  List<FollowingUser> get _filteredFollowing {
    return _following.where((user) {
      // Role filter
      if (_followingRoleFilter != 'All' &&
          user.role.toLowerCase() != _followingRoleFilter.toLowerCase()) {
        return false;
      }
      // Search filter
      if (_followingSearchQuery.isNotEmpty) {
        return user.fullName.toLowerCase().contains(
          _followingSearchQuery.toLowerCase(),
        );
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final d = widget.userProfile;
      final isLong = (d.about?.length ?? 0) > _maxBio;
      final bioText = _bioExpanded
          ? (d.about ?? '')
          : (d.about ?? '').substring(
              0,
              (d.about?.length ?? 0).clamp(0, _maxBio),
            );
      final loc = [
        d.country,
        d.city,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder),
            top: BorderSide(color: AppColors.cardBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── COVER ──
            CoverSection(
              cover: d.coverImageUrl,
              isOwner: widget.isOwner, // Disabled - no cover editing
              onCoverChanged: (newCoverPath) {
                // Disabled - no cover editing
                /* Original code commented out
                setState(() {
                  final updatedData = UserProfile(
                    userId: d.userId,
                    fullName: d.fullName,
                    email: d.email,
                    role: d.role,
                    birthDate: d.birthDate,
                    followersCount: d.followersCount,
                    followingCount: d.followingCount,
                    receivedRecommendationsCount:
                        d.receivedRecommendationsCount,
                    givenRecommendationsCount: d.givenRecommendationsCount,
                    isFollowedByCurrentUser: d.isFollowedByCurrentUser,
                    isBlockedByCurrentUser: d.isBlockedByCurrentUser,
                    canMessage: d.canMessage,
                    hasBlockedTarget: d.hasBlockedTarget,
                  );
                  widget.onUpdate(updatedData);
                });
                */
              },
            ),

            // ── AVATAR + EDIT ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(0, -30),
                    child: GestureDetector(
                      onTap: () => _showImagePreview(
                        context,
                        d.profileImageUrl,
                        'avatar',
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 3,
                          ),
                        ),
                        child: AppAvatar(
                          src:
                              _localAvatarPath ??
                              ImageUrlHelper.getFullImageUrl(
                                d.profileImageUrl,
                              ) ??
                              '',
                          size: 90,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  if (widget.isOwner)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: outlineButton(
                        Icons.edit_outlined,
                        'Edit',
                        () => _showEditModal(context),
                      ),
                    ),
                  if (!widget.isOwner)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: _moreMenuButton(),
                    ),
                ],
              ),
            ),

            // ── INFO ──
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    d.fullName.isNotEmpty ? d.fullName : 'No name',
                    style: GoogleFonts.inter(
                      color: d.fullName.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.cardTextSecondary.withOpacity(0.6),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  // Specialization (trainer only)
                  if (d.isTrainer &&
                      (widget.isOwner ||
                          (d.specialization?.isNotEmpty ?? false))) ...[
                    SizedBox(height: 2),
                    Text(
                      d.specialization?.isNotEmpty == true
                          ? d.specialization!.toUpperCase()
                          : 'ADD SPECIALIZATION',
                      style: GoogleFonts.inter(
                        color: d.specialization?.isNotEmpty == true
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        fontStyle: d.specialization?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],

                  // Rating + clients (trainer only)
                  if (d.isTrainer) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${d.rating ?? '--'}',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${d.reviewsCount ?? 0})',
                          style: GoogleFonts.inter(
                            color: AppColors.cardTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        _dot(),
                        // Text(
                        //   '${d.clients ?? 0} clients',
                        //   style: GoogleFonts.inter(
                        //     color: AppColors.cardTextSecondary,
                        //     fontSize: 12,
                        //   ),
                        // ),
                      ],
                    ),
                  ],

                  // Location + followers + contact
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (loc.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.cardTextSecondary,
                              size: 12,
                            ),
                            SizedBox(width: 3),
                            Text(
                              loc,
                              style: GoogleFonts.inter(
                                color: AppColors.cardTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      if (loc.isNotEmpty) _dot(),
                      GestureDetector(
                        onTap: () => _showFollowersModal(context),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${widget.userProfile.followersCount} ',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: widget.userProfile.followersCount == 1
                                    ? 'follower'
                                    : 'followers',
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _dot(),
                      GestureDetector(
                        onTap: () => _showFollowingModal(context),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${widget.userProfile.followingCount} ',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'following',
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _dot(),
                      GestureDetector(
                        onTap: () => _showContactModal(context),
                        child: Text(
                          'Contact Info',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Follow + Message buttons (not owner)
                  if (!widget.isOwner) ...[
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await ApiService.toggleFollowUser(
                                userId: widget.userProfile.userId,
                              );
                              if (result['success']) {
                                // Refresh the profile to update the followers count and follow status
                                final updatedProfile =
                                    await ApiService.getUserProfile(
                                      widget.userProfile.userId,
                                    );
                                widget.onUpdate(updatedProfile);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    widget.userProfile.isFollowedByCurrentUser
                                    ? AppColors.cardBorder
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  widget.userProfile.isFollowedByCurrentUser
                                      ? 'Following'
                                      : 'Follow',
                                  style: GoogleFonts.inter(
                                    color:
                                        widget
                                            .userProfile
                                            .isFollowedByCurrentUser
                                        ? AppColors.textPrimary
                                        : Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoom(
                                    userId: widget.userProfile.userId,
                                    userName: widget.userProfile.fullName,
                                    userAvatar:
                                        widget.userProfile.profileImageUrl,
                                    onBack: () => Navigator.pop(context),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF5A5D66)),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  'Message',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // About / Bio
                  if (widget.isOwner || (d.about?.isNotEmpty ?? false)) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.cardBackground,
                            AppColors.cardBackground.withOpacity(0.8),
                          ],
                        ),
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                color: AppColors.cardTextSecondary,
                                fontSize: 13,
                                height: 1.6,
                              ),
                              children: [
                                TextSpan(
                                  text: (d.about?.isNotEmpty ?? false)
                                      ? bioText
                                      : 'No bio yet',
                                  style: (d.about?.isNotEmpty ?? false)
                                      ? null
                                      : GoogleFonts.inter(
                                          color: AppColors.cardTextSecondary
                                              .withOpacity(0.5),
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                ),
                                if (!_bioExpanded && isLong)
                                  TextSpan(text: '... '),
                                if (isLong)
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _bioExpanded = !_bioExpanded,
                                      ),
                                      child: Text(
                                        _bioExpanded ? 'Show less' : 'More',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e, stacktrace) {
      print('ERROR in ProfileHeader build: $e');
      print('Stacktrace: $stacktrace');
      return Container(
        color: Colors.red,
        child: Center(child: Text('Error: $e')),
      );
    }
  }

  Widget _dot() => Container(
    width: 4,
    height: 4,
    margin: EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: AppColors.cardBorder,
      shape: BoxShape.circle,
    ),
  );

  Widget _moreMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: AppColors.cardTextSecondary,
        size: 18,
      ),
      color: Color(0xFF0F1412),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      onSelected: (value) {
        if (value == 'report') {
          _showReportDialog();
        } else if (value == 'block') {
          _showBlockDialog();
        } else if (value == 'share') {
          _showShareOptions();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 20,
                color: AppColors.cardTextSecondary,
              ),
              SizedBox(width: 10),
              Text(
                'Report User',
                style: TextStyle(color: AppColors.cardTextSecondary),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.block_outlined, size: 20, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text('Block User', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColors.cardTextSecondary,
              ),
              SizedBox(width: 10),
              Text(
                'Share Profile',
                style: TextStyle(color: AppColors.cardTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F1412),
        title: Text('Report User'),
        content: Text('Are you sure you want to report this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User reported')));
            },
            child: Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F1412),
        title: Text('Block User'),
        content: Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User blocked')));
            },
            child: Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF0F1412),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.copy_outlined),
              title: Text('Copy Profile Link'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Profile link copied!')));
              },
            ),
            ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text('Share via...'),
              onTap: () {
                Navigator.pop(ctx);
                // Add share functionality here
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imagePreviewDialog({
    required String? imageUrl,
    required String type,
    required bool isOwner,
  }) {
    // Convert to full URL using your existing helper
    final fullImageUrl = ImageUrlHelper.getFullImageUrl(imageUrl);

    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: type == 'avatar'
                ? AppAvatar(
                    src: fullImageUrl,
                    size: 300, // Large size for preview
                  )
                : DefaultCover(),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
          if (isOwner)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _previewBtn(Icons.upload_rounded, 'Change', () {
                    Navigator.pop(context);
                    _uploadAvatar();
                  }),
                  SizedBox(width: 12),
                  _previewBtn(Icons.delete_outline_rounded, 'Remove', () {
                    Navigator.pop(context);
                    _deleteAvatar();
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _previewBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 16),
            SizedBox(width: 6),
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
    );
  }

  void _showEditModal(BuildContext ctx) {
    // Create controllers with current values
    final nameController = TextEditingController(
      text: widget.userProfile.fullName,
    );
    final bioController = TextEditingController(
      text: widget.userProfile.about ?? '',
    );
    final countryController = TextEditingController(
      text: widget.userProfile.country ?? '',
    );
    final cityController = TextEditingController(
      text: widget.userProfile.city ?? '',
    );
    final phoneController = TextEditingController(
      text: widget.userProfile.phone ?? '',
    );
    final addressController = TextEditingController(
      text: widget.userProfile.address ?? '',
    );
    final emailController = TextEditingController(
      text: widget.userProfile.email,
    );

    // Parse birth date
    DateTime? selectedBirthDate;
    if (widget.userProfile.birthDate.isNotEmpty) {
      try {
        selectedBirthDate = DateTime.parse(widget.userProfile.birthDate);
      } catch (e) {
        selectedBirthDate = null;
      }
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Tab Bar
                    TabBar(
                      tabs: [
                        Tab(text: 'Basic Info'),
                        Tab(text: 'Contact Info'),
                      ],
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.cardTextSecondary,
                    ),
                    // Tab Bar View - Add Expanded and Flexible here
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Basic Info Tab
                          SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField('Full Name', nameController),
                                SizedBox(height: 12),
                                _buildTextField(
                                  'Bio',
                                  bioController,
                                  maxLines: 4,
                                ),
                                SizedBox(height: 12),
                                _buildTextField('Country', countryController),
                                SizedBox(height: 12),
                                _buildTextField('City', cityController),
                              ],
                            ),
                          ),
                          // Contact Info Tab
                          SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField('Phone', phoneController),
                                SizedBox(height: 12),
                                _buildTextField('Address', addressController),
                                SizedBox(height: 12),
                                _buildTextField('Email', emailController),
                                SizedBox(height: 12),
                                _buildDatePickerField(
                                  'Birth Date',
                                  selectedBirthDate,
                                  (date) {
                                    selectedBirthDate = date;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Buttons
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: BorderSide(color: AppColors.cardBorder),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  // Update Basic Info
                                  final basicResult =
                                      await ApiService.updateBasicProfile(
                                        fullName: nameController.text,
                                        about: bioController.text,
                                        country: countryController.text,
                                        city: cityController.text,
                                      );

                                  if (!basicResult['success']) {
                                    throw Exception(basicResult['message']);
                                  }

                                  // Update Contact Info
                                  if (selectedBirthDate != null) {
                                    final contactResult =
                                        await ApiService.updateContactInfo(
                                          phone: phoneController.text,
                                          address: addressController.text,
                                          email: emailController.text,
                                          birthDate: selectedBirthDate!,
                                        );

                                    if (!contactResult['success']) {
                                      throw Exception(contactResult['message']);
                                    }
                                  }

                                  // Refresh profile data
                                  final updatedProfile =
                                      await ApiService.getUserProfile(
                                        widget.userProfile.userId,
                                      );

                                  if (context.mounted) {
                                    Navigator.pop(context); // Close loading
                                    Navigator.pop(context); // Close edit modal
                                    widget.onUpdate(updatedProfile);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Profile updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context); // Close loading
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 12),
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
      },
    );
  }

  Widget _buildDatePickerField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.cardTextSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: Colors.black,
                      surface: Color(0xFF0F1412),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  style: GoogleFonts.inter(
                    color: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.cardTextSecondary,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.cardTextSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showFollowersModal(BuildContext ctx) {
    if (_followers.isEmpty) {
      _fetchFollowers();
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Followers (${widget.userProfile.followersCount})',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Search
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search followers...',
                      hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.cardTextSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBorder.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        _followersSearchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 12),
                // Role filter tabs
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('All', _followersRoleFilter, (value) {
                        setModalState(() {
                          _followersRoleFilter = value;
                        });
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip('Trainer', _followersRoleFilter, (
                        value,
                      ) {
                        setModalState(() {
                          _followersRoleFilter = value;
                        });
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip('Trainee', _followersRoleFilter, (
                        value,
                      ) {
                        setModalState(() {
                          _followersRoleFilter = value;
                        });
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Followers list
                Expanded(
                  child: _isLoadingFollowers
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _filteredFollowers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: AppColors.cardTextSecondary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No followers found',
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          itemCount:
                              _filteredFollowers.length +
                              (_isLoadingFollowers ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredFollowers.length) {
                              return Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final follower = _filteredFollowers[index];
                            return ListTile(
                              leading: AppAvatar(
                                src:
                                    ImageUrlHelper.getFullImageUrl(
                                      follower.avatar,
                                    ) ??
                                    '',
                                size: 44,
                              ),
                              title: Text(
                                follower.name,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                follower.title,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                follower.time,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(
                                      userProfile: null,
                                      isOwner: false,
                                    ),
                                    settings: RouteSettings(
                                      arguments: follower.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // Reset filters when closed
      _followersSearchQuery = '';
      _followersRoleFilter = 'All';
      _followersPage = 1;
    });
  }

  void _showFollowingModal(BuildContext ctx) {
    if (_following.isEmpty) {
      _fetchFollowing();
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Following (${widget.userProfile.followingCount})',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Search
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search following...',
                      hintStyle: TextStyle(color: AppColors.cardTextSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.cardTextSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBorder.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        _followingSearchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 12),
                // Role filter tabs
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('All', _followingRoleFilter, (value) {
                        setModalState(() {
                          _followingRoleFilter = value;
                        });
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip('Trainer', _followingRoleFilter, (
                        value,
                      ) {
                        setModalState(() {
                          _followingRoleFilter = value;
                        });
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip('Trainee', _followingRoleFilter, (
                        value,
                      ) {
                        setModalState(() {
                          _followingRoleFilter = value;
                        });
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Following list
                Expanded(
                  child: _isLoadingFollowing
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _filteredFollowing.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: AppColors.cardTextSecondary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No following found',
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          itemCount:
                              _filteredFollowing.length +
                              (_isLoadingFollowing ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredFollowing.length) {
                              return Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final user = _filteredFollowing[index];
                            return ListTile(
                              leading: AppAvatar(
                                src:
                                    ImageUrlHelper.getFullImageUrl(
                                      user.profileImageUrl,
                                    ) ??
                                    '',
                                size: 44,
                              ),
                              title: Text(
                                user.fullName,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user.role,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: OutlinedButton(
                                onPressed: () async {
                                  final result =
                                      await ApiService.toggleFollowUser(
                                        userId: user.id,
                                      );
                                  if (result['success']) {
                                    setModalState(() {
                                      user.isFollowedByCurrentUser =
                                          result['isFollowing'];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result['isFollowing']
                                              ? 'Following!'
                                              : 'Unfollowed',
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: user.isFollowedByCurrentUser
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  backgroundColor: user.isFollowedByCurrentUser
                                      ? Colors.transparent
                                      : AppColors.primary,
                                  side: BorderSide(
                                    color: user.isFollowedByCurrentUser
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  user.isFollowedByCurrentUser
                                      ? 'Following'
                                      : 'Follow',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(
                                      userProfile: null,
                                      isOwner: false,
                                    ),
                                    settings: RouteSettings(arguments: user.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      _followingSearchQuery = '';
      _followingRoleFilter = 'All';
      _followingPage = 1;
    });
  }

  Widget _buildFilterChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = selectedValue == label;
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primary,
      side: BorderSide(color: AppColors.cardBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _contactSheet({required UserProfile userProfile}) {
    final items = <Map<String, dynamic>>[];

    // Phone
    if (userProfile.phone?.isNotEmpty == true) {
      items.add({
        'icon': Icons.phone_outlined,
        'label': 'Phone',
        'value': userProfile.phone,
      });
    }

    // Email
    if (userProfile.email.isNotEmpty) {
      items.add({
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': userProfile.email,
      });
    }

    // Address (using country + city)
    final addressParts = <String>[];
    if (userProfile.country?.isNotEmpty == true)
      addressParts.add(userProfile.country!);
    if (userProfile.city?.isNotEmpty == true)
      addressParts.add(userProfile.city!);
    if (userProfile.address?.isNotEmpty == true)
      addressParts.add(userProfile.address!);

    if (addressParts.isNotEmpty) {
      items.add({
        'icon': Icons.location_on_outlined,
        'label': 'Address',
        'value': addressParts.join(', '),
      });
    }

    // LinkedIn
    if (userProfile.linkedInUrl?.isNotEmpty == true) {
      items.add({
        'icon': Icons.link_outlined,
        'label': 'LinkedIn',
        'value': userProfile.linkedInUrl,
      });
    }

    return SheetBase(
      title: 'Contact Info',
      draggable: true,
      maxHeight: 0.55,
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.contact_page_outlined,
                      color: AppColors.cardTextSecondary,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No contact information available',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['label'] as String,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['value'] as String,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  void _showImagePreview(BuildContext ctx, String? img, String type) {
    showDialog(
      context: ctx,
      barrierColor: Colors.black87,
      builder: (_) => _imagePreviewDialog(
        imageUrl: img,
        type: type,
        isOwner: widget.isOwner,
      ),
    );
  }

  void _showContactModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _contactSheet(userProfile: widget.userProfile),
    );
  }
}
