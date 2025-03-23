import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralizes all theme-related configurations for the application
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color constants - updated to match the new design system
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _primaryContainerLight = Color(0xFFDBEAFE);
  static const Color _secondaryLight = Color(0xFF8B5CF6);
  static const Color _secondaryContainerLight = Color(0xFFEDE9FE);
  static const Color _surfaceLight = Color(0xFFF9FAFB);
  static const Color _errorLight = Color(0xFFEF4444);
  static const Color _warningLight = Color(0xFFF59E0B);
  static const Color _successLight = Color(0xFF10B981);
  static const Color _borderLight = Color(0xFFD1D5DB);

  static const Color _primaryDark = Color(0xFF60A5FA);
  static const Color _primaryContentDark = Color(0xFF1F2937);
  static const Color _primaryContainerDark = Color(0xFF1E40AF);
  static const Color _secondaryDark = Color(0xFFA78BFA);
  static const Color _surfaceDark = Color(0xFF1F2937);
  static const Color _errorDark = Color(0xFFF87171);
  static const Color _warningDark = Color(0xFFFBBF24);
  static const Color _successDark = Color(0xFF34D399);

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
        elevation: 1, // Reduced elevation for subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // Updated to white background
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Rounded button style
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryLight,
        unselectedItemColor: Color(0xFF6B7280), // Gray-500
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
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
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937), // Dark background
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: _primaryDark,
        unselectedItemColor: Color(0xFF9CA3AF), // Gray-400
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }

  // New utility methods for accessing semantic colors
  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _warningLight
        : _warningDark;
  }

  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _successLight
        : _successDark;
  }

  // Helper method for priority colors
  static Color getPriorityColor(BuildContext context, int priority) {
    final colorScheme = Theme.of(context).colorScheme;

    if (priority >= 8) return colorScheme.error; // High priority
    if (priority >= 4) return getWarningColor(context); // Medium priority
    return colorScheme.primary; // Low priority
  }
}
