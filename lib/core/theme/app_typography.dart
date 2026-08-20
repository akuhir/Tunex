import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tunex type system — Poppins throughout, bold weights, generous
/// letter-spacing on headings to match the "premium" brief.
///
/// Poppins is bundled locally (assets/fonts/, declared in
/// pubspec.yaml) rather than fetched at runtime via `google_fonts` —
/// Tunex is a fully offline app, so a first launch with no internet
/// connection must not depend on downloading font files.
///
/// Only three weights are bundled — Regular (400), Medium (500), and
/// Bold (700) — so styles that would otherwise ask for a SemiBold
/// (600) use Bold (700) instead of silently falling back to a
/// synthetic/incorrect weight.
class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Poppins';

  static TextTheme get textTheme => const TextTheme(
        // Splash logo wordmark / hero numbers
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AppColors.textPrimary,
        ),

        // Section headers ("Recently Played", "Good evening")
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        // Song titles, card titles
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),

        // Body copy
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),

        // Buttons / labels
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
      );

  /// Tagline style — used on the splash screen under the wordmark.
  static const TextStyle tagline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 3,
    color: AppColors.textSecondary,
  );
}
