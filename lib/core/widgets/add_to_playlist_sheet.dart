import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/playlists_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Sheet shown from a song's three-dot menu — lists existing playlists
/// (tap to add [song] to one) plus a "New Playlist" action that
/// prompts for a name and adds the song to it immediately.
Future<void> showAddToPlaylistSheet(BuildContext context, {required Song song}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => AddToPlaylistSheet(song: song),
  );
}

class AddToPlaylistSheet extends ConsumerWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Add to Playlist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_rounded, color: AppColors.primary),
              title: Text(
                'New Playlist',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final name = await _promptForName(context);
                if (name == null || name.trim().isEmpty) return;
                final created = await ref
                    .read(playlistsProvider.notifier)
                    .createPlaylist(name.trim());
                if (created) {
                  await ref
                      .read(playlistsProvider.notifier)
                      .addSong(name.trim(), song.id);
                }
              },
            ),
            const Divider(height: 1),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No playlists yet — create one above.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final alreadyIn = playlist.songIds.contains(song.id);
                    return ListTile(
                      leading: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        '${playlist.songIds.length} songs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: alreadyIn
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.success)
                          : null,
                      onTap: () {
                        if (!alreadyIn) {
                          ref
                              .read(playlistsProvider.notifier)
                              .addSong(playlist.name, song.id);
                        }
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
