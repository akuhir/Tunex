import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/services/permission_service.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Genres — reads MediaStore's genre tags directly via `on_audio_query`
/// (genre isn't part of our [Song] model since most files either lack
/// it or the tag is unreliable; querying it lazily per-genre keeps the
/// core Song model simple). Tapping a genre shows its songs.
class GenresScreen extends ConsumerWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    if (library.status == LibraryStatus.loading) {
      return const SafeArea(child: SkeletonSongList(itemCount: 8));
    }
    if (library.status == LibraryStatus.permissionDenied ||
        library.status == LibraryStatus.permissionPermanentlyDenied) {
      return SafeArea(
        child: PermissionRequestView(
          permanentlyDenied:
              library.status == LibraryStatus.permissionPermanentlyDenied,
          onRequestPermission: () => ref.read(libraryProvider.notifier).scan(),
          onOpenSettings: () => PermissionService.openSettings(),
        ),
      );
    }

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
                Text('Genres', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<GenreModel>>(
              future: OnAudioQuery().queryGenres(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SkeletonSongList(itemCount: 6);
                }
                final genres = snapshot.data!;
                if (genres.isEmpty) {
                  return Center(
                    child: Text(
                      'No genre tags found in your library',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.category_rounded,
                            color: Colors.white),
                      ),
                      title: Text(genre.genre),
                      subtitle: Text('${genre.numOfSongs} songs'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              _GenreSongsScreen(genreId: genre.id, genreName: genre.genre),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreSongsScreen extends ConsumerWidget {
  final int genreId;
  final String genreName;

  const _GenreSongsScreen({required this.genreId, required this.genreName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(genreName)),
      body: FutureBuilder(
        future: OnAudioQuery().queryAudiosFrom(AudiosFromType.GENRE, genreId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SkeletonSongList(itemCount: 6);
          }
          final library = ref.watch(libraryProvider);
          final idsInGenre =
              snapshot.data!.map((m) => m.id.toString()).toSet();
          final songs =
              library.songs.where((s) => idsInGenre.contains(s.id)).toList();

          if (songs.isEmpty) {
            return const Center(
              child: Text(
                'No songs found for this genre',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) => SongTile(
              song: songs[index],
              onTap: () => ref
                  .read(playbackProvider.notifier)
                  .playQueue(songs, startIndex: index),
            ),
          );
        },
      ),
    );
  }
}
