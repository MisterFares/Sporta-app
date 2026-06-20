import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  final double size;
  const DefaultAvatar({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primary.withOpacity(0.9),
        size: size * 0.55,
      ),
    );
  }
}
