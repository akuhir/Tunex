import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/playlist.dart';
import '../data/repositories/playlists_repository.dart';

final playlistsRepositoryProvider = Provider<PlaylistsRepository>((ref) {
  return PlaylistsRepository();
});

/// Reactive list of the user's playlists. Every mutating method
/// re-reads from the repository afterward rather than optimistically
/// patching state — playlists are small in number so this stays cheap,
/// and it guarantees the UI never drifts from what's actually on disk.
class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  final PlaylistsRepository _repository;

  PlaylistsNotifier(this._repository) : super(_repository.getAllPlaylists());

  void _refresh() => state = _repository.getAllPlaylists();

  Future<bool> createPlaylist(String name) async {
    final created = await _repository.createPlaylist(name);
    if (created) _refresh();
    return created;
  }

  Future<void> deletePlaylist(String name) async {
    await _repository.deletePlaylist(name);
    _refresh();
  }

  Future<void> renamePlaylist(String oldName, String newName) async {
    await _repository.renamePlaylist(oldName, newName);
    _refresh();
  }

  Future<void> addSong(String playlistName, String songId) async {
    await _repository.addSong(playlistName, songId);
    _refresh();
  }

  Future<void> removeSong(String playlistName, String songId) async {
    await _repository.removeSong(playlistName, songId);
    _refresh();
  }

  Future<void> reorderSongs(String playlistName, List<String> newOrder) async {
    await _repository.reorderSongs(playlistName, newOrder);
    _refresh();
  }
}

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier(ref.watch(playlistsRepositoryProvider));
});
