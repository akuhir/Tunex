import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../core/widgets/song_tile.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Shows one album's tracks — reached by tapping an album cover in
/// [AlbumsScreen], per the brief's "Tap opens tracks".
class AlbumDetailScreen extends ConsumerWidget {
  final int albumId;
  final String albumTitle;

  const AlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const SizedBox(width: AppSpacing.sm),
                  ArtworkThumbnail(
                    size: 48,
                    borderRadius: AppRadius.sm,
                    id: albumId,
                    type: ArtworkType.ALBUM,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      albumTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future:
                    OnAudioQuery().queryAudiosFrom(AudiosFromType.ALBUM_ID, albumId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonSongList(itemCount: 8);
                  }
                  final library = ref.watch(libraryProvider);
                  final idsInAlbum =
                      snapshot.data!.map((m) => m.id.toString()).toSet();
                  final songs = library.songs
                      .where((s) => idsInAlbum.contains(s.id))
                      .toList();

                  if (songs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No songs found for this album',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
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
                        onMoreTap: () =>
                            showSongActionsSheet(context, song: song),
                      );
                    },
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
