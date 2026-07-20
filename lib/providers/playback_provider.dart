import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models/song.dart';
import '../data/repositories/history_repository.dart';
import '../data/services/tunex_audio_handler.dart';
import 'library_provider.dart';

/// Repeat mode for the UI — mirrors just_audio's [LoopMode] but named
/// for what the Now Playing repeat button actually cycles through.
enum RepeatMode { off, all, one }

/// App-facing playback state — everything the mini player, Now
/// Playing screen, and Home rails need to render, sourced from the
/// real [TunexAudioHandler] streams rather than held ad hoc.
class PlaybackState {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;

  const PlaybackState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
  });

  bool get hasNext => currentIndex < queue.length - 1 || repeatMode == RepeatMode.all;
  bool get hasPrevious => currentIndex > 0;

  PlaybackState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

/// Owns the single [TunexAudioHandler] instance and republishes its
/// audio_service/just_audio streams as [PlaybackState] for the UI.
/// This is the only class in the app that should call into the audio
/// handler — screens call methods here (play/pause/skip/seek), never
/// the handler directly, so there's one place that knows how UI intent
/// maps to playback engine calls.
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final TunexAudioHandler _handler;
  final HistoryRepository _historyRepository;
  StreamSubscription? _mediaItemSub;
  StreamSubscription? _playbackStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _queueSub;
  String? _lastRecordedSongId;

  PlaybackNotifier(this._handler, this._historyRepository)
      : super(const PlaybackState()) {
    _mediaItemSub = _handler.mediaItem.listen((item) {
      final song = _handler.currentSong;
      state = state.copyWith(
        currentSong: song,
        currentIndex: _handler.currentIndex ?? 0,
        duration: item?.duration ?? Duration.zero,
      );

      // Record exactly once per track start, not on every mediaItem
      // republish (seeking, buffering updates, etc also flow through
      // this stream in some cases).
      if (song != null && song.id != _lastRecordedSongId) {
        _lastRecordedSongId = song.id;
        _historyRepository.recordPlay(song.id);
      }
    });

    _playbackStateSub = _handler.playbackState.listen((playbackState) {
      state = state.copyWith(
        isPlaying: playbackState.playing,
        isBuffering: playbackState.processingState == AudioProcessingState.loading ||
            playbackState.processingState == AudioProcessingState.buffering,
      );
    });

    _positionSub = _handler.positionDataStream.listen((positionData) {
      state = state.copyWith(
        position: positionData.position,
        bufferedPosition: positionData.bufferedPosition,
        duration: positionData.duration,
      );
    });

    _handler.player.loopModeStream.listen((loopMode) {
      state = state.copyWith(repeatMode: switch (loopMode) {
        LoopMode.off => RepeatMode.off,
        LoopMode.all => RepeatMode.all,
        LoopMode.one => RepeatMode.one,
      });
    });

    _handler.player.shuffleModeEnabledStream.listen((enabled) {
      state = state.copyWith(shuffleEnabled: enabled);
    });
  }

  /// Plays a single song immediately — used when tapping a song tile
  /// without a broader queue context (e.g. a search result).
  Future<void> play(Song song) async {
    state = state.copyWith(queue: [song]);
    await _handler.playSingle(song);
  }

  /// Plays [songs] as a queue starting at [startIndex] — used when
  /// tapping a song inside a list (Songs tab, an album, a rail) so
  /// next/previous move through that same list.
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    state = state.copyWith(queue: songs);
    await _handler.setQueue(songs, initialIndex: startIndex);
  }

  Future<void> togglePlayPause() async {
    if (state.currentSong == null) return;
    if (state.isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  /// Explicit pause (as opposed to [togglePlayPause]) — used by the
  /// sleep timer, which always wants to stop playback, never start it.
  Future<void> pause() => _handler.pause();

  Future<void> skipNext() => _handler.skipToNext();
  Future<void> skipPrevious() => _handler.skipToPrevious();
  Future<void> seek(Duration position) => _handler.seek(position);
  Future<void> cycleRepeatMode() => _handler.cycleRepeatMode();

  Future<void> toggleShuffle() =>
      _handler.setShuffleEnabled(!state.shuffleEnabled);

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    _playbackStateSub?.cancel();
    _positionSub?.cancel();
    _queueSub?.cancel();
    super.dispose();
  }
}

/// The single shared [TunexAudioHandler] for the app's lifetime.
/// Initialized once via [AudioService.init] in main.dart and provided
/// here so [PlaybackNotifier] (and nothing else) can reach it.
final audioHandlerProvider = Provider<TunexAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden in main.dart after '
    'AudioService.init() completes.',
  );
});

final playbackProvider =
    StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(
    ref.watch(audioHandlerProvider),
    ref.watch(historyRepositoryProvider),
  );
});
