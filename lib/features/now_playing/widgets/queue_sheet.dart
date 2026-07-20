import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/artwork_thumbnail.dart';
import '../../../providers/playback_provider.dart';

/// Shows the current playback queue — the brief's "Queue" view from
/// the Now Playing screen. Tapping a song jumps to it by replaying the
/// queue starting at that index (simplest correct implementation given
/// [TunexAudioHandler]'s queue is a fixed ConcatenatingAudioSource
/// rather than something exposing arbitrary jump-to-index directly at
/// this layer). Reordering/removing individual queue entries is a
/// natural follow-up once this ships.
Future<void> showQueueSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => const QueueSheet(),
  );
}

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Queue', style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${playback.queue.length} songs',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: playback.queue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        itemCount: playback.queue.length,
                        itemBuilder: (context, index) {
                          final song = playback.queue[index];
                          final isCurrent = index == playback.currentIndex;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ArtworkThumbnail(
                              size: 44,
                              id: int.tryParse(song.id),
                            ),
                            title: Text(
                              song.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isCurrent
                                ? Icon(Icons.equalizer_rounded,
                                    color: AppColors.primary, size: 20)
                                : null,
                            onTap: isCurrent
                                ? null
                                : () {
                                    ref.read(playbackProvider.notifier).playQueue(
                                          playback.queue,
                                          startIndex: index,
                                        );
                                    Navigator.of(context).pop();
                                  },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
