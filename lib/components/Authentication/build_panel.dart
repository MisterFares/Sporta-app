import 'package:fit/components/Logo/s.dart';
import 'package:fit/components/Logo/sporta.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

Widget buildPanel(
  context,
  String? title,
  String description,
  List<Widget> children,
) {
  final width = MediaQuery.of(context).size.width;
  return SingleChildScrollView(
    child: Center(
      child: Container(
        width: width * 0.9 > 900 ? 900 : width * 0.9,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [S(), const SizedBox(width: 8), sportaLogo()],
              ),
              if (title != null) ...[
                const SizedBox(height: 20),
                Text(
                  textAlign: TextAlign.center,
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                textAlign: TextAlign.center,
                description,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Column(children: children),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}
