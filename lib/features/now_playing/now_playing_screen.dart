import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/song.dart';
import '../../data/services/equalizer_service.dart';
import '../../data/services/lyrics_service.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playback_provider.dart';
import '../settings/widgets/sleep_timer_sheet.dart';
import 'widgets/audio_visualizer.dart';
import 'widgets/queue_sheet.dart';

/// The full-screen player. Reached by tapping the mini player.
///
/// Layout follows the brief (large artwork, blurred/gradient
/// backdrop, glassmorphism controls, seek bar, queue/share, lyrics)
/// and borrows the reference mockup's "MADE FOR YOU" tag + inline
/// lyrics panel treatment. Every control here drives real playback
/// through [playbackProvider], plus a bar visualizer, real LRC lyrics
/// lookup, a queue viewer, sleep timer, and system equalizer shortcut.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;

    if (song == null) {
      // Shouldn't normally be reachable (mini player only shows once
      // a song is playing), but guard for safety / hot-reload states.
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Nothing is playing',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.ambientGradient),
        child: SafeArea(
          child: GestureDetector(
            // Swipe left → next, swipe right → previous, matching the
            // brief's "swipe between songs".
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) {
                ref.read(playbackProvider.notifier).skipNext();
              } else if (velocity > 200) {
                ref.read(playbackProvider.notifier).skipPrevious();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  const _TopBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _ArtworkHero(songId: int.tryParse(song.id)),
                  const SizedBox(height: AppSpacing.xl),
                  _TrackInfoRow(
                    songId: song.id,
                    title: song.title,
                    artist: song.artist,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SeekBar(
                    position: playback.position,
                    duration: playback.duration,
                    onSeek: (position) =>
                        ref.read(playbackProvider.notifier).seek(position),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TransportControls(
                    isPlaying: playback.isPlaying,
                    isBuffering: playback.isBuffering,
                    shuffleEnabled: playback.shuffleEnabled,
                    repeatMode: playback.repeatMode,
                    hasNext: playback.hasNext,
                    hasPrevious: playback.hasPrevious,
                    onPlayPause: () =>
                        ref.read(playbackProvider.notifier).togglePlayPause(),
                    onNext: () => ref.read(playbackProvider.notifier).skipNext(),
                    onPrevious: () =>
                        ref.read(playbackProvider.notifier).skipPrevious(),
                    onToggleShuffle: () =>
                        ref.read(playbackProvider.notifier).toggleShuffle(),
                    onCycleRepeat: () =>
                        ref.read(playbackProvider.notifier).cycleRepeatMode(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AudioVisualizer(isPlaying: playback.isPlaying),
                  const SizedBox(height: AppSpacing.lg),
                  _UtilityRow(song: song),
                  const SizedBox(height: AppSpacing.xl),
                  _LyricsPanel(song: song),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Text('Now Playing', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ArtworkHero extends StatelessWidget {
  final int? songId;

  const _ArtworkHero({this.songId});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: ArtworkThumbnail(
              size: double.infinity,
              borderRadius: AppRadius.xl,
              id: songId,
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'MADE FOR YOU',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackInfoRow extends ConsumerWidget {
  final String songId;
  final String title;
  final String artist;

  const _TrackInfoRow({
    required this.songId,
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteIdsProvider).contains(songId);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(artist, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.primary : AppColors.textSecondary,
            size: 26,
          ),
          onPressed: () =>
              ref.read(favoriteIdsProvider.notifier).toggle(songId),
        ),
      ],
    );
  }
}

class _SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  // While the user is actively dragging, show their drag position
  // instead of the stream's position (which would otherwise fight the
  // thumb). Null means "not dragging — follow the real stream".
  double? _dragValue;

  String _formatDuration(Duration d) {
    if (d.isNegative) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds;
    final maxMs = totalMs > 0 ? totalMs.toDouble() : 1.0;
    final currentMs =
        _dragValue ?? widget.position.inMilliseconds.toDouble().clamp(0, maxMs);
    final remaining = widget.duration - widget.position;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: currentMs,
            max: maxMs,
            onChanged: totalMs > 0
                ? (value) => setState(() => _dragValue = value)
                : null,
            onChangeEnd: totalMs > 0
                ? (value) {
                    widget.onSeek(Duration(milliseconds: value.round()));
                    setState(() => _dragValue = null);
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '-${_formatDuration(remaining)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;

  const _TransportControls({
    required this.isPlaying,
    required this.isBuffering,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.hasNext,
    required this.hasPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
  });

  IconData get _repeatIcon => switch (repeatMode) {
        RepeatMode.one => Icons.repeat_one_rounded,
        _ => Icons.repeat_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.shuffle_rounded),
          color: shuffleEnabled ? AppColors.primary : AppColors.textSecondary,
          onPressed: onToggleShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, size: 34),
          color: hasPrevious ? AppColors.textPrimary : AppColors.textSecondary,
          onPressed: onPrevious,
        ),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: isBuffering
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 34),
          color: hasNext ? AppColors.textPrimary : AppColors.textSecondary,
          onPressed: onNext,
        ),
        IconButton(
          icon: Icon(_repeatIcon),
          color: repeatMode == RepeatMode.off
              ? AppColors.textSecondary
              : AppColors.primary,
          onPressed: onCycleRepeat,
        ),
      ],
    );
  }
}

class _UtilityRow extends ConsumerWidget {
  final Song song;

  const _UtilityRow({required this.song});

  Future<void> _openEqualizer(BuildContext context, WidgetRef ref) async {
    final sessionId =
        await ref.read(audioHandlerProvider).androidAudioSessionIdStream.first;
    if (sessionId == null) return;

    final launched = await EqualizerService.launch(audioSessionId: sessionId);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No system equalizer found on this device"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _UtilityIcon(
          icon: Icons.queue_music_rounded,
          label: 'Queue',
          onTap: () => showQueueSheet(context),
        ),
        _UtilityIcon(
          icon: Icons.bedtime_rounded,
          label: 'Sleep',
          onTap: () => showSleepTimerSheet(context),
        ),
        _UtilityIcon(
          icon: Icons.equalizer_rounded,
          label: 'Equalizer',
          onTap: () => _openEqualizer(context, ref),
        ),
        _UtilityIcon(
          icon: Icons.ios_share_rounded,
          label: 'Share',
          onTap: () {
            // Sharing a local audio file requires either a platform
            // share-sheet plugin or a server-hosted link — neither is
            // in scope for an offline-only player, so this is left as
            // a visible-but-inert action rather than faking success.
          },
        ),
      ],
    );
  }
}

class _UtilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilityIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Inline lyrics panel — shows lyrics from a matching `.lrc` file if
/// one exists next to the audio file, per the brief's "Lyrics (LRC if
/// available)". Displayed as plain text, not synced to playback
/// position — Tunex intentionally shows the full lyric block rather
/// than highlighting/auto-scrolling the current line.
class _LyricsPanel extends StatefulWidget {
  final Song song;

  const _LyricsPanel({required this.song});

  @override
  State<_LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends State<_LyricsPanel> {
  bool _expanded = true;
  late Future<String?> _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = LyricsService.load(widget.song.filePath);
  }

  @override
  void didUpdateWidget(covariant _LyricsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.filePath != widget.song.filePath) {
      _lyricsFuture = LyricsService.load(widget.song.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lyrics', style: Theme.of(context).textTheme.titleMedium),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<String?>(
              future: _lyricsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final lyrics = snapshot.data;
                if (lyrics == null || lyrics.trim().isEmpty) {
                  return Text(
                    'No lyrics found for this track. Add a matching '
                    '.lrc file next to the song to see them here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }

                return Text(
                  lyrics,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
