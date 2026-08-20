import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/developer_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_text.dart';

/// The "About Tunex" bio card — the app's story in the developer's own
/// words, ending with the bold brand tagline.
class AboutTunexCard extends StatelessWidget {
  const AboutTunexCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎵 About Tunex',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            DeveloperInfo.aboutTunexBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.9),
                  height: 1.6,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientText(
            '${AppConstants.appName} — ${AppConstants.tagline}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
