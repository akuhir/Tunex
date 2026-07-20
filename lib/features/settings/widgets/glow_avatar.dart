import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A circular profile avatar with a glowing purple/cyan gradient ring
/// and soft outer glow, per the About screen's premium profile card.
///
/// Loads [imageAssetPath] if it exists in the bundle; if the asset is
/// missing (e.g. you haven't dropped a photo in yet) this falls back
/// to a person icon on a branded gradient fill instead of crashing —
/// so replacing the placeholder later is just "add the file", no code
/// changes needed.
class GlowAvatar extends StatelessWidget {
  final String imageAssetPath;
  final double size;

  const GlowAvatar({
    super.key,
    required this.imageAssetPath,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = size + 12;

    return SizedBox(
      width: ringSize + 16,
      height: ringSize + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft outer glow.
          Container(
            width: ringSize + 16,
            height: ringSize + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Gradient ring.
          Container(
            width: ringSize,
            height: ringSize,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Hero(
                  tag: 'tunex-profile-avatar',
                  child: Image.asset(
                    imageAssetPath,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: size * 0.5,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
