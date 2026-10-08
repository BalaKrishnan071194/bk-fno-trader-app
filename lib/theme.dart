/// App Theme — Light and Dark themes for F&O Trading App
library;

import 'package:flutter/material.dart';

class AppTheme {
  // Shared Colors
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);
  static const Color purple = Color(0xFF8B5CF6);

  // Dark Theme Colors
  static const Color darkBgPrimary = Color(0xFF0A0A0F);
  static const Color darkBgSecondary = Color(0xFF18181B);
  static const Color darkBgTertiary = Color(0xFF27272A);
  static const Color darkTextPrimary = Color(0xFFE4E4E7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkBorder = Color(0xFF3F3F46);

  // Light Theme Colors
  static const Color lightBgPrimary = Color(0xFFF8FAFC);
  static const Color lightBgSecondary = Color(0xFFFFFFFF);
  static const Color lightBgTertiary = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Legacy constants (for existing code compatibility with const contexts)
  // Use context.textSec, context.cardBg etc. for theme-aware colors in widgets
  static const Color bgPrimary = lightBgPrimary;
  static const Color bgSecondary = lightBgSecondary;
  static const Color bgTertiary = lightBgTertiary;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color border = lightBorder;

  // Badge colors
  static const Color callBadgeBg = Color(0xFF166534);
  static const Color callBadgeText = Color(0xFF22C55E);
  static const Color putBadgeBg = Color(0xFF991B1B);
  static const Color putBadgeText = Color(0xFFFCA5A5);

  // Light badge colors
  static const Color lightCallBadgeBg = Color(0xFFDCFCE7);
  static const Color lightCallBadgeText = Color(0xFF166534);
  static const Color lightPutBadgeBg = Color(0xFFFEE2E2);
  static const Color lightPutBadgeText = Color(0xFF991B1B);

  // Theme mode is handled by ThemeData - use context extensions for dynamic colors

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBgPrimary,

      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: blue,
        surface: lightBgSecondary,
        error: primaryRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightBgSecondary,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: lightBorder,
      ),

      cardTheme: CardThemeData(
        color: lightBgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightBorder),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightBgSecondary,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightTextPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: lightTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: lightTextPrimary),
        bodySmall: TextStyle(fontSize: 12, color: lightTextSecondary),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: lightTextSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          side: const BorderSide(color: lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),

      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),

      popupMenuTheme: PopupMenuThemeData(
        color: lightBgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightBorder),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: lightBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: const TextStyle(color: lightBgPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBgPrimary,

      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: blue,
        surface: darkBgSecondary,
        error: primaryRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBgSecondary,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: darkBgTertiary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBgTertiary,
        selectedItemColor: primaryGreen,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextPrimary),
        bodySmall: TextStyle(fontSize: 12, color: darkTextSecondary),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: darkTextSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen),
        ),
      ),

      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),

      popupMenuTheme: PopupMenuThemeData(
        color: darkBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkTextPrimary,
        contentTextStyle: const TextStyle(color: darkBgPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Extension for easy theme-aware color access
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get profit => AppTheme.primaryGreen;
  Color get loss => AppTheme.primaryRed;
  Color get cardBg => isDark ? AppTheme.darkBgTertiary : AppTheme.lightBgTertiary;
  Color get textSec => isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get borderColor => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get surfaceBg => isDark ? AppTheme.darkBgSecondary : AppTheme.lightBgSecondary;
}
