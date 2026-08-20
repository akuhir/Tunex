import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/services/permission_service.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Folders — groups songs by their containing directory, derived from
/// [Song.filePath] rather than a separate MediaStore query (folders
/// aren't a MediaStore concept the way genres/albums are — they're
/// just "which directory is this file in").
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

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

    final byFolder = <String, int>{};
    for (final song in library.songs) {
      final folder = _folderOf(song.filePath);
      byFolder[folder] = (byFolder[folder] ?? 0) + 1;
    }
    final folders = byFolder.keys.toList()..sort();

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
                Text('Folders', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
          Expanded(
            child: folders.isEmpty
                ? EmptyLibraryView(
                    onRescan: () => ref.read(libraryProvider.notifier).scan(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.folder_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                        title: Text(
                          folder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${byFolder[folder]} songs'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _FolderSongsScreen(folder: folder),
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

  String _folderOf(String filePath) {
    final parts = filePath.split('/');
    if (parts.length < 2) return 'Unknown';
    return parts[parts.length - 2];
  }
}

class _FolderSongsScreen extends ConsumerWidget {
  final String folder;

  const _FolderSongsScreen({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final songs = library.songs.where((s) {
      final parts = s.filePath.split('/');
      return parts.length >= 2 && parts[parts.length - 2] == folder;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(folder)),
      body: ListView.builder(
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
      ),
    );
  }
}
