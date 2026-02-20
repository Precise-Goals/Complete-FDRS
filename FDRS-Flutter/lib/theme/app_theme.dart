import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color trueBlack = Color(0xFF000000);
  static const Color darkGray = Color(0xFF0A0A0A);
  static const Color panelGray = Color(0xFF141414);
  static const Color accentRed = Color(0xFFFF2A2A);
  static const Color accentOrange = Color(0xFFFF4500);
  static const Color accentOrangeLight = Color(0xFFFF9500);
  static const Color textSecondary = Color(0xFF888888);
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: trueBlack,
      primaryColor: accentOrange,
      colorScheme: const ColorScheme.dark(
        primary: accentOrange,
        secondary: accentRed,
        surface: panelGray,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 96, fontWeight: FontWeight.w900, letterSpacing: -1.5),
        displayMedium: GoogleFonts.inter(fontSize: 60, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        displaySmall: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
        labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      useMaterial3: true,
    );
  }

  // Tech font for the SOS button
  static TextStyle get techFont => GoogleFonts.orbitron(
    fontWeight: FontWeight.w900,
  );

  // Poppins for User Profile
  static TextStyle get poppinsFont => GoogleFonts.poppins();
}
