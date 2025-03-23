import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralizes all theme-related configurations for the application
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color constants
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _primaryContainerLight = Color(0xFFDBEAFE);
  static const Color _secondaryLight = Color(0xFF8B5CF6);
  static const Color _secondaryContainerLight = Color(0xFFEDE9FE);
  static const Color _surfaceLight = Color(0xFFF9FAFB);
  static const Color _errorLight = Color(0xFFEF4444);
  static const Color _borderLight = Color(0xFFD1D5DB);

  static const Color _primaryDark = Color(0xFF60A5FA);
  static const Color _primaryContentDark = Color(0xFF1F2937);
  static const Color _primaryContainerDark = Color(0xFF1E40AF);
  static const Color _secondaryDark = Color(0xFFA78BFA);
  static const Color _surfaceDark = Color(0xFF1F2937);
  static const Color _errorDark = Color(0xFFF87171);

  /// Returns the light theme for the application
  static ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      ),
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        primaryContainer: _primaryContainerLight,
        secondary: _secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: _secondaryContainerLight,
        surface: _surfaceLight,
        error: _errorLight,
        onError: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Returns the dark theme for the application
  static ThemeData getDarkTheme(BuildContext context) {
    return ThemeData.dark(useMaterial3: true).copyWith(
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: _primaryContentDark,
        primaryContainer: _primaryContainerDark,
        secondary: _secondaryDark,
        onSecondary: _primaryContentDark,
        surface: _surfaceDark,
        error: _errorDark,
        onError: _primaryContentDark,
      ),
      cardTheme: CardTheme(
        color: _surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
