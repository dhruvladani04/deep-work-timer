import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeVariant { classic, ocean, lavender, forest }

class AppTheme {
  final String name;
  final Color focusColor;
  final Color breakColor;

  const AppTheme({
    required this.name,
    required this.focusColor,
    required this.breakColor,
  });

  static const classic = AppTheme(
    name: 'Classic',
    focusColor: Colors.deepOrange,
    breakColor: Colors.green,
  );

  static const ocean = AppTheme(
    name: 'Ocean',
    focusColor: Colors.blue,
    breakColor: Colors.cyan,
  );

  static const lavender = AppTheme(
    name: 'Lavender',
    focusColor: Colors.purple,
    breakColor: Colors.pink,
  );

  static const forest = AppTheme(
    name: 'Forest',
    focusColor: Color(0xFF2E7D32), // Dark Green
    breakColor: Color(0xFFCDDC39), // Lime
  );

  static AppTheme fromVariant(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.classic:
        return classic;
      case AppThemeVariant.ocean:
        return ocean;
      case AppThemeVariant.lavender:
        return lavender;
      case AppThemeVariant.forest:
        return forest;
    }
  }
}

class ThemeNotifier extends Notifier<AppThemeVariant> {
  static const _keyTheme = 'deep_work_theme';

  @override
  AppThemeVariant build() {
    _loadTheme();
    return AppThemeVariant.classic;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppThemeVariant.values.length) {
      state = AppThemeVariant.values[themeIndex];
    }
  }

  Future<void> setTheme(AppThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, variant.index);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeVariant>(() {
  return ThemeNotifier();
});
