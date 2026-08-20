/// Spacing, radius, and elevation tokens.
///
/// Centralizing these makes "generous spacing" and "rounded corners"
/// from the brief consistent and tunable in one place instead of magic
/// numbers scattered across widgets.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal page padding used across all list/grid pages.
  static const double pageHorizontal = 20;
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;

  /// Used for circular artist avatars, the mini player thumbnail, etc.
  static const double pill = 999;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);

  // Splash sequence timings (brief: 3–5s total)
  static const Duration splashLogoFadeIn = Duration(milliseconds: 900);
  static const Duration splashLogoScale = Duration(milliseconds: 900);
  static const Duration splashGlow = Duration(milliseconds: 1400);
  static const Duration splashTextFadeIn = Duration(milliseconds: 700);
  static const Duration splashHoldBeforeExit = Duration(milliseconds: 900);
  static const Duration splashExitFade = Duration(milliseconds: 500);
}
