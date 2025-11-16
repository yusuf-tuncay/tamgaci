import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _primaryLight = Color(0xFF2196F3);
  static const Color _secondaryLight = Color(0xFF4CAF50);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _onSecondaryLight = Color(0xFFFFFFFF);
  static const Color _onSurfaceLight = Color(0xFF212121);
  static const Color _errorLight = Color(0xFFF44336);
  static const Color _backgroundLight = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color _primaryDark = Color(0xFF64B5F6);
  static const Color _secondaryDark = Color(0xFF81C784);
  static const Color _surfaceDark = Color(0xFF3A3A3A);
  static const Color _onPrimaryDark = Color(0xFF000000);
  static const Color _onSecondaryDark = Color(0xFF000000);
  static const Color _onSurfaceDark = Color(0xFFE0E0E0);
  static const Color _errorDark = Color(0xFFCF6679);
  static const Color _backgroundDark = Color(0xFF2C2C2C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: _errorLight,
        onPrimary: _onPrimaryLight,
        onSecondary: _onSecondaryLight,
        onSurface: _onSurfaceLight,
        onError: _onPrimaryLight,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: _onSurfaceLight,
        displayColor: _onSurfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: _onSurfaceLight,
        elevation: 2,
        centerTitle: true,
        shadowColor: Color(0x1F000000),
        titleTextStyle: TextStyle(
          color: _onSurfaceLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: const Color(0x1F000000),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: _onPrimaryLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: _surfaceLight,
        labelStyle: const TextStyle(color: _onSurfaceLight),
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryLight,
        foregroundColor: _onPrimaryLight,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _onSurfaceLight,
        iconColor: _onSurfaceLight,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceLight,
        titleTextStyle: const TextStyle(
          color: _onSurfaceLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: _onSurfaceLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: _surfaceLight,
        deleteIconColor: _onSurfaceLight,
        disabledColor: Color(0xFFE0E0E0),
        selectedColor: _primaryLight,
        secondarySelectedColor: _secondaryLight,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(color: _onSurfaceLight),
        secondaryLabelStyle: TextStyle(color: _onPrimaryLight),
        brightness: Brightness.light,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _surfaceLight,
        scrimColor: Color(0x40000000),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: _errorDark,
        onPrimary: _onPrimaryDark,
        onSecondary: _onSecondaryDark,
        onSurface: _onSurfaceDark,
        onError: _onPrimaryDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: _onSurfaceDark,
        displayColor: _onSurfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
        elevation: 2,
        centerTitle: true,
        shadowColor: Color(0x1F000000),
        titleTextStyle: TextStyle(
          color: _onSurfaceDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF424242),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: const Color(0x1F000000),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _onPrimaryDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: _surfaceDark,
        labelStyle: const TextStyle(color: _onSurfaceDark),
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: _onPrimaryDark,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _onSurfaceDark,
        iconColor: _onSurfaceDark,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDark,
        titleTextStyle: const TextStyle(
          color: _onSurfaceDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: _onSurfaceDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: _surfaceDark,
        deleteIconColor: _onSurfaceDark,
        disabledColor: Color(0xFF424242),
        selectedColor: _primaryDark,
        secondarySelectedColor: _secondaryDark,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(color: _onSurfaceDark),
        secondaryLabelStyle: TextStyle(color: _onPrimaryDark),
        brightness: Brightness.dark,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _surfaceDark,
        scrimColor: Color(0x40000000),
      ),
    );
  }
}
