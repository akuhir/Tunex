import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Reactive set of favorite song ids. A [StateNotifier] wrapping the
/// Hive-backed repository so toggling a favorite anywhere (Now
/// Playing's heart icon, a song's three-dot menu) notifies every
/// screen watching this — Home's Favorites rail, the dedicated
/// Favorites page, and any song tile showing a filled/outline heart.
class FavoriteIdsNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repository;

  FavoriteIdsNotifier(this._repository) : super(_repository.getFavoriteIds());

  Future<void> toggle(String songId) async {
    await _repository.toggleFavorite(songId);
    state = _repository.getFavoriteIds();
  }

  bool isFavorite(String songId) => state.contains(songId);
}

final favoriteIdsProvider =
    StateNotifierProvider<FavoriteIdsNotifier, Set<String>>((ref) {
  return FavoriteIdsNotifier(ref.watch(favoritesRepositoryProvider));
});
