import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// A frosted-glass panel: blurred backdrop + translucent fill + thin
/// light border. This is the single building block behind every
/// "glassmorphism" surface in the brief — player controls, mini
/// player, overlay sheets.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double fillOpacity;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.lg,
    this.blurSigma = 20,
    this.fillOpacity = 0.08,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glass(opacity: fillOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                border ?? Border.all(color: AppColors.glassBorder(), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
