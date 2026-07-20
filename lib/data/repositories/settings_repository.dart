import '../services/hive_service.dart';

enum SongSortOption { titleAZ, titleZA, artist, album, durationLongest, durationShortest }

enum AlbumSortOption { titleAZ, titleZA, artist, trackCount }

extension SongSortOptionLabel on SongSortOption {
  String get label => switch (this) {
        SongSortOption.titleAZ => 'Title (A–Z)',
        SongSortOption.titleZA => 'Title (Z–A)',
        SongSortOption.artist => 'Artist',
        SongSortOption.album => 'Album',
        SongSortOption.durationLongest => 'Duration (longest first)',
        SongSortOption.durationShortest => 'Duration (shortest first)',
      };
}

extension AlbumSortOptionLabel on AlbumSortOption {
  String get label => switch (this) {
        AlbumSortOption.titleAZ => 'Title (A–Z)',
        AlbumSortOption.titleZA => 'Title (Z–A)',
        AlbumSortOption.artist => 'Artist',
        AlbumSortOption.trackCount => 'Track Count',
      };
}

/// Persisted app settings: accent color choice, song/album sort
/// order. Read once at startup and updated whenever the user changes
/// something in Settings.
class SettingsRepository {
  static const _accentKey = 'accent_name';
  static const _songSortKey = 'song_sort';
  static const _albumSortKey = 'album_sort';

  String getAccentName() {
    return HiveService.settingsBox.get(_accentKey, defaultValue: 'Violet') as String;
  }

  Future<void> setAccentName(String name) async {
    await HiveService.settingsBox.put(_accentKey, name);
  }

  SongSortOption getSongSort() {
    final index = HiveService.settingsBox.get(_songSortKey, defaultValue: 0) as int;
    return SongSortOption.values[index.clamp(0, SongSortOption.values.length - 1)];
  }

  Future<void> setSongSort(SongSortOption option) async {
    await HiveService.settingsBox.put(_songSortKey, option.index);
  }

  AlbumSortOption getAlbumSort() {
    final index = HiveService.settingsBox.get(_albumSortKey, defaultValue: 0) as int;
    return AlbumSortOption.values[index.clamp(0, AlbumSortOption.values.length - 1)];
  }

  Future<void> setAlbumSort(AlbumSortOption option) async {
    await HiveService.settingsBox.put(_albumSortKey, option.index);
  }
}
