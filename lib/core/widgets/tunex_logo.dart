import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The Tunex signature mark — an early, code-drawn placeholder concept.
///
/// **Superseded**: the app now uses the real designed logo
/// (`assets/images/tunex_logo.png`, wrapped by [AppLogoImage]) across
/// the splash screen, launcher icon, and every in-app usage. This
/// widget is kept only as a reference/fallback concept and isn't
/// referenced anywhere in the live app — safe to delete, or repurpose
/// if you ever want an animatable vector mark again.
///
/// Concept: a stylized "T" where the crossbar resolves into a play
/// triangle on the right and a small soundwave (three bars) on the
/// left — one continuous shape reading simultaneously as a letterform
/// and a play control. Purple-to-cyan gradient fill, per brand.
class TunexLogo extends StatelessWidget {
  /// Overall size of the mark's bounding box.
  final double size;

  /// 0..1 — used by the splash screen to animate the glow intensity.
  final double glowStrength;

  const TunexLogo({super.key, this.size = 96, this.glowStrength = 1.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TunexLogoPainter(glowStrength: glowStrength),
      ),
    );
  }
}

class _TunexLogoPainter extends CustomPainter {
  final double glowStrength;

  _TunexLogoPainter({required this.glowStrength});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);

    final gradientPaint = Paint()
      ..shader = AppColors.brandGradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Ambient glow behind the mark.
    if (glowStrength > 0) {
      final glowPaint = Paint()
        ..shader = AppColors.brandGradient.createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.22)
        ..color = Colors.white.withOpacity(0.55 * glowStrength);
      canvas.drawCircle(
        Offset(w / 2, h / 2),
        w * 0.32,
        glowPaint,
      );
    }

    // --- Soundwave bars (left stroke of the "T", reimagined) ---
    final barWidth = w * 0.09;
    final barPaint = Paint()
      ..shader = AppColors.brandGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final barHeights = [0.34, 0.52, 0.40];
    final barStartX = w * 0.14;
    for (var i = 0; i < barHeights.length; i++) {
      final bh = h * barHeights[i];
      final bx = barStartX + i * (barWidth * 1.6);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, (h - bh) / 2, barWidth, bh),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rrect, barPaint);
    }

    // --- Horizontal crossbar connecting bars to the play triangle ---
    final crossbarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        barStartX,
        h * 0.46,
        w * 0.62,
        h * 0.08,
      ),
      Radius.circular(h * 0.04),
    );
    canvas.drawRRect(crossbarRect, gradientPaint);

    // --- Play triangle (right side, the "T" resolving into play) ---
    final playPath = Path()
      ..moveTo(w * 0.62, h * 0.30)
      ..lineTo(w * 0.92, h * 0.5)
      ..lineTo(w * 0.62, h * 0.70)
      ..close();
    canvas.drawPath(playPath, gradientPaint);

    // --- Vertical stem of the "T" ---
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w * 0.42,
        h * 0.46,
        w * 0.08,
        h * 0.40,
      ),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(stemRect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _TunexLogoPainter oldDelegate) =>
      oldDelegate.glowStrength != glowStrength;
}
