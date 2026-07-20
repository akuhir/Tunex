import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../data/models/song.dart';
import '../../data/services/permission_service.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';
import 'widgets/greeting_header.dart';
import 'widgets/hero_banner.dart';
import 'widgets/library_shortcuts_row.dart';
import 'widgets/quick_action_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    switch (library.status) {
      case LibraryStatus.loading:
        return const SafeArea(child: SkeletonSongList(itemCount: 8));

      case LibraryStatus.permissionDenied:
      case LibraryStatus.permissionPermanentlyDenied:
        return SafeArea(
          child: PermissionRequestView(
            permanentlyDenied:
                library.status == LibraryStatus.permissionPermanentlyDenied,
            onRequestPermission: () =>
                ref.read(libraryProvider.notifier).scan(),
            onOpenSettings: () => PermissionService.openSettings(),
          ),
        );

      case LibraryStatus.error:
        return SafeArea(
          child: LibraryErrorView(
            message: library.errorMessage ?? 'Unknown error',
            onRetry: () => ref.read(libraryProvider.notifier).scan(),
          ),
        );

      case LibraryStatus.ready:
        if (library.songs.isEmpty) {
          return SafeArea(
            child: EmptyLibraryView(
              onRescan: () => ref.read(libraryProvider.notifier).scan(),
            ),
          );
        }
        return _HomeContent(library: library);
    }
  }
}

class _HomeContent extends ConsumerWidget {
  final LibraryState library;

  const _HomeContent({required this.library});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final hasMiniPlayer = playback.currentSong != null;

    final recentlyAdded = ref.watch(recentlyAddedProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final mostPlayed = ref.watch(mostPlayedProvider);
    final favorites = ref.watch(favoriteSongsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(libraryProvider.notifier).scan(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
                AppSpacing.pageHorizontal,
                hasMiniPlayer ? AppSpacing.md : AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const GreetingHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  HeroBanner(
                    onCtaTap: () {
                      ref
                          .read(playbackProvider.notifier)
                          .playQueue(library.songs);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuickActionRow(
                    onShuffleAll: () {
                      final shuffled = List<Song>.from(library.songs)
                        ..shuffle();
                      ref
                          .read(playbackProvider.notifier)
                          .playQueue(shuffled);
                    },
                    onQuickPlay: () {
                      ref
                          .read(playbackProvider.notifier)
                          .playQueue(library.songs);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const LibraryShortcutsRow(),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Most Played', onSeeAll: () {}),
                  _SongRail(
                    songs: mostPlayed,
                    onSongTap: (song, index) => ref
                        .read(playbackProvider.notifier)
                        .playQueue(mostPlayed, startIndex: index),
                  ),
                  if (recentlyPlayed.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(title: 'Recently Played', onSeeAll: () {}),
                    _SongRail(
                      songs: recentlyPlayed,
                      onSongTap: (song, index) => ref
                          .read(playbackProvider.notifier)
                          .playQueue(recentlyPlayed, startIndex: index),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: 'Favorites',
                    onSeeAll: () => context.push(AppRoutes.favorites),
                  ),
                  favorites.isEmpty
                      ? const _EmptyRailHint(text: 'No favorites yet')
                      : _SongRail(
                          songs: favorites,
                          onSongTap: (song, index) => ref
                              .read(playbackProvider.notifier)
                              .playQueue(favorites, startIndex: index),
                        ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Recently Added', onSeeAll: () {}),
                  _SongRail(
                    songs: recentlyAdded,
                    onSongTap: (song, index) => ref
                        .read(playbackProvider.notifier)
                        .playQueue(recentlyAdded, startIndex: index),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling rail of album-art cards used by every Home
/// section — Most Played, Favorites, Recently Added.
class _SongRail extends StatelessWidget {
  final List<Song> songs;
  final void Function(Song song, int index) onSongTap;

  const _SongRail({required this.songs, required this.onSongTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => onSongTap(song, index),
            onLongPress: () => showSongActionsSheet(context, song: song),
            child: SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtworkThumbnail(
                    size: 130,
                    borderRadius: AppRadius.md,
                    id: int.tryParse(song.id),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyRailHint extends StatelessWidget {
  final String text;
  const _EmptyRailHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
