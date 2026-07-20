import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// The Home screen's hero banner — a large gradient card with a bold
/// headline and a primary CTA, echoing the "Feel Every Beat / Listen
/// Now" treatment from the reference design. Uses the brand gradient
/// and an abstract soundwave motif instead of a photo, keeping it
/// consistent with the rest of the app's artwork placeholders.
class HeroBanner extends StatelessWidget {
  final String headline;
  final String ctaLabel;
  final VoidCallback onCtaTap;

  const HeroBanner({
    super.key,
    this.headline = 'Feel\nEvery Beat.',
    this.ctaLabel = 'Listen Now',
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: AppColors.brandGradient,
      ),
      child: Stack(
        children: [
          // Abstract soundwave motif, echoing the mockup's photo
          // silhouette without using an actual photograph.
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.18,
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 190,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  headline,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CtaButton(label: ctaLabel, onTap: onCtaTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CtaButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
