import '../models/playlist.dart';
import '../services/hive_service.dart';

/// Persisted user playlists. Each playlist is stored as a
/// `List<String>` of song ids under its name as the Hive key, so
/// playlist names must be unique — enforced in [createPlaylist].
class PlaylistsRepository {
  List<Playlist> getAllPlaylists() {
    final box = HiveService.playlistsBox;
    return box.keys.map((key) {
      final songIds = List<String>.from(box.get(key) as List);
      return Playlist(name: key as String, songIds: songIds);
    }).toList();
  }

  /// Returns false without creating anything if a playlist with this
  /// name already exists — the UI should surface that as "name taken"
  /// rather than silently overwriting an existing playlist.
  Future<bool> createPlaylist(String name) async {
    final box = HiveService.playlistsBox;
    if (box.containsKey(name)) return false;
    await box.put(name, <String>[]);
    return true;
  }

  Future<void> deletePlaylist(String name) async {
    await HiveService.playlistsBox.delete(name);
  }

  Future<void> renamePlaylist(String oldName, String newName) async {
    final box = HiveService.playlistsBox;
    if (!box.containsKey(oldName) || box.containsKey(newName)) return;
    final songIds = box.get(oldName);
    await box.put(newName, songIds);
    await box.delete(oldName);
  }

  Future<void> addSong(String playlistName, String songId) async {
    final box = HiveService.playlistsBox;
    final songIds = List<String>.from(box.get(playlistName) as List? ?? []);
    if (!songIds.contains(songId)) {
      songIds.add(songId);
      await box.put(playlistName, songIds);
    }
  }

  Future<void> removeSong(String playlistName, String songId) async {
    final box = HiveService.playlistsBox;
    final songIds = List<String>.from(box.get(playlistName) as List? ?? []);
    songIds.remove(songId);
    await box.put(playlistName, songIds);
  }

  Future<void> reorderSongs(String playlistName, List<String> newOrder) async {
    await HiveService.playlistsBox.put(playlistName, newOrder);
  }
}
