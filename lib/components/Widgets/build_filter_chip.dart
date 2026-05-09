import 'package:fit/classes/filter_option.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class BuildFilterChip extends StatefulWidget {
  final FilterOption filter;
  final bool isActive;
  final ValueChanged<String>? onFilterSelected;

  const BuildFilterChip({
    super.key,
    required this.filter,
    required this.isActive,
    this.onFilterSelected,
  });

  @override
  State<BuildFilterChip> createState() => _BuildFilterChipState();
}

class _BuildFilterChipState extends State<BuildFilterChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onFilterSelected != null) {
          widget.onFilterSelected!(widget.filter.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: widget.isActive
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primary],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1D21), Color(0xFF0F1115)],
                ),
          border: Border.all(
            color: widget.isActive
                ? AppColors.primary
                : AppColors.border.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.filter.icon != null) ...[
              Icon(
                widget.filter.icon,
                size: 16,
                color: widget.isActive ? Colors.black : const Color(0xFF8B949E),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.filter.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.black : const Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
