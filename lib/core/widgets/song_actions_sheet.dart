import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/models/song.dart';
import '../../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'add_to_playlist_sheet.dart';
import 'artwork_thumbnail.dart';

/// The three-dot menu from the brief: Play Next, Add to Queue, Add to
/// Playlist, Favorite, Share, Song Details. Shown as a bottom sheet
/// from any song tile across Home/Songs/Albums/Playlists.
///
/// "Set as Ringtone", "View Album", "View Artist", "Delete from
/// Playlist", and "Hide Song" are context-specific (only make sense
/// from certain screens) and are added at their owning screens rather
/// than here, to avoid this generic sheet needing to know its caller.
Future<void> showSongActionsSheet(
  BuildContext context, {
  required Song song,
  VoidCallback? onPlayNext,
  VoidCallback? onAddToQueue,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => SongActionsSheet(
      song: song,
      onPlayNext: onPlayNext,
      onAddToQueue: onAddToQueue,
    ),
  );
}

class SongActionsSheet extends ConsumerWidget {
  final Song song;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToQueue;

  const SongActionsSheet({
    super.key,
    required this.song,
    this.onPlayNext,
    this.onAddToQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteIdsProvider).contains(song.id);

    return SafeArea(
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
            child: Row(
              children: [
                ArtworkThumbnail(size: 48, id: int.tryParse(song.id)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (onPlayNext != null)
            _ActionTile(
              icon: Icons.playlist_play_rounded,
              label: 'Play Next',
              onTap: () {
                Navigator.of(context).pop();
                onPlayNext!();
              },
            ),
          if (onAddToQueue != null)
            _ActionTile(
              icon: Icons.queue_music_rounded,
              label: 'Add to Queue',
              onTap: () {
                Navigator.of(context).pop();
                onAddToQueue!();
              },
            ),
          _ActionTile(
            icon: Icons.playlist_add_rounded,
            label: 'Add to Playlist',
            onTap: () {
              Navigator.of(context).pop();
              showAddToPlaylistSheet(context, song: song);
            },
          ),
          _ActionTile(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            iconColor: isFavorite ? AppColors.primary : null,
            label: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onTap: () {
              ref.read(favoriteIdsProvider.notifier).toggle(song.id);
              Navigator.of(context).pop();
            },
          ),
          if (song.albumId != null)
            _ActionTile(
              icon: Icons.album_rounded,
              label: 'View Album',
              onTap: () {
                Navigator.of(context).pop();
                context.push(
                  '${AppRoutes.albumDetail}/${song.albumId}/${Uri.encodeComponent(song.album)}',
                );
              },
            ),
          _ActionTile(
            icon: Icons.person_rounded,
            label: 'View Artist',
            onTap: () {
              Navigator.of(context).pop();
              context.push(
                '${AppRoutes.artistDetail}/${Uri.encodeComponent(song.artist)}',
              );
            },
          ),
          _ActionTile(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () => Navigator.of(context).pop(),
          ),
          _ActionTile(
            icon: Icons.info_outline_rounded,
            label: 'Song Details',
            onTap: () {
              Navigator.of(context).pop();
              _showSongDetails(context, song);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showSongDetails(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(song.title, style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Artist', value: song.artist),
            _DetailRow(label: 'Album', value: song.album),
            _DetailRow(
              label: 'Duration',
              value:
                  '${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
            _DetailRow(label: 'Path', value: song.filePath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap,
    );
  }
}
