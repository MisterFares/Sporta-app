import 'package:fit/models/profile/recommendations.dart';
import 'package:fit/screens/profile/app_avatar.dart';
import 'package:fit/screens/profile/base_sheet.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/screens/profile/tab_chip.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllRecsSheet extends StatefulWidget {
  final List<Recommendation> received;
  final List<Recommendation> given;
  final String initialTab;

  const AllRecsSheet({
    super.key, 
    required this.received,
    required this.given,
    required this.initialTab,
  });

  @override
  State<AllRecsSheet> createState() => _AllRecsSheetState();
}

class _AllRecsSheetState extends State<AllRecsSheet> {
  late String _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 'received' ? widget.received : widget.given;
    
    return SheetBase(
      title: 'Recommendations',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                TabChip(
                  label: 'Received (${widget.received.length})',
                  selected: _tab == 'received',
                  onTap: () => setState(() => _tab = 'received'),
                ),
                const SizedBox(width: 8),
                TabChip(
                  label: 'Given (${widget.given.length})',
                  selected: _tab == 'given',
                  onTap: () => setState(() => _tab = 'given'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.cardBorder, height: 24),
              itemBuilder: (_, i) {
                final rec = list[i];
                
                // 👇 USE TARGET FIELDS (SAME FOR BOTH TABS)
                final avatarUrl = ImageUrlHelper.getFullImageUrl(rec.targetImageUrl) ?? '';
                final name = rec.targetName.isNotEmpty ? rec.targetName : 'Unknown';
                final role = rec.targetSpecialization.isNotEmpty ? rec.targetSpecialization : '';
                final date = rec.createdAt;
                final formattedDate = '${date.month}/${date.day}/${date.year}';
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              userProfile: null,
                              isOwner: false,
                            ),
                            settings: RouteSettings(
                              arguments: rec.targetUserId,
                            ),
                          ),
                        );
                      },
                      child: AppAvatar(src: avatarUrl, size: 44),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                userProfile: null,
                                isOwner: false,
                              ),
                              settings: RouteSettings(
                                arguments: rec.targetUserId,
                              ),
                            ),
                          );
                        },
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
                            if (role.isNotEmpty)
                              Text(
                                role,
                                style: GoogleFonts.inter(
                                  color: AppColors.cardTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              rec.content,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary.withOpacity(0.8),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: GoogleFonts.inter(
                                color: AppColors.cardTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}