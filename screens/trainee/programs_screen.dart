import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/models/trainee/coach_programs_model.dart';
import 'package:fit/screens/trainee/program_card.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'view_program_screen.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _getCycleLabel(String uploadDate, String duration) {
  try {
    final formats = ['MMM dd, yyyy', 'MMM d, yyyy'];
    DateTime? startDate;
    // ignore: unused_local_variable
    for (final fmt in formats) {
      try {
        startDate = _parseDate(uploadDate);
        break;
      } catch (_) {}
    }
    if (startDate == null) return duration;

    final months = int.tryParse(duration.split(' ').first) ?? 0;
    final endDate = DateTime(
      startDate.year,
      startDate.month + months,
      startDate.day,
    );

    final startLabel = _formatMonthYear(startDate);
    final endLabel = _formatMonthYear(endDate);
    return '$startLabel - $endLabel ($duration)';
  } catch (_) {
    return duration;
  }
}

DateTime _parseDate(String dateStr) {
  // E.g. "May 14, 2026" → DateTime
  final months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  final parts = dateStr.replaceAll(',', '').split(' ');
  final month = months[parts[0]] ?? 1;
  final day = int.tryParse(parts[1]) ?? 1;
  final year = int.tryParse(parts[2]) ?? 2025;
  return DateTime(year, month, day);
}

String _formatMonthYear(DateTime date) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month]} ${date.year}';
}

// ─── Programs Screen ─────────────────────────────────────────────────────────

class ProgramsScreen extends StatefulWidget {
  final String? coachId;
  const ProgramsScreen({super.key, this.coachId});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  List<ProgramFile> _programFiles = [];
  List<AvailablePeriod> _availablePeriods = [];
  bool _isLoading = true;
  final Map<String, DownloadState> _downloadStates = {};
  final TextEditingController _searchController = TextEditingController();
  String _activeRoute = 'workout';
  String _selectedPeriod = 'All Time';
  String _searchTerm = '';
  bool _isPeriodDropdownOpen = false;

  bool get _hasNutritionAccess =>
      _programFiles.any((p) => p.routeType == 'nutrition');

  bool get _hasDataForCurrentRoute {
    return _programFiles.any((p) {
      if (_activeRoute == 'workout') {
        return p.routeType == 'workout' || p.routeType == 'category';
      }
      return p.routeType == _activeRoute;
    });
  }

  List<Map<String, String>> get _periodOptions {
    final cycles = _programFiles
        .map((p) => _getCycleLabel(p.uploadDate, p.duration))
        .toSet()
        .toList();
    return [
      {'label': 'All Time', 'value': 'All Time'},
      ...cycles.map((c) => {'label': c, 'value': c}),
    ];
  }

  List<ProgramFile> get _filteredPrograms {
    return _programFiles.where((p) {
      final matchesRoute = _activeRoute == 'workout'
          ? (p.routeType == 'workout' || p.routeType == 'category')
          : p.routeType == _activeRoute;
      final matchesPeriod =
          _selectedPeriod == 'All Time' ||
          _getCycleLabel(p.uploadDate, p.duration) == _selectedPeriod;
      final matchesSearch =
          _searchTerm.isEmpty ||
          p.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          p.trainerName.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesRoute && matchesPeriod && matchesSearch;
    }).toList();
  }

  int get _programsInPeriod {
    return _programFiles.where((p) {
      final matchesRoute = _activeRoute == 'workout'
          ? (p.routeType == 'workout' || p.routeType == 'category')
          : p.routeType == _activeRoute;
      final matchesPeriod =
          _selectedPeriod == 'All Time' ||
          _getCycleLabel(p.uploadDate, p.duration) == _selectedPeriod;
      return matchesRoute && matchesPeriod;
    }).length;
  }

