import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../models/album.dart';
import '../models/song.dart';
import 'permission_service.dart';

/// Result of a library scan — either songs, or a reason we don't have any.
enum LibraryScanStatus { success, permissionDenied, permissionPermanentlyDenied, error }

class LibraryScanResult {
  final LibraryScanStatus status;
  final List<Song> songs;
  final List<Album> albums;
  final String? errorMessage;

  const LibraryScanResult({
    required this.status,
    this.songs = const [],
    this.albums = const [],
    this.errorMessage,
  });
}

/// Reads the device's audio library via MediaStore (`on_audio_query`).
///
/// This is the only place in the app that talks to the platform media
/// index. Everything else — providers, screens — consumes [Song],
/// [Album], and [Artist] domain models, so if the underlying query
/// package is ever swapped, only this file changes.
class MusicRepository {
  final OnAudioQuery _query = OnAudioQuery();

  /// Scans the device for all supported audio files. Returns a
  /// [LibraryScanResult] describing what happened rather than
  /// throwing, so the UI can render permission/error states cleanly.
  ///
  /// Deliberately does NOT gate this on a permission_handler/plugin
  /// status check first. A confirmed real-device case (Android 11,
  /// TECNO OEM build) showed Android's own Settings screen reporting
  /// the permission as Allowed while every permission-status plugin
  /// call still reported not-granted — so trusting any plugin's
  /// self-reported status as a gate was the actual bug. Instead this
  /// just attempts the real MediaStore query directly; Android itself
  /// throws a SecurityException if permission genuinely isn't granted,
  /// which is the only source of truth that can't be wrong. The
  /// permission-request UI flow only runs as a fallback if that direct
  /// attempt fails.
  Future<LibraryScanResult> scanSongs() async {
    try {
      final result = await _attemptQuery();
      if (kDebugMode) {
        debugPrint('[Tunex] direct query succeeded without a prior permission check');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Tunex] direct query failed ($e) — falling back to permission flow');
      }
      // Direct query failed — likely a real permission gap. Fall back
      // to the request flow so the user can grant it.
    }

    final hasPermission = await PermissionService.hasAudioPermission();
    if (kDebugMode) {
      debugPrint('[Tunex] scanSongs — hasPermission: $hasPermission');
    }

    if (!hasPermission) {
      final granted = await PermissionService.requestAudioPermission();
      if (kDebugMode) {
        debugPrint('[Tunex] scanSongs — requestAudioPermission -> $granted');
      }

      if (!granted) {
        final permanentlyDenied = await PermissionService.isPermanentlyDenied();
        return LibraryScanResult(
          status: permanentlyDenied
              ? LibraryScanStatus.permissionPermanentlyDenied
              : LibraryScanStatus.permissionDenied,
        );
      }
    }

    try {
      return await _attemptQuery();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Tunex] scanSongs() threw after permission flow: $e');
        debugPrint('$stackTrace');
      }
      return LibraryScanResult(
        status: LibraryScanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Builds the full song list by querying every album's tracks and
  /// combining them. Throws on failure (including a real permission
  /// gap) rather than catching — callers decide how to interpret that.
  ///
  /// Deliberately does NOT call `_query.querySongs()`. That method has
  /// a confirmed, reproducible native crash — `IllegalStateException:
  /// Reply already submitted` — inside its own Kotlin coroutine
  /// implementation on at least one real device/OS combination
  /// (Android 11, TECNO OEM), present in both `on_audio_query` and its
  /// `_forked` variant. It's a hard process-killing exception that
  /// happens natively before anything reaches Dart, so no amount of
  /// try/catch on this side can recover from it — the only fix is
  /// avoiding that specific method entirely.
  ///
  /// Instead of querySongs(), this aggregates results from
  /// `queryAudiosFrom(AudiosFromType.ALBUM_ID, ...)` across every
  /// album from `queryAlbums()` — both confirmed working without any
  /// crash on this exact device in prior test logs (used successfully
  /// by the Album detail screen already). This means songs with no
  /// album tag (uncommon, but possible) won't appear; that's a
  /// reasonable tradeoff against the alternative, which is the app not
  /// launching at all.
  Future<LibraryScanResult> _attemptQuery() async {
    final albumModels = await _query.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    if (kDebugMode) {
      debugPrint('[Tunex] queryAlbums() raw result count: ${albumModels.length}');
    }

    const supportedExtensions = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'];
    final allSongs = <Song>[];
    final seenIds = <String>{};

    for (final album in albumModels) {
      final tracks = await _query.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        album.id,
      );

      for (final m in tracks) {
        final id = m.id.toString();
        if (seenIds.contains(id)) continue; // a song can span "albums" oddly tagged

        final ext = m.data.split('.').last.toLowerCase();
        final longEnough = (m.duration ?? 0) > 15000; // 15s, excludes ringtones/UI sounds
        if (!supportedExtensions.contains(ext) || !longEnough) continue;

        seenIds.add(id);
        allSongs.add(Song.fromSongModel(m));
      }
    }

    if (kDebugMode) {
      debugPrint('[Tunex] aggregated ${allSongs.length} songs across ${albumModels.length} albums');
    }

    final albums = albumModels
        .map((m) => Album(
              id: m.id,
              title: m.album,
              artist: m.artist ?? 'Unknown Artist',
              numberOfSongs: m.numOfSongs,
            ))
        .toList();

    return LibraryScanResult(
      status: LibraryScanStatus.success,
      songs: allSongs,
      albums: albums,
    );
  }

  Future<List<Album>> queryAlbums() async {
    final models = await _query.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return models
        .map((m) => Album(
              id: m.id,
              title: m.album,
              artist: m.artist ?? 'Unknown Artist',
              numberOfSongs: m.numOfSongs,
            ))
        .toList();
  }

  Future<List<Artist>> queryArtists() async {
    final models = await _query.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return models
        .map((m) => Artist(
              id: m.id,
              name: m.artist,
              numberOfTracks: m.numberOfTracks ?? 0,
              numberOfAlbums: m.numberOfAlbums ?? 0,
            ))
        .toList();
  }

  /// Raw artwork bytes for a song, for `QueryArtworkWidget`-free custom
  /// rendering. Returns null if the file has no embedded art.
  Future<Uint8List?> songArtwork(int songId) {
    return _query.queryArtwork(songId, ArtworkType.AUDIO);
  }
}
