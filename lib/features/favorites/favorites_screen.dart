import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../core/widgets/song_tile.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Dedicated Favorites page — the full liked-songs list, reached from
/// Home's "Favorites" section header ("See all") or the library nav.
/// Backed by the same persisted [favoriteSongsProvider] as the Home
/// rail and the heart icons across the app, so toggling anywhere stays
/// in sync everywhere.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteSongsProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text('Favorites', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No favorites yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Tap the heart on any song to add it here.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    itemCount: favorites.length + 1,
                    itemBuilder: (context, index) {
                      if (index == favorites.length) {
                        return const SizedBox(height: AppSpacing.xxl);
                      }
                      final song = favorites[index];
                      return SongTile(
                        song: song,
                        onTap: () => ref
                            .read(playbackProvider.notifier)
                            .playQueue(favorites, startIndex: index),
                        onMoreTap: () =>
                            showSongActionsSheet(context, song: song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
