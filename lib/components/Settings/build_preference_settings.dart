import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class BuildPreferenceSettings extends StatefulWidget {
  const BuildPreferenceSettings({super.key});

  @override
  State<BuildPreferenceSettings> createState() =>
      _BuildPreferenceSettingsState();
}

class _BuildPreferenceSettingsState extends State<BuildPreferenceSettings> {
  bool _notificationsEnabled = true;
  bool _darkThemeEnabled = true;
  @override
  Widget build(BuildContext context) {
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
        ),
        const SizedBox(height: 12),
        _buildToggleRow(
          'Dark Theme',
          'Use dark color scheme',
          _darkThemeEnabled,
          (value) {
            setState(() {
              _darkThemeEnabled = value;
            });
          },
        ),
      ],
    );
  }
}

Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.cardTextSecondary,
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
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.cardBorder,
          ),
        ],
      ),
    );
  }
