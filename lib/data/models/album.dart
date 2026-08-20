import 'package:equatable/equatable.dart';

/// An album grouping, as read from MediaStore.
class Album extends Equatable {
  final int id;
  final String title;
  final String artist;
  final int numberOfSongs;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.numberOfSongs,
  });

  @override
  List<Object?> get props => [id, title, artist];
}

/// An artist grouping, as read from MediaStore.
class Artist extends Equatable {
  final int id;
  final String name;
  final int numberOfTracks;
  final int numberOfAlbums;

  const Artist({
    required this.id,
    required this.name,
    required this.numberOfTracks,
    required this.numberOfAlbums,
  });

  @override
  List<Object?> get props => [id, name];
}
