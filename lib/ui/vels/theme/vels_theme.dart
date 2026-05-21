import 'package:flutter/material.dart';

class VelsTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF15397F);      // Primary Dark Blue
  static const Color secondaryBlue = Color(0xFF3B82F6);    // VISTAS Blue Accent
  static const Color textDark = Color(0xFF0F172A);         // Main Slate Dark
  static const Color textLight = Color(0xFF64748B);        // Muted Slate Text
  static const Color backgroundWhite = Colors.white;       // Pure White
  static const Color backgroundGray = Color(0xFFF8FAFC);   // Off-white Slate
  static const Color borderLight = Color(0xFFE2E8F0);      // Soft Border Gray

  // Status/Highlight Colors
  static const Color accentTeal = Color(0xFF0EA5E9);       // Sky Accent
  static const Color pendingYellow = Color(0xFFF59E0B);    // Orange/Yellow Status
  static const Color overdueRed = Color(0xFFEF4444);       // Alert Red
  static const Color successGreen = Color(0xFF10B981);     // Success Green

  // Returns the ThemeData for VELS
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGray,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: backgroundWhite,
        error: overdueRed,
        outline: borderLight,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        color: backgroundWhite,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: secondaryBlue,
        unselectedItemColor: textLight,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
