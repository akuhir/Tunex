import 'package:equatable/equatable.dart';

/// A user-created playlist: a name plus an ordered list of song ids.
/// Song ids reference [Song.id] (stringified MediaStore ids) rather
/// than embedding full [Song] objects, so a playlist stays valid even
/// if the underlying library is rescanned — the repository resolves
/// ids back to songs at read time.
class Playlist extends Equatable {
  final String name;
  final List<String> songIds;

  const Playlist({required this.name, required this.songIds});

  Playlist copyWith({String? name, List<String>? songIds}) {
    return Playlist(
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
    );
  }

  @override
  List<Object?> get props => [name, songIds];
}
