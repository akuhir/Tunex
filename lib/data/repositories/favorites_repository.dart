import '../services/hive_service.dart';

/// Persisted favorite song ids. Backed by a Hive box storing a single
/// list under one key — favorites are small (hundreds, not millions of
/// entries) so one list read/write per change is simple and fast
/// enough, and avoids per-song box entries that would need cleanup
/// when a song is removed from the device.
class FavoritesRepository {
  static const _key = 'favorite_ids';

  Set<String> getFavoriteIds() {
    final stored = HiveService.favoritesBox.get(_key, defaultValue: <String>[]);
    return Set<String>.from(stored as List);
  }

  Future<void> toggleFavorite(String songId) async {
    final current = getFavoriteIds();
    if (current.contains(songId)) {
      current.remove(songId);
    } else {
      current.add(songId);
    }
    await HiveService.favoritesBox.put(_key, current.toList());
  }

  bool isFavorite(String songId) => getFavoriteIds().contains(songId);
}
