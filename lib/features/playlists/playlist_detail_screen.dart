import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/playlist.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/playlists_provider.dart';

/// Shows one playlist's songs — resolves the playlist's stored song
/// ids against the live library (so a song deleted from the device
/// simply disappears here rather than crashing), with remove-from
/// -playlist and shuffle-play actions.
class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final library = ref.watch(libraryProvider);

    Playlist? playlist;
    for (final p in playlists) {
      if (p.name == playlistName) {
        playlist = p;
        break;
      }
    }

    if (playlist == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Playlist not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final songsById = {for (final s in library.songs) s.id: s};
    final resolvedSongs = playlist.songIds
        .map((id) => songsById[id])
        .where((s) => s != null)
        .map((s) => s!)
        .toList();

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
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${resolvedSongs.length} songs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (resolvedSongs.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded),
                    onPressed: () {
                      final shuffled = List.of(resolvedSongs)..shuffle();
                      ref
                          .read(playbackProvider.notifier)
                          .playQueue(shuffled);
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: resolvedSongs.isEmpty
                ? Center(
                    child: Text(
                      'No songs in this playlist yet.\nAdd some from any song\'s menu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    itemCount: resolvedSongs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == resolvedSongs.length) {
                        return const SizedBox(height: AppSpacing.xxl);
                      }
                      final song = resolvedSongs[index];
                      return SongTile(
                        song: song,
                        onTap: () => ref
                            .read(playbackProvider.notifier)
                            .playQueue(resolvedSongs, startIndex: index),
                        onMoreTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.lg),
                            ),
                          ),
                          builder: (context) => SafeArea(
                            child: ListTile(
                              leading: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: AppColors.danger,
                              ),
                              title: const Text('Remove from Playlist'),
                              onTap: () {
                                Navigator.of(context).pop();
                                ref
                                    .read(playlistsProvider.notifier)
                                    .removeSong(playlist!.name, song.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
