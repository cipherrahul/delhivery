import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // Primary Brand Colors (Vibrant & Premium)
  static const Color primary = Color(0xFF1A1A1A); // Sleek Black
  static const Color accent = Color(0xFFFFD700);  // Premium Gold
  static const Color secondary = Color(0xFFF5F5f7); // Soft Grey
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);

  // Backgrounds
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFFAFAFA);

  // Typography
  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        color: primary.withValues(alpha: 0.7),
      );

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // Decoration
  static BoxDecoration get premiumCard => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow,
      );
}
