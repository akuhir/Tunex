import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../core/widgets/song_tile.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Shows one artist's songs and simple stats (song/album counts) per
/// the brief's "Artist songs. Albums. Statistics." Filters the live
/// library by artist name rather than a separate MediaStore query,
/// since [Song.artist] is already the source of truth used to build
/// the Artists tab's list in the first place.
class ArtistDetailScreen extends ConsumerWidget {
  final String artistName;

  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final songs = library.songs.where((s) => s.artist == artistName).toList();
    final albumCount = songs.map((s) => s.album).toSet().length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const ArtworkThumbnail(size: 96, circular: true),
            const SizedBox(height: AppSpacing.md),
            Text(artistName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${songs.length} songs · $albumCount albums',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (songs.isNotEmpty)
              TextButton.icon(
                onPressed: () => ref
                    .read(playbackProvider.notifier)
                    .playQueue(songs),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play All'),
              ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                itemCount: songs.length + 1,
                itemBuilder: (context, index) {
                  if (index == songs.length) {
                    return const SizedBox(height: AppSpacing.xxl);
                  }
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    onTap: () => ref
                        .read(playbackProvider.notifier)
                        .playQueue(songs, startIndex: index),
                    onMoreTap: () => showSongActionsSheet(context, song: song),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
