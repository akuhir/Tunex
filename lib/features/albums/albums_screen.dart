import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../data/models/album.dart';
import '../../data/repositories/permission_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../settings/widgets/sort_picker_sheet.dart';

/// Albums tab — beautiful grid of large covers, per brief. Real
/// albums via [libraryProvider], with a persisted sort order (see
/// Settings > Sort Albums, or the sort icon here); tapping opens the
/// album's track list.
class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  List<Album> _sorted(List<Album> albums, AlbumSortOption option) {
    final sorted = List<Album>.from(albums);
    switch (option) {
      case AlbumSortOption.titleAZ:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case AlbumSortOption.titleZA:
        sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case AlbumSortOption.artist:
        sorted.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case AlbumSortOption.trackCount:
        sorted.sort((a, b) => b.numberOfSongs.compareTo(a.numberOfSongs));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final sortOption = ref.watch(albumSortProvider);

    Widget body;
    switch (library.status) {
      case LibraryStatus.loading:
        body = const SkeletonSongList(itemCount: 8);
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
        final albums = _sorted(library.albums, sortOption);
        body = albums.isEmpty
            ? EmptyLibraryView(
                onRescan: () => ref.read(libraryProvider.notifier).scan(),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.8,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return GestureDetector(
                    onTap: () => context.push(
                      '${AppRoutes.albumDetail}/${album.id}/${Uri.encodeComponent(album.title)}',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ArtworkThumbnail(
                            size: double.infinity,
                            borderRadius: AppRadius.md,
                            id: album.id,
                            type: ArtworkType.ALBUM,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          album.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${album.numberOfSongs} songs',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                Text('Albums', style: Theme.of(context).textTheme.headlineLarge),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: () => showSortPickerSheet(
                    context,
                    title: 'Sort Albums',
                    options: AlbumSortOption.values.map((option) {
                      return (
                        label: option.label,
                        isSelected: option == sortOption,
                        onTap: () =>
                            ref.read(albumSortProvider.notifier).setSort(option),
                      );
                    }).toList(),
                  ),
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
