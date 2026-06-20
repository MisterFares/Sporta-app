import 'package:fit/models/profile/recommendations.dart';
import 'package:fit/screens/profile/all_recs_sheet.dart';
import 'package:fit/screens/profile/app_avatar.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/screens/profile/tab_chip.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationsSection extends StatefulWidget {
  final String userId;
  final bool isOwner;

  const RecommendationsSection({
    super.key,
    required this.userId,
    required this.isOwner,
  });

  @override
  State<RecommendationsSection> createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  String _tab = 'received';
  bool _expanded = false;
  static const _maxLen = 400;

  // State for recommendations
  List<Recommendation> _receivedRecs = [];
  List<Recommendation> _givenRecs = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Recommendation> get _current =>
      _tab == 'received' ? _receivedRecs : _givenRecs;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getUserRecommendations(
        userId: widget.userId,
      );
      print("🔍 Received recommendations: ${response.received.length}");
      print(
        "🔍 First received: ${response.received.isNotEmpty ? response.received.first.toJson() : 'none'}",
      );
      print(
        "🔍 First given: ${response.given.isNotEmpty ? response.given.first.toJson() : 'none'}",
      );
      setState(() {
        _receivedRecs = response.received;
        _givenRecs = response.given;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _current.take(1).toList();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              Text(
                'Recommendations',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              if (!widget.isOwner)
                GestureDetector(
                  onTap: () => _showAddDropdown(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.cardTextSecondary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // loading state
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          // error state
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load recommendations',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _loadRecommendations,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // tabs
            Row(
              children: [
                TabChip(
                  label: 'Received (${_receivedRecs.length})',
                  selected: _tab == 'received',
                  onTap: () => setState(() {
                    _tab = 'received';
                    _expanded = false;
                  }),
                ),
                SizedBox(width: 8),
                TabChip(
                  label: 'Given (${_givenRecs.length})',
                  selected: _tab == 'given',
                  onTap: () => setState(() {
                    _tab = 'given';
                    _expanded = false;
                  }),
                ),
              ],
            ),
            SizedBox(height: 16),

            // content
            if (displayed.isEmpty)
              Text(
                'No recommendations yet',
                style: GoogleFonts.inter(
                  color: AppColors.cardTextSecondary.withOpacity(0.4),
                  fontSize: 14,
                ),
              )
            else
              ...displayed.map((rec) {
                final isLong = rec.content.length > _maxLen;
                final text = _expanded
                    ? rec.content
                    : rec.content.substring(
                        0,
                        rec.content.length.clamp(0, _maxLen),
                      );
                final avatarUrl =
                    ImageUrlHelper.getFullImageUrl(rec.targetImageUrl) ?? '';
                final name = rec.targetName;
                final role = rec.targetSpecialization;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userProfile: null, isOwner: false,), settings: RouteSettings(arguments: rec.targetUserId)));
                          },
                          child: AppAvatar(
                            src: avatarUrl,
                            size: 44,
                            borderWidth: 1,
                            borderColor: AppColors.cardBorder,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                role,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary
                                      .withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isOwner && _tab == 'given')
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.cardTextSecondary,
                              size: 20,
                            ),
                            color: Color(0xFF0F1412),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmDialog(rec);
                              }
                            },
                            itemBuilder: (context) => [
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
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(text: text),
                          if (!_expanded && isLong) TextSpan(text: '... '),
                          if (isLong)
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                child: Text(
                                  _expanded ? 'less' : 'more',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_current.length > 1) ...[
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showAllRecs(context),
                        child: Text(
                          'Show all ${_current.length} recommendations',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
          ],
        ],
      ),
    );
  }

  void _showAddDropdown(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _quickRecommendationSheet(),
    );
  }

  Widget _quickRecommendationSheet() {
    return Container(
      height: 180,
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
          SizedBox(height: 16),
          _option(Icons.format_quote_rounded, 'Ask for a recommendation', () {
            Navigator.pop(context);
            _showFullScreenModal(type: 'ask');
          }),
          Divider(height: 1, color: AppColors.cardBorder),
          _option(Icons.add_comment_outlined, 'Give a recommendation', () {
            Navigator.pop(context);
            _showFullScreenModal(type: 'give');
          }),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _option(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenModal({required String type}) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.95),
          child: SafeArea(
            child: Column(
              children: [
                // Header with close button
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        type == 'ask'
                            ? 'Ask for a Recommendation'
                            : 'Give a Recommendation',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        _buildTextField(
                          'Recommendation Message',
                          textController,
                          maxLines: 6,
                        ),
                        SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: BorderSide(color: AppColors.cardBorder),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (textController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please enter a message'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Show loading
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  Map<String, dynamic> result;
                                  if (type == 'ask') {
                                    result =
                                        await ApiService.sendRecommendationRequest(
                                          receiverId: widget.userId,
                                          content: textController.text,
                                        );
                                  } else {
                                    result =
                                        await ApiService.giveRecommendation(
                                          receiverId: widget.userId,
                                          content: textController.text,
                                        );
                                  }

                                  if (!context.mounted) return;
                                  Navigator.pop(context); // Close loading

                                  if (result['success']) {
                                    print(
                                      "🔍 Recommendation posted successfully",
                                    );
                                    print(
                                      "🔍 Response data: ${result['data']}",
                                    );
                                    await _loadRecommendations();
                                    Navigator.pop(context); // Close modal
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          type == 'ask'
                                              ? 'Recommendation request sent!'
                                              : 'Recommendation given!',
                                        ),
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
                                child: Text(
                                  type == 'ask' ? 'Request' : 'Submit',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(Recommendation rec) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F1412),
        title: Text('Delete Recommendation'),
        content: SingleChildScrollView(
          child: Text(
            'Are you sure you want to delete this recommendation?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
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
              Navigator.pop(ctx); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              final result = await ApiService.deleteRecommendation(
                recommendationId: rec.id,
              );

              if (!context.mounted) return;
              Navigator.pop(context); // Close loading

              if (result['success']) {
                await _loadRecommendations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recommendation deleted!'),
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
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

  void _showAllRecs(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllRecsSheet(
        received: _receivedRecs,
        given: _givenRecs,
        initialTab: _tab,
      ),
    );
  }
}
