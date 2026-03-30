import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark palette (primary app theme) ─────────────────────────────────────
  static const Color obsidian = Color(0xFF080C18);
  static const Color surface = Color(0xFF0F1525);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D060);
  static const Color textMuted = Color(0xFF8A97B0);
  static const Color dividerDark = Color(0xFF1E2A42);

  // ── Light accents (auth form cards, light-on-dark elements) ──────────────
  static const Color primaryBlue = Color(0xFF001A4D);
  static const Color secondaryBlue = Color(0xFF153376);
  static const Color paleBlue = Color(0xFFF4F7FB);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color goldAccent = gold;
  static const Color borderColor = Color(0xFFE5E7EB);

  // ── Typography helpers ──────────────────────────────────────────────────────

  /// Playfair Display — for H1 / H2 / brand titles
  static TextStyle playfair({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = textDark,
    double letterSpacing = -0.5,
    double? height,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Inter — for H3, body, labels, forms, numbers
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textDark,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Uppercase label style (H3 equivalent)
  static TextStyle label({
    Color color = textGrey,
    double fontSize = 10,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2.0,
      );

  /// Snackbar for features not yet implemented
  static void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bientôt disponible',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: obsidian,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 36,
          letterSpacing: -0.8,
          height: 1.05,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        titleSmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        bodyLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        secondary: goldAccent,
        surface: surface,
        onPrimary: obsidian,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: obsidian,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: obsidian,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: BorderSide(color: gold.withValues(alpha: 0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
