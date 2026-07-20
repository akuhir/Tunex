import 'package:flutter/material.dart';
import '../../data/models/song.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'artwork_thumbnail.dart';

/// The canonical song row: artwork, title/artist, duration, three-dot
/// menu. Reused across Home ("Recently Played" etc.), Songs, Album
/// detail, Playlist detail — anywhere a flat song list appears.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showDuration;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.showDuration = true,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ArtworkThumbnail(size: 52, id: int.tryParse(song.id)),
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
            if (showDuration) ...[
              Text(
                _formatDuration(song.duration),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              color: AppColors.textSecondary,
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
