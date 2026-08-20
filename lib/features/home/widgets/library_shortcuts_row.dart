import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// Quick-access row to the library sections that aren't bottom-nav
/// tabs — Playlists, Favorites, Genres, Folders. Sits on Home since
/// the brief keeps the bottom nav to five tabs (Home/Songs/Albums/
/// Artists/Settings) but still calls for all of these as first-class
/// pages.
class LibraryShortcutsRow extends StatelessWidget {
  const LibraryShortcutsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ShortcutChip(
            icon: Icons.queue_music_rounded,
            label: 'Playlists',
            onTap: () => context.push(AppRoutes.playlists),
          ),
          const SizedBox(width: AppSpacing.md),
          _ShortcutChip(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            onTap: () => context.push(AppRoutes.favorites),
          ),
          const SizedBox(width: AppSpacing.md),
          _ShortcutChip(
            icon: Icons.category_rounded,
            label: 'Genres',
            onTap: () => context.push(AppRoutes.genres),
          ),
          const SizedBox(width: AppSpacing.md),
          _ShortcutChip(
            icon: Icons.folder_rounded,
            label: 'Folders',
            onTap: () => context.push(AppRoutes.folders),
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
