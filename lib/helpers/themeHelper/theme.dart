import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeHelper {
  /// Theme for light mode
  ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      onSurface: Color(0xff11181C),
      primary: Color(0xFF8C1AB1),
      onPrimary: Colors.white,
      secondary: Color(0xFFF9C126),
      onSecondary: Color(0xff441B04),
    ),
    //
    textTheme: GoogleFonts.manropeTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xff697177)),
        bodyMedium: TextStyle(color: Color(0xff697177)),
      ),
    ),
    //
    bottomSheetTheme: const BottomSheetThemeData().copyWith(
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
  );

  /// Theme for dark mode
  ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xff11181C),
      onSurface: Colors.white,
      primary: Color(0xFF8C1AB1),
      onPrimary: Colors.white,
      secondary: Color(0xFFF9C126),
      onSecondary: Color(0xff441B04),
    ),
    //
    textTheme: GoogleFonts.manropeTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
      ),
    ),
    //
    bottomSheetTheme: const BottomSheetThemeData().copyWith(
      backgroundColor: const Color(0xff11181C),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
  );
}
