import 'package:fit/models/trainee/coach_programs_model.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'program_details_modal.dart';

enum DownloadState { idle, downloading, success }

class ProgramCard extends StatefulWidget {
  final ProgramFile prog;
  final DownloadState downloadState;
  final VoidCallback onDownload;
  final VoidCallback onViewProgram;
  final String subscriptionId;

  const ProgramCard({
    super.key,
    required this.prog,
    required this.downloadState,
    required this.onDownload,
    required this.onViewProgram,
    required this.subscriptionId,
  });

  @override
  State<ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<ProgramCard>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
    if (_isMenuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _closeMenu() {
    setState(() => _isMenuOpen = false);
    _menuController.reverse();
  }

  String _truncateNote(String text, {int maxLength = 65}) {
    if (text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Color _getUploadTypeBadgeColor(String type) {
    switch (type.toUpperCase()) {
      case 'VIDEO':
        return AppColors.orange;
      case 'INTERACTIVE':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prog = widget.prog;
    final isWorkout = prog.routeType == 'workout';

    return GestureDetector(
      onTap: _closeMenu,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE SECTION ──
            _buildImageSection(prog),

            // ── CONTENT SECTION ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + menu
                  _buildTitleRow(prog),

                  const SizedBox(height: 12),

                  // Route badge + date
                  _buildBadgeRow(prog, isWorkout),

                  const SizedBox(height: 12),

                  // Coach Notes
                  _buildCoachNotes(prog),

                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: AppColors.cardBorder, height: 1),

                  const SizedBox(height: 14),

                  // Action Buttons
                  _buildActionButtons(prog),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ProgramFile prog) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            prog.thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cardBorder,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.cardTextSecondary,
              ),
            ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.cardBackground.withOpacity(0.9),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),
        // Upload type badge (top left)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 11,
                  color: _getUploadTypeBadgeColor(prog.uploadType),
                ),
                const SizedBox(width: 4),
                Text(
                  prog.uploadType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Duration badge (top right)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Text(
              prog.duration,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(ProgramFile prog) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            prog.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // 3-dot menu
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.cardTextSecondary,
                  size: 18,
                ),
              ),
            ),
            if (_isMenuOpen)
              Positioned(
                right: 0,
                top: 28,
                child: FadeTransition(
                  opacity: _menuAnimation,
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _MenuButton(
                          icon: Icons.flag_outlined,
                          label: 'Report',
                          color: AppColors.textPrimary,
                          onTap: () {
                            _closeMenu();
                            // Report action
                          },
                        ),
                        Divider(height: 1, color: AppColors.cardBorder),
                        _MenuButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          color: AppColors.red,
                          onTap: () {
                            _closeMenu();
                            // Delete action
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeRow(ProgramFile prog, bool isWorkout) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWorkout ? Icons.fitness_center_rounded : Icons.eco_rounded,
                size: 10,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                prog.routeType.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF38423E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.calendar_today_rounded,
          size: 11,
          color: AppColors.cardTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          prog.uploadDate,
          style: TextStyle(
            color: AppColors.cardTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachNotes(ProgramFile prog) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COACH NOTES',
                style: TextStyle(
                  color: AppColors.cardTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => ProgramDetailsModal.show(
                  context,
                  prog,
                  widget.subscriptionId,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          prog.coachNote.isEmpty
              ? Text(
                  'No notes provided.',
                  style: TextStyle(
                    color: AppColors.cardTextSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                )
              : Text(
                  _truncateNote(prog.coachNote),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProgramFile prog) {
    return Row(
      children: [
        // View Program button
        Expanded(
          child: _ActionButton(
            icon: Icons.remove_red_eye_outlined,
            label: 'View Program',
            iconColor: AppColors.primary,
            onTap: widget.onViewProgram,
          ),
        ),
        // Download button (only if canDownload)
        if (prog.canDownload) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _DownloadButton(
              prog: prog,
              downloadState: widget.downloadState,
              onTap: widget.onDownload,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final ProgramFile prog;
  final DownloadState downloadState;
  final VoidCallback onTap;

  const _DownloadButton({
    required this.prog,
    required this.downloadState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = prog.fileUrl.isNotEmpty;
    final isDownloading = downloadState == DownloadState.downloading;
    final isSuccess = downloadState == DownloadState.success;

    Color borderColor = AppColors.cardBorder;
    Color bgColor = AppColors.cardBackground;
    Color textColor = AppColors.textPrimary;

    if (!hasFile) {
      bgColor = AppColors.cardBackground.withOpacity(0.3);
      borderColor = AppColors.cardBorder.withOpacity(0.4);
      textColor = AppColors.cardTextSecondary.withOpacity(0.3);
    } else if (isSuccess) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    Widget child;
    if (isDownloading) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Downloading...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    } else if (isSuccess) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, size: 13, color: AppColors.textPrimary),
          SizedBox(width: 6),
          Text(
            'Downloaded',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 13,
            color: hasFile
                ? AppColors.cardTextSecondary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(width: 6),
          Text(
            'Download',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: hasFile && !isDownloading ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: child,
      ),
    );
  }
}
