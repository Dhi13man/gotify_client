import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gotify_client/models/enums.dart';

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
  static const Color _borderLight = Color(0xFFD1D5DB);

  static const Color _primaryDark = Color(0xFF60A5FA);
  static const Color _primaryContentDark = Color(0xFF1F2937);
  static const Color _primaryContainerDark = Color(0xFF1E40AF);
  static const Color _secondaryDark = Color(0xFFA78BFA);
  static const Color _surfaceDark = Color(0xFF1F2937);
  static const Color _errorDark = Color(0xFFF87171);

  // Text colors
  static const Color _textPrimaryLight = Color(0xFF6B7280);
  static const Color _textSecondaryLight = Colors.black87;

  static const Color _textPrimaryDark = Colors.white;
  static const Color _textSecondaryDark = Color(0xFF9CA3AF);

  // Priority colors - standardized and centralized
  static const Color _priorityMaxLight = Color(0xFFB91C1C); // Red-700
  static const Color _priorityHighLight = Color(0xFFEA580C); // Orange-600
  static const Color _priorityMediumLight = Color(0xFFD97706); // Amber-600
  static const Color _priorityLowLight = Color(0xFF059669); // Emerald-600
  static const Color _priorityMinLight = Color(0xFFD1D5DB); // Gray-300

  static const Color _priorityMaxDark = Color(0xFFF87171); // Red-400
  static const Color _priorityHighDark = Color(0xFFFB923C); // Orange-400
  static const Color _priorityMediumDark = Color(0xFFFBBF24); // Amber-400
  static const Color _priorityLowDark = Color(0xFF34D399); // Emerald-400
  static const Color _priorityMinDark = Color(0xFF9CA3AF); // Gray-400

  // Background colors
  static const Color _backgroundLight = Color(0xFFF9FAFB);
  static const Color _backgroundDark = Color(0xFF1F2937);

  // Border colors
  static const Color _borderDark = Color(0xFF374151);

  /// Returns the light theme for the application
  static ThemeData getLightTheme(BuildContext context) {
    final ThemeData baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      primaryTextTheme: _getTextTheme(baseTheme, _textPrimaryLight),
      textTheme: _getTextTheme(baseTheme, _textSecondaryLight),
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
    final ThemeData baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      primaryTextTheme: _getTextTheme(baseTheme, _textPrimaryDark),
      textTheme: _getTextTheme(baseTheme, _textSecondaryDark),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Helper method for priority colors
  static Color getPriorityColor(BuildContext context, int priority) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final PriorityType priorityType = PriorityType.fromNumeric(priority);

    switch (priorityType) {
      case PriorityType.max:
        return isLightMode ? _priorityMaxLight : _priorityMaxDark;
      case PriorityType.high:
        return isLightMode ? _priorityHighLight : _priorityHighDark;
      case PriorityType.medium:
        return isLightMode ? _priorityMediumLight : _priorityMediumDark;
      case PriorityType.low:
        return isLightMode ? _priorityLowLight : _priorityLowDark;
      case PriorityType.min:
        return isLightMode ? _priorityMinLight : _priorityMinDark;
      default:
        return Theme.of(context)
            .colorScheme
            .primary; // Default to primary color
    }
  }

  static TextTheme _getTextTheme(ThemeData themeData, Color color) {
    return GoogleFonts.interTextTheme(
      themeData.textTheme.copyWith(
        displayLarge: themeData.textTheme.displayLarge?.copyWith(color: color),
        displayMedium:
            themeData.textTheme.displayMedium?.copyWith(color: color),
        displaySmall: themeData.textTheme.displaySmall?.copyWith(color: color),
        headlineLarge:
            themeData.textTheme.headlineLarge?.copyWith(color: color),
        headlineMedium:
            themeData.textTheme.headlineMedium?.copyWith(color: color),
        headlineSmall:
            themeData.textTheme.headlineSmall?.copyWith(color: color),
        titleLarge: themeData.textTheme.titleLarge?.copyWith(color: color),
        titleMedium: themeData.textTheme.titleMedium?.copyWith(color: color),
        titleSmall: themeData.textTheme.titleSmall?.copyWith(color: color),
        bodyLarge: themeData.textTheme.bodyLarge?.copyWith(color: color),
        bodyMedium: themeData.textTheme.bodyMedium?.copyWith(color: color),
        bodySmall: themeData.textTheme.bodySmall?.copyWith(color: color),
        labelLarge: themeData.textTheme.labelLarge?.copyWith(color: color),
        labelMedium: themeData.textTheme.labelMedium?.copyWith(color: color),
        labelSmall: themeData.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _borderLight
        : _borderDark;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _backgroundLight
        : _backgroundDark;
  }
}
