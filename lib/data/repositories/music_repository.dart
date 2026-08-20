import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../services/permission_service.dart';

enum LibraryScanStatus { success, permissionDenied, permissionPermanentlyDenied, error }

class LibraryScanResult {
  final LibraryScanStatus status;
  final List<Song> songs;
  final List<Album> albums;
  final String? errorMessage;
  const LibraryScanResult({required this.status, this.songs = const [], this.albums = const [], this.errorMessage});
}

class MusicRepository {
  static const MethodChannel _channel = MethodChannel('com.tunex.app/media_store');

  Future<LibraryScanResult> scanSongs() async {
    try {
      var hasPermission = await PermissionService.hasAudioPermission();
      debugPrint('[Tunex] Media permission before scan: $hasPermission');
      if (!hasPermission) {
        final granted = await PermissionService.requestAudioPermission();
        debugPrint('[Tunex] Media permission request result: $granted');
        if (!granted) {
          final permanent = await PermissionService.isPermanentlyDenied();
          return LibraryScanResult(
            status: permanent ? LibraryScanStatus.permissionPermanentlyDenied : LibraryScanStatus.permissionDenied,
          );
        }
        hasPermission = await PermissionService.hasAudioPermission();
        debugPrint('[Tunex] Media permission after request: $hasPermission');
        if (!hasPermission) {
          return const LibraryScanResult(status: LibraryScanStatus.permissionDenied);
        }
      }

      final raw = await _channel.invokeMapMethod<String, dynamic>('scanLibrary');
      final songsRaw = (raw?['songs'] as List?) ?? const [];
      final albumsRaw = (raw?['albums'] as List?) ?? const [];
      final songs = songsRaw.map((e) => _songFromMap(Map<String, dynamic>.from(e as Map))).toList();
      final albums = albumsRaw.map((e) => _albumFromMap(Map<String, dynamic>.from(e as Map))).toList();
      debugPrint('[Tunex] MediaStore scan: ${songs.length} songs, ${albums.length} albums');
      return LibraryScanResult(status: LibraryScanStatus.success, songs: songs, albums: albums);
    } on PlatformException catch (e, st) {
      debugPrint('[Tunex] MediaStore error: ${e.code} ${e.message}\n$st');
      return LibraryScanResult(status: LibraryScanStatus.error, errorMessage: e.message ?? e.code);
    } catch (e, st) {
      debugPrint('[Tunex] MediaStore scan failed: $e\n$st');
      return LibraryScanResult(status: LibraryScanStatus.error, errorMessage: e.toString());
    }
  }

  Song _songFromMap(Map<String, dynamic> m) => Song(
    id: '${m['id']}', title: m['title'] ?? 'Unknown Title', artist: m['artist'] ?? 'Unknown Artist',
    album: m['album'] ?? 'Unknown Album', dateAdded: (m['dateAdded'] as num?) != null
        ? DateTime.fromMillisecondsSinceEpoch((m['dateAdded'] as num).toInt() * 1000)
        : null, albumId: (m['albumId'] as num?)?.toInt(), artistId: (m['artistId'] as num?)?.toInt(),
    duration: Duration(milliseconds: (m['duration'] as num? ?? 0).toInt()), filePath: m['path'] ?? '',
  );

  Album _albumFromMap(Map<String, dynamic> m) => Album(
    id: (m['id'] as num).toInt(), title: m['title'] ?? 'Unknown Album', artist: m['artist'] ?? 'Unknown Artist',
    numberOfSongs: (m['numberOfSongs'] as num? ?? 0).toInt(),
  );

  Future<List<Album>> queryAlbums() async {
    final result = await scanSongs();
    return result.albums;
  }

  Future<Uint8List?> artwork(int id, {bool album = false}) async {
    final bytes = await _channel.invokeMethod<Uint8List>('getArtwork', {'id': id, 'album': album});
    return bytes;
  }
}
