import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color accent = Color(0xFFD4AF37);
  static const Color bgLight = Color(0xFFF7F3E9);
  static const Color bgDark = Color(0xFF0E1A12);

  // بدون Google Fonts — خط النظام (Noto Sans Arabic / Roboto) — يعمل بلا نت
  static TextTheme _textTheme(Brightness b) {
    final base = b == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
    return base.copyWith(
      bodyLarge: const TextStyle(fontSize: 18, height: 1.6),
      bodyMedium: const TextStyle(fontSize: 15, height: 1.5),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
    );
  }

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light).copyWith(secondary: accent),
        scaffoldBackgroundColor: bgLight,
        textTheme: _textTheme(Brightness.light),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: primary, foregroundColor: Colors.white),
        cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        navigationBarTheme: NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: primary.withOpacity(0.15)),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark).copyWith(secondary: accent),
        scaffoldBackgroundColor: bgDark,
        textTheme: _textTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
}
