import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedColor = 'purple';

  bool get isDarkMode => _isDarkMode;
  String get selectedColor => _selectedColor;
  
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  ThemeService() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(AppConstants.darkModeKey) ?? false;
      _selectedColor = prefs.getString('theme_color') ?? 'purple';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.darkModeKey, isDark);
    } catch (e) {
      debugPrint('Error saving dark mode preference: $e');
    }
  }

  Future<void> setThemeColor(String colorName) async {
    _selectedColor = colorName;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_color', colorName);
    } catch (e) {
      debugPrint('Error saving theme color: $e');
    }
  }

  void toggleTheme() {
    setDarkMode(!_isDarkMode);
  }
}