import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabChip(
      {super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.border : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.primary.withOpacity(0.4) : AppColors.cardBorder),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? AppColors.primary : AppColors.cardTextSecondary.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
