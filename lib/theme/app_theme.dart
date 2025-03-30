import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gotify_client/models/enums.dart';

/// Centralizes all theme-related configurations for the application
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Modern Color Palette inspired by contemporary design systems
  // Light theme colors
  static const Color _primaryLight = Color(0xFF5061FF);
  static const Color _primaryContainerLight = Color(0xFFEFF1FF);
  static const Color _secondaryLight = Color(0xFF4A4AFF);
  static const Color _secondaryContainerLight = Color(0xFFE7E7FF);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _errorLight = Color(0xFFE53935);
  static const Color _borderLight = Color(0xFFE5E5E5);
  static const Color _accentLight = Color(0xFF00BFA5);

  // Dark theme colors
  static const Color _primaryDark = Color(0xFF8B9CFF);
  static const Color _primaryContentDark = Color(0xFF1F1F2C);
  static const Color _primaryContainerDark = Color(0xFF3949AB);
  static const Color _secondaryDark = Color(0xFF9FA8DA);
  static const Color _surfaceDark = Color(0xFF1F1F2C);
  static const Color _errorDark = Color(0xFFEF5350);
  static const Color _borderDark = Color(0xFF3F3F5A);
  static const Color _accentDark = Color(0xFF26A69A);
  static const Color _textPrimaryLight = Color(0xFF2E3147);
  static const Color _textSecondaryLight = Color(0xFF6E7191);
  static const Color _textPrimaryDark = Color(0xFFF5F5FC);
  static const Color _textSecondaryDark = Color(0xFFB9BDD1);
  static const Color _backgroundLight = Color(0xFFF7F9FC);
  static const Color _backgroundDark = Color(0xFF14141F);

  // Priority colors
  static const Color _priorityMaxLight = Color(0xFFDC2626);
  static const Color _priorityHighLight = Color(0xFFEA580C);
  static const Color _priorityMediumLight = Color(0xFFD97706);
  static const Color _priorityLowLight = Color(0xFF059669);
  static const Color _priorityMinLight = Color(0xFF9CA3AF);
  static const Color _priorityMaxDark = Color(0xFFEF4444);
  static const Color _priorityHighDark = Color(0xFFF97316);
  static const Color _priorityMediumDark = Color(0xFFF59E0B);
  static const Color _priorityLowDark = Color(0xFF10B981);
  static const Color _priorityMinDark = Color(0xFF6B7280);

  /// Returns the light theme for the application
  static ThemeData getLightTheme(BuildContext context) {
    final ThemeData baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      primaryTextTheme: _getTextTheme(baseTheme, _textPrimaryLight),
      textTheme: _getTextTheme(baseTheme, _textSecondaryLight),
      colorScheme: ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        primaryContainer: _primaryContainerLight,
        secondary: _secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: _secondaryContainerLight,
        surface: _surfaceLight,
        background: _backgroundLight,
        error: _errorLight,
        onError: Colors.white,
        tertiary: _accentLight,
      ),
      cardTheme: CardTheme(
        elevation: 0.8, // More subtle elevation
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _borderLight.withOpacity(0.3), width: 0.5),
        ),
        color: _surfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: _textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _primaryLight, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: _borderLight.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorLight, width: 1),
        ),
        prefixIconColor: _secondaryLight,
        suffixIconColor: _secondaryLight,
        filled: true,
        fillColor: _surfaceLight,
        hintStyle: TextStyle(
          color: _textSecondaryLight.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceLight,
        selectedItemColor: _primaryLight,
        unselectedItemColor: _textSecondaryLight,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryContainerLight,
        disabledColor: _borderLight,
        selectedColor: _primaryLight,
        secondarySelectedColor: _secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _borderLight,
        thickness: 0.5,
        space: 24,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      iconTheme: baseTheme.iconTheme.copyWith(
        color: _secondaryLight,
        size: 24,
      ),
      primaryIconTheme: baseTheme.iconTheme.copyWith(
        color: _primaryLight,
        size: 24,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primaryLight,
        unselectedLabelColor: _textSecondaryLight,
        indicatorColor: _primaryLight,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _surfaceLight,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Returns the dark theme for the application
  static ThemeData getDarkTheme(BuildContext context) {
    final ThemeData baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      primaryTextTheme: _getTextTheme(baseTheme, _textPrimaryDark),
      textTheme: _getTextTheme(baseTheme, _textSecondaryDark),
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: _primaryContentDark,
        primaryContainer: _primaryContainerDark,
        secondary: _secondaryDark,
        onSecondary: _primaryContentDark,
        surface: _surfaceDark,
        background: _backgroundDark,
        error: _errorDark,
        onError: _primaryContentDark,
        tertiary: _accentDark,
      ),
      cardTheme: CardTheme(
        elevation: 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _borderDark.withOpacity(0.3), width: 0.5),
        ),
        color: _surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: _textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _primaryContentDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _primaryDark, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderDark.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorDark, width: 1),
        ),
        prefixIconColor: _secondaryDark,
        suffixIconColor: _secondaryDark,
        filled: true,
        fillColor: _surfaceDark.withOpacity(0.8),
        hintStyle: TextStyle(
          color: _textSecondaryDark.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: _textSecondaryDark,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryContainerDark,
        disabledColor: _borderDark,
        selectedColor: _primaryDark,
        secondarySelectedColor: _secondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: _primaryContentDark,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: _primaryContentDark,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _borderDark,
        thickness: 0.5,
        space: 24,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      iconTheme: baseTheme.iconTheme.copyWith(
        color: _secondaryDark,
        size: 24,
      ),
      primaryIconTheme: baseTheme.iconTheme.copyWith(
        color: _primaryDark,
        size: 24,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primaryDark,
        unselectedLabelColor: _textSecondaryDark,
        indicatorColor: _primaryDark,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _surfaceDark,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Helper method for priority colors
  static Color getPriorityColor(BuildContext context, int priority) {
    final ThemeData theme = Theme.of(context);
    final bool isLightMode = theme.brightness == Brightness.light;
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
        return theme.colorScheme.primary;
    }
  }

  /// Helper method to get text theme with Google Fonts
  static TextTheme _getTextTheme(ThemeData themeData, Color color) {
    return GoogleFonts.interTextTheme(
      themeData.textTheme.copyWith(
        displayLarge: themeData.textTheme.displayLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        displayMedium: themeData.textTheme.displayMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall: themeData.textTheme.displaySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineLarge: themeData.textTheme.headlineLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: themeData.textTheme.headlineMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        headlineSmall: themeData.textTheme.headlineSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: themeData.textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: themeData.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: themeData.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: themeData.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: themeData.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: themeData.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: themeData.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelMedium: themeData.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: themeData.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
