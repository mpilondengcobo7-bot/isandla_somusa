import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand colours ──────────────────────────────────────────────────
  static const Color forestGreen  = Color(0xFF3B6D11);
  static const Color tealGreen    = Color(0xFF1D9E75);
  static const Color warmAmber    = Color(0xFFEF9F27);
  static const Color coralAccent  = Color(0xFFD85A30);
  static const Color offWhite     = Color(0xFFF1EFE8);
  static const Color charcoal     = Color(0xFF2C2C2A);
  static const Color lightGray    = Color(0xFFD3D1C7);
  static const Color errorRed     = Color(0xFFE24B4A);
  static const Color successGreen = Color(0xFF639922);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tealGreen,
      primary: tealGreen,
      secondary: warmAmber,
      tertiary: coralAccent,
      background: offWhite,
      surface: Colors.white,
      error: errorRed,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: offWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: tealGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tealGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tealGreen,
        side: const BorderSide(color: tealGreen, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: tealGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE1F5EE),
      labelStyle: const TextStyle(color: forestGreen, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: coralAccent,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: tealGreen,
      unselectedItemColor: lightGray,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tealGreen,
      primary: tealGreen,
      secondary: warmAmber,
      tertiary: coralAccent,
      background: charcoal,
      surface: const Color(0xFF3A3A38),
      error: errorRed,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: charcoal,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A18),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF3A3A38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
