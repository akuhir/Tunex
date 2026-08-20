import 'package:flutter/material.dart';

/// Tunex brand color system.
///
/// Every color in the app should be sourced from here — never hardcode
/// a hex value inline in a widget.
///
/// [primary] and [accent] are plain getters backed by [_accentNameNotifier]
/// rather than `static const`, so Settings' "Accent Color" picker can
/// change them at runtime. [TunexApp] in main.dart watches
/// `accentProvider` (see providers/settings_provider.dart) so the whole
/// app rebuilds — and therefore re-reads these getters — the instant
/// the accent changes.
class AppColors {
  AppColors._();

  /// Curated accent choices offered in Settings — each is a
  /// (primary, accent) pair chosen to keep the same "purple-to-cyan
  /// style gradient" feel the brief calls for, just with a different
  /// hue pair.
  static const Map<String, ({Color primary, Color accent})> accentPresets = {
    'Violet': (primary: Color(0xFF6C63FF), accent: Color(0xFF00D4FF)),
    'Sunset': (primary: Color(0xFFFF6B6B), accent: Color(0xFFFFB86B)),
    'Emerald': (primary: Color(0xFF10B981), accent: Color(0xFF34D399)),
    'Rose': (primary: Color(0xFFEC4899), accent: Color(0xFFF472B6)),
    'Ocean': (primary: Color(0xFF3B82F6), accent: Color(0xFF22D3EE)),
  };

  static const String defaultAccentName = 'Violet';

  static final ValueNotifier<String> _accentNameNotifier =
      ValueNotifier(defaultAccentName);

  static String get accentName => _accentNameNotifier.value;

  /// Called once at startup (after reading the persisted choice) and
  /// whenever the user picks a new accent in Settings.
  static void setAccent(String name) {
    if (accentPresets.containsKey(name)) {
      _accentNameNotifier.value = name;
    }
  }

  static ({Color primary, Color accent}) get _currentPreset =>
      accentPresets[_accentNameNotifier.value] ?? accentPresets[defaultAccentName]!;

  // Brand — dynamic, per the current accent preset.
  static Color get primary => _currentPreset.primary;
  static Color get accent => _currentPreset.accent;

  // Surfaces
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF161B2D);
  static const Color card = Color(0xFF1B2236);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5AEC0);

  // Status
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFFF4D6D);

  // Derived / utility tones (built from the palette above, not new hues)
  static const Color cardHighlight = Color(0xFF232B45);
  static const Color divider = Color(0x1FA5AEC0); // textSecondary @ 12%
  static const Color overlayScrim = Color(0xCC0F172A); // background @ 80%

  /// The signature Tunex gradient — purple to cyan by default, follows
  /// whichever accent preset is active. Used sparingly: progress
  /// fills, glow accents, the logo, and the signature animated
  /// backdrop behind the Now Playing artwork.
  static LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, accent],
      );

  /// A softened version of the brand gradient for large ambient
  /// backgrounds (glow behind splash logo, blurred player backdrop).
  static LinearGradient get ambientGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(primary, background, 0.75) ?? background,
          background,
        ],
      );

  /// Glassmorphism surface fill — layered over blurred backgrounds.
  static Color glass({double opacity = 0.08}) =>
      Colors.white.withOpacity(opacity);

  /// Glass border — the thin light edge that sells the frosted-glass look.
  static Color glassBorder({double opacity = 0.12}) =>
      Colors.white.withOpacity(opacity);
}
