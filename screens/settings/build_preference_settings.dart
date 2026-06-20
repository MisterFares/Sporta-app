import 'package:fit/providers/theme_provider.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildPreferenceSettings extends StatefulWidget {
  const BuildPreferenceSettings({super.key});

  @override
  State<BuildPreferenceSettings> createState() =>
      _BuildPreferenceSettingsState();
}

class _BuildPreferenceSettingsState extends State<BuildPreferenceSettings> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      children: [
        _buildToggleRow(
          'Push Notifications',
          'Receive updates on workouts',
          _notificationsEnabled,
          (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildToggleRow('Dark Mode', 'Use dark color scheme', isDarkMode, (
          value,
        ) {
          AppColors.isDarkMode = !isDarkMode; // Add this line
          themeProvider.toggleTheme();
        }, isDarkMode),
      ],
    );
  }
}

Widget _buildToggleRow(
  String title,
  String subtitle,
  bool value,
  Function(bool) onChanged,
  bool isDarkMode,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.textPrimary : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppColors.cardTextSecondary
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withOpacity(0.5),
          inactiveThumbColor: AppColors.textPrimary,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ],
    ),
  );
}
