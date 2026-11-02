import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  /// Cairo reads well in Arabic and carries a full Latin set; Inter is used
  /// for English because its tighter metrics suit dense tables.
  static const arabicFont = 'Cairo';
  static const latinFont = 'Inter';

  static TextTheme textTheme({required bool arabic, required Color onSurface}) {
    final base = arabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();

    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
          bodySmall: base.bodySmall?.copyWith(fontSize: 12.5, height: 1.45),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        )
        .apply(bodyColor: onSurface, displayColor: onSurface);
  }
}
