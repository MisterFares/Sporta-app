import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_filters.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/models/notification/filter_option.dart';
import 'package:fit/screens/coach/subscriptions_screen.dart';
import 'package:fit/models/notification/notification.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onNotificationsChanged;
  final String? role;

  const NotificationsScreen({
    super.key,
    this.onNotificationsChanged,
    required this.role,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  List<FilterOption> get _filters {
    if (widget.role == 'trainer') {
      return [
        FilterOption(id: 'all', label: 'All', icon: LucideIcons.layers),
        FilterOption(id: 'social', label: 'Social', icon: LucideIcons.users),
        FilterOption(id: 'clients', label: 'Clients', icon: LucideIcons.user),
        FilterOption(
          id: 'finance',
          label: 'Finance',
          icon: LucideIcons.dollarSign,
        ),
        FilterOption(
          id: 'store',
          label: 'Store',
          icon: LucideIcons.shoppingBag,
        ),
        FilterOption(
          id: 'system',
          label: 'System',
          icon: LucideIcons.settings2,
        ),
      ];
    } else {
      return [
        FilterOption(id: 'all', label: 'All', icon: LucideIcons.layers),
        FilterOption(id: 'social', label: 'Social', icon: LucideIcons.users),
        FilterOption(id: 'trainer', label: 'Trainer', icon: LucideIcons.user),
        FilterOption(
          id: 'store',
          label: 'Store',
          icon: LucideIcons.shoppingBag,
        ),
        FilterOption(
          id: 'system',
          label: 'System',
          icon: LucideIcons.settings2,
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _notifications = [];
        _currentPage = 1;
      });
    }

    try {
      final response = await ApiService.getNotifications(
        pageNumber: reset ? 1 : _currentPage + 1,
        pageSize: 15,
      );

      setState(() {
        if (reset) {
          _notifications = response.items;
        } else {
          _notifications.addAll(response.items);
        }
        _currentPage = response.currentPage;
        _totalPages = response.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });

      widget.onNotificationsChanged?.call();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadNotifications(reset: false);
  }

  Future<void> _markAsRead(String notificationId) async {
    final result = await ApiService.markNotificationAsRead(
      notificationId: notificationId,
    );

    if (result['success']) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index].isRead = true;
        }
      });

      widget.onNotificationsChanged?.call();
    }
  }

  Future<void> _markAllAsRead() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Mark All as Read'),
        content: const Text(
          'Are you sure you want to mark all notifications as read?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Mark All', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final result = await ApiService.markAllNotificationsAsRead();

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (result['success']) {
      // Mark all local notifications as read
      setState(() {
        for (var notification in _notifications) {
          notification.isRead = true;
        }
      });

      widget.onNotificationsChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.category == _selectedFilter).toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    return Scaffold(
      appBar: MyAppBar(
        drawerIcon: Icons.menu,
        title: 'Notifications',
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: widget.role == 'trainer' ? 6 : 3,
        role: widget.role,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: pageHeader(
                'Stay updated with your training, orders, and coach messages.',
              ),
            ),

            buildFilters(_filters, _selectedFilter, (filterId) {
              setState(() {
                _selectedFilter = filterId;
              });
            }),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _errorMessage != null
                  ? _buildErrorState()
                  : filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(reset: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: _filteredNotifications.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredNotifications.length && _isLoadingMore) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final notification = _filteredNotifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () async {
        if (isUnread) {
          await _markAsRead(notification.id);
        }
        _handleNotificationTap(notification);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUnread
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.primary, AppColors.cardBackground],
                  stops: [0.0, 0.01],
                )
              : null,
          color: isUnread ? null : AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isUnread
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.textPrimary.withOpacity(0.03),
                border: Border.all(
                  color: isUnread
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getIconForNotification(notification),
                size: 20,
                color: isUnread ? AppColors.primary : const Color(0xFF8B949E),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitleForNotification(notification),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: isUnread
                          ? AppColors.textPrimary
                          : const Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B949E),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.formattedTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B949E),
                  ),
                ),
                const SizedBox(height: 8),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC7F000),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForNotification(AppNotification notification) {
    final title = notification.title;
    if (title == 'Follow') {
      return Icons.person_add_outlined;
    } else if (title == 'NewRecommendation') {
      return Icons.rate_review_outlined;
    } else if (title == 'RecommendationRequest') {
      return Icons.help_outline;
    } else if (title == 'CoachAccountApproved') {
      return Icons.verified_outlined;
    }
    return Icons.notifications_outlined;
  }

  String _getTitleForNotification(AppNotification notification) {
    final title = notification.title;
    if (title == 'Follow') {
      return 'New Follower';
    } else if (title == 'NewRecommendation') {
      return 'New Recommendation';
    } else if (title == 'RecommendationRequest') {
      return 'Recommendation Request';
    } else if (title == 'CoachAccountApproved') {
      return 'Account Approved!';
    }
    return title;
  }

  void _handleNotificationTap(AppNotification notification) {
    final title = notification.title;
    if (title == 'Follow' || title == 'RecommendationRequest') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(userProfile: null, isOwner: false),
          settings: RouteSettings(arguments: notification.relatedEntityId),
        ),
      );
    } else if (title == 'NewSubscription') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SubscriptionsScreen()),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Failed to load notifications',
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadNotifications(reset: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: AppColors.cardBackground,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(fontSize: 14, color: AppColors.cardTextSecondary),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
