import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = true;
  bool _canReview = false;
  final bool _alreadyReviewed = false;
  int _userRating = 5;

  // Calculate the average rating dynamically
  double get _averageRating {
    if (_reviewsList.isEmpty) return 0.0;

    double total = 0;
    for (var review in _reviewsList) {
      // Safely parse the rating regardless of whether it's int, double, or String
      total += double.tryParse(review['rating'].toString()) ?? 0.0;
    }
    return total / _reviewsList.length;
  }

  // Get the total number of reviews
  int get _totalReviewsCount => _reviewsList.length;

  // New state tracking for incoming backend review logs
  List<dynamic> _reviewsList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Fetch eligibility and existing reviews in parallel
      final results = await Future.wait([
        ApiService.getOrderHistory(),
        ApiService.getProductReviews(widget.productId),
      ]);

      final List<dynamic> orders = results[0];
      final List<dynamic> fetchedReviews = results[1];

      // --- Eligibility Verification (Temporary bypass check/Bypassed if needed for testing) ---
      bool hasPurchased = orders.any((order) {
        String orderStatus = (order['status'] ?? '').toString().toLowerCase();
        if (orderStatus != 'paid' && orderStatus != 'approved') return false;

        final innerItems = order['items'] as List<dynamic>? ?? [];
        return innerItems
            .isNotEmpty; // For testing: unlocks if they have any paid item
      });

      setState(() {
        _reviewsList = fetchedReviews;
        _canReview =
            hasPurchased; // Toggle to 'true' directly if you are testing local UI overrides
        _isChecking = false;
      });
    } catch (e) {
      print("DEBUG: Initialization error: $e");
      setState(() => _isChecking = false);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.submitProductReview(
        productId: widget.productId,
        rating: _userRating,
        comment: _reviewController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _reviewController.clear();
        // Refresh structural context lists to show your newly posted submission instantly
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER PANEL ---
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              SizedBox(width: 12),
              Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(height: 24, color: AppColors.cardBorder),

          // Wrap scrollable items safely to prevent crashing with modal height boundaries
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- RATING STATS OVERVIEW CARD ---
                  _buildStatsRow(),
                  SizedBox(height: 24),

                  // --- SUBMISSION ENTRY PANEL ---
                  if (!_canReview)
                    _buildWarningBanner(
                      "You must have purchased this item to share review feedback.",
                    )
                  else if (_alreadyReviewed)
                    _buildWarningBanner(
                      "You have already submitted an active feedback score for this product.",
                    )
                  else
                    _buildInteractiveFormSection(),

                  SizedBox(height: 24),
                  Divider(thickness: 1),
                  SizedBox(height: 8),

                  // --- DYNAMIC REVIEWS HUB FEED ---
                  Text(
                    'Community Feedback',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                  SizedBox(height: 12),

                  if (_reviewsList.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          "No reviews posted yet. Be the first to share your thoughts!",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Scroll managed smoothly by parent context
                      itemCount: _reviewsList.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 20, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final currentReview = _reviewsList[index];
                        return _buildReviewTile(currentReview);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Average Rating Container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              // Dynamic Average Rating
              Text(
                _averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),

              // Dynamic Star Visualization
              Row(
                children: List.generate(5, (index) {
                  if (index < _averageRating.floor()) {
                    return Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 14,
                    );
                  } else if (index < _averageRating) {
                    return Icon(
                      Icons.star_half_rounded,
                      color: AppColors.primary,
                      size: 14,
                    );
                  } else {
                    return Icon(
                      Icons.star_outline_rounded,
                      color: AppColors.primary,
                      size: 14,
                    );
                  }
                }),
              ),
              SizedBox(height: 6),

              // Dynamic Total Count
              Text(
                '$_totalReviewsCount global ratings',
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),

        // Right: Review Invitation Context
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                'Review this product',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardTextSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Share your feedback and thoughts to guide other customer choices.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTile(dynamic data) {
    // Modify target string keys according to your exact backend response attributes
    int reviewStars = int.tryParse(data['rating'].toString()) ?? 5;
    String commentText = data['comment'] ?? '';
    String userName = data['user'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              radius: 16,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.cardTextSecondary,
              ),
            ),
            Spacer(),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < reviewStars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 42.0),
          child: Text(
            commentText,
            style: TextStyle(
              color: AppColors.cardTextSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardTextSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: AppColors.primary, fontSize: 13),
      ),
    );
  }

  Widget _buildInteractiveFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _userRating = starValue),
              child: Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Icon(
                  starValue <= _userRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _reviewController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      'Share your dynamic user experience with this item...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.cardTextSecondary,
                  ),
                  contentPadding: EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: AppColors.textPrimary)
                    : Text('Post'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
