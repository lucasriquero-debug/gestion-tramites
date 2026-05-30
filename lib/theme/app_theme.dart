import 'package:flutter/material.dart';

enum AppThemeMode { integra, oscuro }

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.oscuro:
        return _oscuro;
      case AppThemeMode.integra:
      default:
        return _integra;
    }
  }

  // Colores Integra
  static const Color integraPrimario = Color(0xFF1B4F72);
  static const Color integraSecundario = Color(0xFF2E8B7A);
  static const Color integraFondo = Color(0xFFF4F6F8);
  static const Color integraSuperficie = Colors.white;
  static const Color integraTexto = Color(0xFF1B2631);
  static const Color integraTextoSecundario = Color(0xFF5D6D7E);
  static const Color integraBorde = Color(0xFFD5D8DC);

  // Colores Oscuro
  static const Color oscuroPrimario = Color(0xFF2E8B7A);
  static const Color oscuroFondo = Color(0xFF121212);
  static const Color oscuroSuperficie = Color(0xFF1E1E1E);
  static const Color oscuroSuperficie2 = Color(0xFF2C2C2C);
  static const Color oscuroTexto = Color(0xFFF4F6F8);
  static const Color oscuroTextoSecundario = Color(0xFF9CA3AF);
  static const Color oscuroBorde = Color(0xFF3A3A3A);

  static final ThemeData _integra = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: integraPrimario,
      primary: integraPrimario,
      secondary: integraSecundario,
      background: integraFondo,
      surface: integraSuperficie,
    ),
    scaffoldBackgroundColor: integraFondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: integraTexto,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: integraTexto,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: integraPrimario),
      selectedLabelTextStyle: TextStyle(color: integraPrimario),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: integraPrimario,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: integraBorde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: integraBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: integraPrimario),
      ),
    ),
  );

  static final ThemeData _oscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: oscuroPrimario,
      brightness: Brightness.dark,
      primary: oscuroPrimario,
      background: oscuroFondo,
      surface: oscuroSuperficie,
    ),
    scaffoldBackgroundColor: oscuroFondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: oscuroSuperficie,
      foregroundColor: oscuroTexto,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: oscuroTexto,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: oscuroSuperficie,
      selectedIconTheme: IconThemeData(color: oscuroPrimario),
      selectedLabelTextStyle: TextStyle(color: oscuroPrimario),
    ),
    cardColor: oscuroSuperficie,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: oscuroPrimario,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: oscuroSuperficie2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: oscuroBorde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: oscuroBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: oscuroPrimario),
      ),
    ),
  );
}