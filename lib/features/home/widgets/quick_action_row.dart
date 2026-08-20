import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// "Shuffle All" + "Quick Play" pill buttons on Home, per brief.
class QuickActionRow extends StatelessWidget {
  final VoidCallback onShuffleAll;
  final VoidCallback onQuickPlay;

  const QuickActionRow({
    super.key,
    required this.onShuffleAll,
    required this.onQuickPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionPill(
            icon: Icons.shuffle_rounded,
            label: 'Shuffle All',
            filled: true,
            onTap: onShuffleAll,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionPill(
            icon: Icons.bolt_rounded,
            label: 'Quick Play',
            filled: false,
            onTap: onQuickPlay,
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? null : AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.brandGradient : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
