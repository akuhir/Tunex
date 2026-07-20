import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The real Tunex logo — a single place wrapping
/// `assets/images/tunex_logo.png` so every screen that shows the mark
/// (splash, About app bar, permission-request empty state, etc.) stays
/// in sync if the asset is ever swapped for a new design.
///
/// Falls back to a simple music-note glyph on a branded gradient if
/// the asset is somehow missing, so a bad asset never crashes a screen.
class AppLogoImage extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const AppLogoImage({super.key, this.size = 32, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/tunex_logo.png',
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.brandGradient,
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white.withOpacity(0.9),
          size: size * 0.55,
        ),
      ),
    );
  }
}