  void _handleDownload(ProgramFile prog) {
    if (prog.fileUrl.isEmpty) return;
    setState(() => _downloadStates[prog.fileId] = DownloadState.downloading);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _downloadStates[prog.fileId] = DownloadState.success);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _downloadStates[prog.fileId] = DownloadState.idle);
      });
    });
  }

  void _handleViewProgram(ProgramFile prog) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViewProgramScreen(
          fileUrl: prog.fileUrl,
          fileType: prog.uploadType.toLowerCase(),
        ),
      ),
    );
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.coachId == null) {
        throw Exception('Coach ID is required');
      }

      print(
        "🆔 Loading programs for coachId: ${widget.coachId}",
      ); // 👈 ADD THIS

      final data = await ApiService.getCoachPrograms(coachId: widget.coachId!);

      print(
        "📦 Programs data: ${data.files.length} files found",
      ); // 👈 ADD THIS

      setState(() {
        _programFiles = data.files;
        _availablePeriods = data.availablePeriods;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading programs: $e"); // 👈 ADD THIS
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'My Programs',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulseDot(),
                        SizedBox(width: 6),
                        Text(
                          'ACTIVE SUBSCRIPTION',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () {
                if (_isPeriodDropdownOpen) {
                  setState(() => _isPeriodDropdownOpen = false);
                }
              },
              child: Column(
                children: [
                  // ── HEADER ──
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pageHeader(
                      'Access your workout and nutrition programs.',
                    ),
                  ),

                  // ── BODY ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Route tabs (Workout / Nutrition)
                          _buildRouteTabs(),

                          const SizedBox(height: 24),

                          // Search + Filter
                          if (_hasDataForCurrentRoute) ...[
                            _buildSearchAndFilter(),
                            const SizedBox(height: 24),
                          ],

                          // Program grid or empty state
                          _buildProgramsContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildRouteTabs() {
    return Row(
      children: [
        Expanded(
          child: _RouteTab(
            icon: Icons.fitness_center_rounded,
            title: 'Workout',
            subtitle: 'Strength & conditioning programs',
            isActive: _activeRoute == 'workout',
            isLocked: false,
            onTap: () => setState(() => _activeRoute = 'workout'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RouteTab(
            icon: Icons.eco_rounded,
            title: 'Nutrition',
            subtitle: 'Dietary templates & meal systems',
            isActive: _activeRoute == 'nutrition',
            isLocked: !_hasNutritionAccess,
            onTap: () {
              if (_hasNutritionAccess) {
                setState(() => _activeRoute = 'nutrition');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          // Search field
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: buildSearchInput(
              _searchController,
              (val) => setState(() => _searchTerm = val),
              'Search programs...',
            ),
          ),
          const SizedBox(height: 10),

          // 👇 REPLACE THE CUSTOM DROPDOWN WITH THIS
          DropdownButtonFormField<String>(
            value: _selectedPeriod,
            isExpanded: true,
            dropdownColor: AppColors.cardBackground,
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            items: _periodOptions.map((opt) {
              return DropdownMenuItem(
                value: opt['value']!,
                child: Text(opt['label']!),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedPeriod = val!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsContent() {
    if (!_hasDataForCurrentRoute) {
      return _EmptyState(
        icon: _activeRoute == 'workout'
            ? Icons.fitness_center_rounded
            : Icons.apple_rounded,
        title: 'No programs uploaded yet',
        subtitle: _activeRoute == 'workout'
            ? "Your coach hasn't uploaded any workout programs for you yet."
            : 'Nutrition plans will appear here once uploaded by your coach.',
        actionLabel: null,
        onAction: null,
      );
    }

    if (_programsInPeriod == 0) {
      return _EmptyState(
        icon: Icons.calendar_today_rounded,
        title: 'No programs in $_selectedPeriod',
        subtitle:
            'There are no $_activeRoute programs uploaded during this specific time cycle.',
        actionLabel: 'View All Time',
        onAction: () => setState(() => _selectedPeriod = 'All Time'),
      );
    }

    if (_filteredPrograms.isEmpty) {
      return _EmptyState(
        icon: Icons.search_rounded,
        title: 'No search results',
        subtitle:
            'We couldn\'t find any $_activeRoute matching "$_searchTerm". Try checking for typos.',
        actionLabel: null,
        onAction: null,
      );
    }

    return Column(
      children: _filteredPrograms.map((prog) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProgramCard(
            prog: prog,
            downloadState: _downloadStates[prog.id] ?? DownloadState.idle,
            subscriptionId: _availablePeriods.first.subscriptionId,
            onDownload: () => _handleDownload(prog),
            onViewProgram: () => _handleViewProgram(prog),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _RouteTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _RouteTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isLocked
        ? const Color(0xFF1B211E).withOpacity(0.4)
        : isActive
        ? AppColors.primary.withOpacity(0.5)
        : AppColors.cardBorder;

    final Color bgColor = isLocked
        ? AppColors.cardBackground.withOpacity(0.4)
        : isActive
        ? AppColors.cardBackground
        : const Color(0xFF0F1412);

    final Color iconBg = isLocked
        ? AppColors.cardBackground.withOpacity(0.5)
        : isActive
        ? AppColors.primary
        : AppColors.cardBackground;

    final Color iconColor = isLocked
        ? const Color(0xFF383F3B)
        : isActive
        ? AppColors.textPrimary
        : AppColors.cardTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive && !isLocked
                      ? AppColors.primary
                      : AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isLocked
                              ? AppColors.cardTextSecondary
                              : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x11FF453A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0x33FF453A),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'LOCKED',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isLocked
                          ? const Color(0xFF3B423F)
                          : AppColors.cardTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(
                Icons.lock_outlined,
                size: 14,
                color: Color(0xFF484F58),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2421),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Icon(icon, color: AppColors.cardTextSecondary, size: 26),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cardTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2421),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
