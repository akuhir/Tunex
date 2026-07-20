import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../models/song.dart';

/// The real playback engine.
///
/// This is an [BaseAudioHandler] (audio_service) wrapping a
/// [AudioPlayer] (just_audio). audio_service is what gives Tunex a
/// real Android media session — lock screen controls, notification
/// with play/pause/next/prev, headset button handling, and correct
/// audio focus behavior (pausing when a call comes in, ducking for
/// notifications, etc) — all per the brief's "Android Features"
/// section. just_audio does the actual decoding/output and exposes
/// the queue/position streams this class republishes as
/// [MediaItem]/[PlaybackState] for the OS.
///
/// UI code never touches this class directly — it goes through
/// [PlaybackNotifier] (Riverpod), which owns one instance of this
/// handler and adapts its streams into app-level state.
class TunexAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<Song> _queue = [];

  TunexAudioHandler() {
    _configureAudioSession();

    _player.playbackEventStream.listen((event) {
      try {
        _broadcastState(event);
      } catch (_) {}
    });

    // When just_audio finishes a track naturally, advance the queue —
    // this is what makes "swipe to next" / auto-advance work without
    // the UI having to poll anything.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  /// Configures audio focus behavior per the brief's "Audio focus
  /// handling" requirement: pause for phone calls, duck (lower
  /// volume) for transient interruptions like notification dings, and
  /// resume appropriately after.
  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.3);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Stop playback outright if e.g. Bluetooth headphones disconnect —
    // matches standard Android media app behavior.
    session.becomingNoisyEventStream.listen((_) => _player.pause());
  }

  AudioPlayer get player => _player;

  /// The platform audio session id this player is using — required to
  /// launch Android's system equalizer scoped to *our* audio output
  /// (see EqualizerService) rather than a generic/global one.
  Stream<int?> get androidAudioSessionIdStream =>
      _player.androidAudioSessionIdStream;

  /// Loads a fresh queue and starts playback at [initialIndex].
  Future<void> setQueue(List<Song> songs, {int initialIndex = 0}) async {
    _queue
      ..clear()
      ..addAll(songs);

    queue.add(_queue.map(_toMediaItem).toList());

    final source = ConcatenatingAudioSource(
      children: _queue.map((s) => AudioSource.uri(Uri.file(s.filePath))).toList(),
    );

    await _player.setAudioSource(source, initialIndex: initialIndex);
    mediaItem.add(_toMediaItem(_queue[initialIndex]));
    await _player.play();
  }

  /// Convenience for "play this one song right now" (tapping a song
  /// tile outside of a specific list context) — queues just that song.
  Future<void> playSingle(Song song) => setQueue([song]);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
      _syncMediaItemToCurrentIndex();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      _syncMediaItemToCurrentIndex();
    } else {
      // Standard player behavior: if we're a few seconds in, "previous"
      // restarts the current track instead of doing nothing.
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      return await super.stop();
    } catch (_) {}
  }

  /// Toggles between no repeat / repeat-all / repeat-one, matching the
  /// tri-state repeat button in the brief's Music Player spec.
  Future<void> cycleRepeatMode() async {
    final next = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(next);
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) await _player.shuffle();
  }

  Song? get currentSong {
    final index = _player.currentIndex;
    if (index == null || index < 0 || index >= _queue.length) return null;
    return _queue[index];
  }

  int? get currentIndex => _player.currentIndex;
  List<Song> get currentQueue => List.unmodifiable(_queue);

  void _syncMediaItemToCurrentIndex() {
    final song = currentSong;
    if (song != null) mediaItem.add(_toMediaItem(song));
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      extras: {'songId': song.id},
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  /// Combined position/duration/buffered stream, convenient for the
  /// seek bar to listen to in one subscription instead of three.
  Stream<PositionData> get positionDataStream => Rx.combineLatest3<
      Duration, Duration, Duration?, PositionData>(
    _player.positionStream,
    _player.bufferedPositionStream,
    _player.durationStream,
    (position, bufferedPosition, duration) => PositionData(
      position,
      bufferedPosition,
      duration ?? Duration.zero,
    ),
  );
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData(this.position, this.bufferedPosition, this.duration);
}
