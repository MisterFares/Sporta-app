import 'package:fit/services/theme_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    AppColors.isDarkMode = _isDarkMode; // Add this line
    notifyListeners();
  }
}