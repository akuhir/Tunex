import 'package:flutter/material.dart';
import '../../../core/constants/developer_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/glass_container.dart';
import 'glow_avatar.dart';
import 'verified_badge.dart';

/// The developer profile card at the top of the About screen: a
/// glowing circular avatar, name with a decorative verified badge,
/// alias, and a short role tagline — all sourced from [DeveloperInfo]
/// so this reads correctly however much of that file has been filled in.
class DeveloperProfileCard extends StatelessWidget {
  const DeveloperProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        children: [
          const GlowAvatar(imageAssetPath: DeveloperInfo.profileImageAsset),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  DeveloperInfo.developerName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const VerifiedBadge(),
            ],
          ),
          if (DeveloperInfo.developerAlias.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '(${DeveloperInfo.developerAlias})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (DeveloperInfo.developerRoleTagline.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              DeveloperInfo.developerRoleTagline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
