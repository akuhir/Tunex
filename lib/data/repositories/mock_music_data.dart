import '../models/song.dart';

/// Fixture catalogue kept for widget tests / design previews.
///
/// As of Phase 2 the app itself is fully wired to real device data via
/// [MusicRepository] / [libraryProvider] — nothing in `lib/features`
/// imports this anymore. Safe to delete once real widget tests exist,
/// or keep around for quick UI experiments without a device attached.
class MockMusicData {
  MockMusicData._();

  static final List<Song> songs = [
    const Song(
      id: '1',
      title: 'Midnight Drive',
      artist: 'Nova Ray',
      album: 'Neon Hours',
      duration: Duration(minutes: 3, seconds: 42),
      filePath: '/storage/mock/midnight_drive.mp3',
      isFavorite: true,
    ),
    const Song(
      id: '2',
      title: 'Glass Horizon',
      artist: 'Echo Valley',
      album: 'Afterglow',
      duration: Duration(minutes: 4, seconds: 5),
      filePath: '/storage/mock/glass_horizon.mp3',
    ),
    const Song(
      id: '3',
      title: 'Violet Skies',
      artist: 'Nova Ray',
      album: 'Neon Hours',
      duration: Duration(minutes: 3, seconds: 18),
      filePath: '/storage/mock/violet_skies.mp3',
    ),
    const Song(
      id: '4',
      title: 'Static Bloom',
      artist: 'Halcyon Drift',
      album: 'Static Bloom',
      duration: Duration(minutes: 3, seconds: 55),
      filePath: '/storage/mock/static_bloom.mp3',
      isFavorite: true,
    ),
    const Song(
      id: '5',
      title: 'Paper Moons',
      artist: 'Echo Valley',
      album: 'Afterglow',
      duration: Duration(minutes: 2, seconds: 51),
      filePath: '/storage/mock/paper_moons.mp3',
    ),
    const Song(
      id: '6',
      title: 'Amber Tide',
      artist: 'Solstice Kid',
      album: 'Amber Tide',
      duration: Duration(minutes: 4, seconds: 20),
      filePath: '/storage/mock/amber_tide.mp3',
    ),
  ];

  static List<Song> get recentlyPlayed => songs.take(4).toList();
  static List<Song> get mostPlayed => songs.reversed.take(4).toList();
  static List<Song> get favorites =>
      songs.where((s) => s.isFavorite).toList();

  static List<String> get albums =>
      songs.map((s) => s.album).toSet().toList();
  static List<String> get artists =>
      songs.map((s) => s.artist).toSet().toList();
}
