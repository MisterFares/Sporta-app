import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class DefaultCertIcon extends StatelessWidget {
  const DefaultCertIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Icon(Icons.workspace_premium_rounded,
          color: AppColors.primary, size: 32),
    );
  }
}
