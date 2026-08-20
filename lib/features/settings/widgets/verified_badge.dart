import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Purely decorative verified badge — a blue checkmark-in-a-circle
/// matching the general style of verification badges on X, Instagram,
/// Facebook, and Telegram. Has no functionality; it's just a visual
/// trust signal next to the developer's name on the About screen.
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF3B9EFF), // recognizable "verified" blue
      ),
      child: Icon(
        Icons.check_rounded,
        size: size * 0.68,
        color: AppColors.background,
        weight: 900,
      ),
    );
  }
}
