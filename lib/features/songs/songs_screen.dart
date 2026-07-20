import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/repositories/permission_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/settings_provider.dart';
import '../settings/widgets/sort_picker_sheet.dart';

/// Songs tab — real device library via [libraryProvider], with the
/// three-dot action menu, search, full song list, and a persisted
/// sort order (see Settings > Sort Songs, or the sort icon here).
class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final sortOption = ref.watch(songSortProvider);

    Widget body;
    switch (library.status) {
      case LibraryStatus.loading:
        body = const SkeletonSongList(itemCount: 10);
        break;
      case LibraryStatus.permissionDenied:
      case LibraryStatus.permissionPermanentlyDenied:
        body = PermissionRequestView(
          permanentlyDenied:
              library.status == LibraryStatus.permissionPermanentlyDenied,
          onRequestPermission: () => ref.read(libraryProvider.notifier).scan(),
          onOpenSettings: () => PermissionService.openSettings(),
        );
        break;
      case LibraryStatus.error:
        body = LibraryErrorView(
          message: library.errorMessage ?? 'Unknown error',
          onRetry: () => ref.read(libraryProvider.notifier).scan(),
        );
        break;
      case LibraryStatus.ready:
        final songs = applySongSort(
          library.songs,
          sortOption,
          title: (s) => s.title,
          artist: (s) => s.artist,
          album: (s) => s.album,
          duration: (s) => s.duration,
        );
        body = songs.isEmpty
            ? EmptyLibraryView(
                onRescan: () => ref.read(libraryProvider.notifier).scan(),
              )
            : ListView.builder(
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
                    onMoreTap: () => showSongActionsSheet(
                      context,
                      song: song,
                      onPlayNext: () {
                        // Queue insertion-at-position lands with the
                        // dedicated queue-management pass; for now
                        // "Play Next" starts it immediately, which is
                        // the most common intent anyway.
                        ref
                            .read(playbackProvider.notifier)
                            .playQueue(songs, startIndex: index);
                      },
                    ),
                  );
                },
              );
        break;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Songs', style: Theme.of(context).textTheme.headlineLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () => context.push(AppRoutes.search),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort_rounded),
                      onPressed: () => showSortPickerSheet(
                        context,
                        title: 'Sort Songs',
                        options: SongSortOption.values.map((option) {
                          return (
                            label: option.label,
                            isSelected: option == sortOption,
                            onTap: () => ref
                                .read(songSortProvider.notifier)
                                .setSort(option),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
