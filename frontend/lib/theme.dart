import 'package:flutter/material.dart';

const String kBase = 'https://ortho-api.onrender.com';

const Color kTeal = Color(0xFF0B6E7A);
const Color kNaranja = Color(0xFFA84A0E);
const Color kFondo = Color(0xFFF2F6F7);
const Color kTexto = Color(0xFF0F2A33);

ThemeData construirTema() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kTeal,
    primary: kTeal,
    secondary: kNaranja,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kFondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: kFondo,
      foregroundColor: kTexto,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kTeal.withAlpha(90)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}