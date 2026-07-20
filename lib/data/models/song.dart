import 'package:equatable/equatable.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

/// Represents a single audio track.
///
/// Backed by real MediaStore data via `on_audio_query` as of Phase 2.
/// `id` stays a [String] (stringified from the platform's int id) so
/// every call site that treats it as an opaque identifier — which is
/// all of them — didn't need to change when this swapped from mock
/// data to real device data.
class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int? artistId;
  final String? artworkPath;
  final Duration duration;
  final String filePath;
  final bool isFavorite;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.albumId,
    this.artistId,
    this.artworkPath,
    this.isFavorite = false,
  });

  /// Maps a raw `on_audio_query` [SongModel] (a MediaStore row) into
  /// our domain model. This is the single seam between "on_audio_query
  /// package shape" and "what the rest of the app works with" — if the
  /// package's field names ever change, only this factory needs to.
  factory Song.fromSongModel(SongModel model) {
    return Song(
      id: model.id.toString(),
      title: model.title,
      artist: (model.artist == null || model.artist == '<unknown>')
          ? 'Unknown Artist'
          : model.artist!,
      album: (model.album == null || model.album == '<unknown>')
          ? 'Unknown Album'
          : model.album!,
      albumId: model.albumId,
      artistId: model.artistId,
      duration: Duration(milliseconds: model.duration ?? 0),
      filePath: model.data,
    );
  }

  Song copyWith({bool? isFavorite}) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      albumId: albumId,
      artistId: artistId,
      duration: duration,
      filePath: filePath,
      artworkPath: artworkPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, artist, album, filePath];
}

