import 'package:equatable/equatable.dart';

/// Represents a single audio track.
///
/// Backed by real Android MediaStore data.
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
  /// MediaStore DATE_ADDED timestamp. Android exposes this in seconds since epoch.
  final DateTime? dateAdded;
  final bool isFavorite;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.dateAdded,
    this.albumId,
    this.artistId,
    this.artworkPath,
    this.isFavorite = false,
  });

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
      dateAdded: dateAdded,
      artworkPath: artworkPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, artist, album, filePath, dateAdded];
}

