import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = true;
  
  static Color get background => isDarkMode ? const Color(0xFF0F1115) : Colors.grey[50]!;
  static Color get drawerBackground => isDarkMode ? const Color(0xFF161C1A) : Colors.white;
  static Color get cardBackground => isDarkMode ? const Color(0xFF161C1A) : Colors.white;
  static Color get cardBorder => isDarkMode ? const Color(0xFF232B28) : Colors.grey[300]!;
  static Color get cardTextSecondary => isDarkMode ? const Color(0xFF8B949E) : Colors.grey[600]!;
  static Color get surface => isDarkMode ? const Color(0xFF181A20) : Colors.grey[100]!;
  static Color get border => isDarkMode ? const Color(0xFF27272A) : Colors.grey[400]!;
  static Color get primary => isDarkMode ? const Color(0xFFD4FF00) : Color.fromARGB(255, 27, 114, 108);
  static Color get textPrimary => isDarkMode ? Colors.white : Colors.black;
  static Color get textSecondary => isDarkMode ? const Color(0xFFA1A1AA) : Colors.grey[600]!;
  static Color get notActive => isDarkMode ? const Color(0xFF232B28) : Colors.grey[300]!;
  static Color get imgHeader1 => isDarkMode ? const Color(0xFF1F2926) : Colors.grey[200]!;
  static Color get imgHeader2 => isDarkMode ? const Color(0xFF161C1A) : Colors.grey[100]!;
  static Color get btnSecondary => isDarkMode ? const Color(0xFF0B0F0E) : Colors.grey[200]!;
  static Color get active => isDarkMode ? const Color(0x22C7F000) : Colors.black.withOpacity(0.1);
  static Color get secondaryBtnBorder => isDarkMode ? const Color(0xFF232B28) : Colors.grey[300]!;
  static Color get secondaryBtnText => isDarkMode ? const Color(0xFF8B949E) : Colors.grey[700]!;
  static Color get secondaryBtn => isDarkMode ? const Color(0xFF1F2926) : Colors.grey[200]!;
  static Color get red => const Color(0xFFFF453A);
  static Color get orange => const Color(0xFFFF7900);
  static Color get vodafone => const Color(0xFFE60000);
  static Color get greeen => const Color(0xFF00C853);
  static Color get silver => const Color(0xFFC0C0C0);
  static Color get bronze => const Color(0xFFCD7F32);
  static Color get gold => const Color(0xFFFFD700);
}