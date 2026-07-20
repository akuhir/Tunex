import 'package:flutter/material.dart';
import '../../data/models/song.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'artwork_thumbnail.dart';
import 'glass_container.dart';

/// The persistent mini player, docked above the bottom nav whenever a
/// song is loaded. Tapping it (outside the play/pause button) expands
/// into the full Now Playing screen. Shows a thin real-time progress
/// line and a buffering spinner in place of the play/pause icon while
/// the next track is loading.
class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isBuffering;
  final double progress; // 0..1
  final VoidCallback onPlayPause;
  final VoidCallback? onExpand;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    this.isBuffering = false,
    this.progress = 0,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onExpand,
        child: GlassContainer(
          borderRadius: AppRadius.lg,
          fillOpacity: 0.10,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    ArtworkThumbnail(
                      size: 44,
                      borderRadius: AppRadius.sm,
                      id: int.tryParse(song.id),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: isBuffering
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.textPrimary,
                                size: 30,
                              ),
                              onPressed: onPlayPause,
                            ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg),
                ),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 2,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor:
                      AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
