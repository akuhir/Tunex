import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/album.dart';
import '../data/models/song.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/music_repository.dart';
import 'favorites_provider.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepository();
});

/// UI-facing state for the library scan — mirrors [LibraryScanStatus]
/// plus loading, so screens can show a skeleton, a permission prompt,
/// an error, or the real list with one `when`-style switch.
enum LibraryStatus { loading, ready, permissionDenied, permissionPermanentlyDenied, error }

class LibraryState {
  final LibraryStatus status;
  final List<Song> songs;
  final List<Album> albums;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.loading,
    this.songs = const [],
    this.albums = const [],
    this.errorMessage,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<Song>? songs,
    List<Album>? albums,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<String> get artistNames =>
      songs.map((s) => s.artist).toSet().toList()..sort();
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  bool _isScanning = false;
  final MusicRepository _repository;

  LibraryNotifier(this._repository) : super(const LibraryState()) {
    scan();
  }

  Future<void> scan() async {
    if (_isScanning) return;
    _isScanning = true;
    try {
    state = state.copyWith(status: LibraryStatus.loading);

    final result = await _repository.scanSongs();

    switch (result.status) {
      case LibraryScanStatus.success:
        state = LibraryState(
          status: LibraryStatus.ready,
          songs: result.songs,
          albums: result.albums,
        );
        break;
      case LibraryScanStatus.permissionDenied:
        state = state.copyWith(status: LibraryStatus.permissionDenied);
        break;
      case LibraryScanStatus.permissionPermanentlyDenied:
        state =
            state.copyWith(status: LibraryStatus.permissionPermanentlyDenied);
        break;
      case LibraryScanStatus.error:
        state = state.copyWith(
          status: LibraryStatus.error,
          errorMessage: result.errorMessage,
        );
        break;
    }
    } finally {
      _isScanning = false;
    }
  }
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier(ref.watch(musicRepositoryProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// Derived, cheap-to-recompute rails for Home. These stay providers
/// (not fields on LibraryState) so Home only rebuilds the rails that
/// actually change.
final recentlyAddedProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  return songs.take(10).toList();
});

/// Real favorites, sourced from the persisted [favoriteIdsProvider]
/// rather than [Song.isFavorite] (which is never set — MediaStore has
/// no concept of "favorite", so this has to be app-side state).
final favoriteSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  final favoriteIds = ref.watch(favoriteIdsProvider);
  return songs.where((s) => favoriteIds.contains(s.id)).toList();
});

/// Real listening history, backed by [HistoryRepository]. Falls back
/// to a shuffled sample of the library when there's no history yet
/// (fresh install) so the rail isn't empty on first run.
final mostPlayedProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  final history = ref.watch(historyRepositoryProvider);
  final ids = history.mostPlayedIds();

  if (ids.isEmpty) {
    return songs.length > 8
        ? (List<Song>.from(songs)..shuffle()).take(8).toList()
        : songs;
  }

  final byId = {for (final s in songs) s.id: s};
  return ids.map((id) => byId[id]).whereType<Song>().toList();
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(libraryProvider).songs;
  final history = ref.watch(historyRepositoryProvider);
  final ids = history.recentlyPlayedIds();

  final byId = {for (final s in songs) s.id: s};
  return ids.map((id) => byId[id]).whereType<Song>().toList();
});
