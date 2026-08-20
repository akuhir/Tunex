import 'package:flutter/material.dart';
import '../../../core/constants/developer_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// Centered footer: version, copyright line, and a small "made with"
/// note — subtle typography, sits below the main content cards.
class FooterSection extends StatelessWidget {
  final String version;

  const FooterSection({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Version $version',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          if (DeveloperInfo.copyrightLine.isNotEmpty)
            Text(
              DeveloperInfo.copyrightLine,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          if (DeveloperInfo.madeWithLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              DeveloperInfo.madeWithLine,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
