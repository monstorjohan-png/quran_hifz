import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1B5E20); // deep green
  static const Color accent = Color(0xFFD4AF37); // gold
  static const Color bgLight = Color(0xFFF7F3E9);
  static const Color bgDark = Color(0xFF0E1A12);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
        scaffoldBackgroundColor: bgLight,
        textTheme: GoogleFonts.amiriTextTheme(),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
        scaffoldBackgroundColor: bgDark,
        textTheme: GoogleFonts.amiriTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      );
}
