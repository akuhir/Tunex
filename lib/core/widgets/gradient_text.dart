import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders [text] filled with the Tunex brand gradient instead of a
/// flat color. Used sparingly — the wordmark on splash, key numerals,
/// the active tab label — per the "use gradients as highlights" brief.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedGradient = gradient ?? AppColors.brandGradient;
    return ShaderMask(
      shaderCallback: (bounds) => resolvedGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
