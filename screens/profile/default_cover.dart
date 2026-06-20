import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pattern_box/pattern_box.dart';

class DefaultCover extends StatelessWidget {
  const DefaultCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Stack(
        children: [
          // dots texture effect
          Opacity(
            opacity: 0.04,
            child: CustomPaint(
              painter: DotsPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          // Blobs
          Positioned(
            top: -24, left: -24,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -32, right: -16,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          // Brand center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _gradientLine(),
                const SizedBox(height: 16),
                Text(
                  'SPORTA',
                  style: GoogleFonts.inter(
                    color: AppColors.primary.withOpacity(0.85),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 10,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _gradientLine(),
              ],
            ),
          ),
          // fitness icons
          ..._buildIcons(),
        ],
      ),
    );
  }

  Widget _gradientLine() => Container(
        width: 100,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.primary.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
      );

  List<Widget> _buildIcons() {
    final icons = [
      Icons.fitness_center_rounded,
      Icons.emoji_events_rounded,
      Icons.favorite_rounded,
      Icons.bolt_rounded,
      Icons.timer_rounded,
      Icons.sports_gymnastics_rounded,
    ];
    final positions = [
      const Offset(0.08, 0.1),
      const Offset(0.25, 0.2),
      const Offset(0.85, 0.15),
      const Offset(0.06, 0.65),
      const Offset(0.2, 0.75),
      const Offset(0.88, 0.55),
    ];
    return List.generate(icons.length, (i) {
      return Positioned.fill(
        child: FractionallySizedBox(
          alignment: Alignment(
            positions[i].dx * 2 - 1,
            positions[i].dy * 2 - 1,
          ),
          child: Icon(icons[i],
              color: AppColors.primary.withOpacity(0.2), size: 28),
        ),
      );
    });
  }
}
