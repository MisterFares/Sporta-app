import 'package:fit/models/coach/store_front_tier.dart';
import 'package:fit/screens/coach_programs/my_programs_screen2.dart';
import 'package:fit/screens/store/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fit/models/coach/program.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/screens/profile/program_card.dart';
import 'package:fit/screens/profile/program_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgramsSection extends StatefulWidget {
  final bool isOwner;
  final String role;
  final String userId; // Add this - pass the coach/user ID

  const ProgramsSection({
    super.key,
    required this.isOwner,
    required this.role,
    required this.userId,
  });

  @override
  State<ProgramsSection> createState() => _ProgramsSectionState();
}

class _ProgramsSectionState extends State<ProgramsSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.role.toLowerCase() != 'trainer') {
      return const SizedBox.shrink();
    }

    return _ProgramsContent(isOwner: widget.isOwner, userId: widget.userId);
  }
}

class _ProgramsContent extends StatefulWidget {
  final bool isOwner;
  final String userId;

  const _ProgramsContent({required this.isOwner, required this.userId});

  @override
  State<_ProgramsContent> createState() => _ProgramsContentState();
}

class _ProgramsContentState extends State<_ProgramsContent> {
  List<StorefrontTier> _tiers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedTierId = '';
  Program? _viewingProgram;
  List<String> _subscribedIds = []; // Changed to String
  String? _subscribingId;
  bool _isSubscribing = false;
  String? _currentSubscribingId;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  int _currentVisibleIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadStorefrontData();
    _loadSubscriptions();
    _scrollController.addListener(_checkScroll);
  }

  Future<void> _loadStorefrontData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tiers = await ApiService.getProfileStorefront(widget.userId);
      setState(() {
        _tiers = tiers;
        _isLoading = false;
        if (_tiers.isNotEmpty) {
          _selectedTierId = _tiers[0].id;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('subscribed_programs') ?? [];
    setState(() {
      _subscribedIds = saved;
    });
    print("🔍 Loaded subscriptions: $_subscribedIds");
  }

  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subscribed_programs', _subscribedIds);
    print("🔍 Saved subscriptions: $_subscribedIds");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  StorefrontTier get _selectedTier {
    return _tiers.firstWhere(
      (t) => t.id == _selectedTierId,
      orElse: () => _tiers.isNotEmpty
          ? _tiers[0]
          : StorefrontTier(id: '', isActive: false, benefits: [], programs: []),
    );
  }

  List<Program> get _filteredPrograms {
    return _selectedTier.programs;
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;

    final scrollLeft = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    setState(() {
      _canScrollLeft = scrollLeft > 5;
      _canScrollRight = scrollLeft < maxScroll - 5;
    });

    if (_scrollController.hasClients && _filteredPrograms.isNotEmpty) {
      final itemWidth = 300.0;
      final gap = 16.0;
      final scrollPosition = _scrollController.position.pixels;
      final index =
          ((scrollPosition + MediaQuery.of(context).size.width / 2) /
                  (itemWidth + gap))
              .floor();
      setState(() {
        _currentVisibleIndex = (index + 1).clamp(1, _filteredPrograms.length);
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.position.pixels - 316,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.position.pixels + 316,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSubscribe(Program prog) async {
    if (_isSubscribing || _subscribedIds.contains(prog.id)) return;

    setState(() {
      _isSubscribing = true;
      _subscribingId = prog.id;
      _currentSubscribingId = prog.id;
    });

    await _saveSubscriptions();

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            paymentType: 'program',
            amount: prog.finalPrice,
            programName: prog.title,
            programId: prog.id,
          ),
        ),
      );

      // After returning from payment, refresh data
      await _loadStorefrontData();

      print("🔍 AFTER REFRESH - Subscribed IDs: $_subscribedIds");
      print(
        "🔍 AFTER REFRESH - Is this program subscribed? ${_subscribedIds.contains(prog.id)}",
      );

      // 👇 ADD THIS: Mark as subscribed locally
      setState(() {
        _subscribedIds.add(prog.id);
      });

      // Also update the local program object
      setState(() {
        final allPrograms = _tiers.expand((t) => t.programs).toList();
        for (var p in allPrograms) {
          if (p.id == prog.id) {
            // @ts-ignore - we're adding a field to the program object
            p.isSubscribed = true;
            p.isAllowedToSubscribe = false;
          } else {
            // @ts-ignore
            p.isAllowedToSubscribe = false;
          }
        }
      });

      print("✅ Subscribed to: ${prog.id}");
      print("✅ Subscribed IDs: $_subscribedIds");
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && _currentSubscribingId == prog.id) {
        setState(() {
          _isSubscribing = false;
          _subscribingId = null;
          _currentSubscribingId = null;
        });
      }
    }
  }

  bool _hasAnySubscription() {
    return _subscribedIds.isNotEmpty;
  }

  bool get _isLockedForUser => !_selectedTier.isActive && !widget.isOwner;

  IconData _getTierIcon(String tierId) {
    switch (tierId) {
      case 'bronze':
        return LucideIcons.award;
      case 'silver':
        return LucideIcons.shield;
      case 'gold':
        return LucideIcons.crown;
      default:
        return LucideIcons.circle;
    }
  }

  Color _getTierColor(String tierId) {
    switch (tierId) {
      case 'bronze':
        return AppColors.bronze;
      case 'silver':
        return AppColors.silver;
      case 'gold':
        return AppColors.gold;
      default:
        return AppColors.primary;
    }
  }

  String _getTierSubtitle(String tierId) {
    switch (tierId) {
      case 'bronze':
        return 'Essential Foundation';
      case 'silver':
        return 'Advanced Results';
      case 'gold':
        return 'Elite Performance';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Error loading programs: $_errorMessage',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coaching Programs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              _buildTierSelector(),
              const SizedBox(height: 24),

              _isLockedForUser
                  ? _buildLockedContent()
                  : _buildProgramsContent(),
            ],
          ),
        ),

        if (_viewingProgram != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: ProgramModal(
                  program: _viewingProgram!,
                  onClose: () => setState(() => _viewingProgram = null),
                  isSubscribed: _subscribedIds.contains(_viewingProgram!.id),
                  isSubscribing: _subscribingId == _viewingProgram!.id,
                  onSubscribe: () => _handleSubscribe(_viewingProgram!),
                  isOwner: widget.isOwner,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTierSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tiers.length,
        itemBuilder: (context, index) {
          final tier = _tiers[index];
          final isActive = _selectedTierId == tier.id;
          final tierColor = _getTierColor(tier.id);
          final tierIcon = _getTierIcon(tier.id);
          final isLockedTab = !tier.isActive && !widget.isOwner;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTierId = tier.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? tierColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isActive
                        ? tierColor.withOpacity(0.4)
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tierIcon,
                      size: 14,
                      color: isActive ? tierColor : AppColors.cardTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tier.id.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? tierColor
                            : AppColors.cardTextSecondary,
                      ),
                    ),
                    if (isLockedTab) ...[
                      const SizedBox(width: 6),
                      Icon(
                        LucideIcons.lock,
                        size: 10,
                        color: AppColors.cardTextSecondary,
                      ),
                    ],
                    if (!tier.isActive && widget.isOwner) ...[
                      const SizedBox(width: 6),
                      Icon(
                        LucideIcons.eyeOff,
                        size: 10,
                        color: isActive
                            ? tierColor
                            : AppColors.cardTextSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedContent() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.lock,
                size: 24,
                color: AppColors.cardTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Access Restricted',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enrollment for the ${_selectedTier.id.toUpperCase()} tier is currently closed.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.cardTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsContent() {
    final tierColor = _getTierColor(_selectedTierId);
    final filteredPrograms = _filteredPrograms;
    final isOverflowing = filteredPrograms.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTierSubtitle(_selectedTier.id),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tierColor,
          ),
        ),
        const SizedBox(height: 16),

        if (_selectedTier.benefits.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedTier.benefits.map((benefit) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.05),
                  border: Border.all(color: tierColor.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 14, color: tierColor),
                    const SizedBox(width: 8),
                    Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        if (_selectedTier.benefits.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.cardTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'The coach hasn\'t added any features for this tier yet.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cardTextSecondary,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        if (filteredPrograms.isEmpty)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTierIcon(_selectedTier.id),
                    size: 28,
                    color: AppColors.cardTextSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No programs available in ${_selectedTier.id.toUpperCase()} right now.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.cardTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.isOwner) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyProgramsScreen2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tierColor,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('+ Create Program'),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 380,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredPrograms.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      child: ProgramCard(
                        program: filteredPrograms[index],
                        isSubscribed: _subscribedIds.contains(
                          filteredPrograms[index].id,
                        ),
                        isSubscribing:
                            _subscribingId == filteredPrograms[index].id,
                        onSubscribe: () =>
                            _handleSubscribe(filteredPrograms[index]),
                        onTap: () => setState(
                          () => _viewingProgram = filteredPrograms[index],
                        ),
                        isOwner: widget.isOwner,
                        hasAnySubscription: _hasAnySubscription(),
                      ),
                    );
                  },
                ),
              ),

              if (isOverflowing)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withOpacity(0.1),
                          border: Border.all(color: tierColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentVisibleIndex.toString().padLeft(2, '0')} / ${filteredPrograms.length.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _canScrollLeft ? _scrollLeft : null,
                            icon: Icon(
                              Icons.chevron_left,
                              color: _canScrollLeft
                                  ? AppColors.textPrimary
                                  : AppColors.cardTextSecondary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.cardBackground,
                              side: BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _canScrollRight ? _scrollRight : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: _canScrollRight
                                  ? AppColors.textPrimary
                                  : AppColors.cardTextSecondary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.cardBackground,
                              side: BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
