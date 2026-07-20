import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Drives the accent color choice. On creation, reads the persisted
/// value and applies it via [AppColors.setAccent] immediately — this
/// runs at app startup (see main.dart) so the correct accent is live
/// before the first frame the user actually sees.
class AccentNotifier extends StateNotifier<String> {
  final SettingsRepository _repository;

  AccentNotifier(this._repository) : super(_repository.getAccentName()) {
    AppColors.setAccent(state);
  }

  Future<void> setAccent(String name) async {
    await _repository.setAccentName(name);
    AppColors.setAccent(name);
    state = name;
  }
}

final accentProvider = StateNotifierProvider<AccentNotifier, String>((ref) {
  return AccentNotifier(ref.watch(settingsRepositoryProvider));
});

class SongSortNotifier extends StateNotifier<SongSortOption> {
  final SettingsRepository _repository;

  SongSortNotifier(this._repository) : super(_repository.getSongSort());

  Future<void> setSort(SongSortOption option) async {
    await _repository.setSongSort(option);
    state = option;
  }
}

final songSortProvider =
    StateNotifierProvider<SongSortNotifier, SongSortOption>((ref) {
  return SongSortNotifier(ref.watch(settingsRepositoryProvider));
});

class AlbumSortNotifier extends StateNotifier<AlbumSortOption> {
  final SettingsRepository _repository;

  AlbumSortNotifier(this._repository) : super(_repository.getAlbumSort());

  Future<void> setSort(AlbumSortOption option) async {
    await _repository.setAlbumSort(option);
    state = option;
  }
}

final albumSortProvider =
    StateNotifierProvider<AlbumSortNotifier, AlbumSortOption>((ref) {
  return AlbumSortNotifier(ref.watch(settingsRepositoryProvider));
});

/// Sorts [songs] according to [option]. Pure function so it's usable
/// from any screen (Songs tab, search results, etc) without needing a
/// widget context.
List<T> applySongSort<T>(
  List<T> songs,
  SongSortOption option, {
  required String Function(T) title,
  required String Function(T) artist,
  required String Function(T) album,
  required Duration Function(T) duration,
}) {
  final sorted = List<T>.from(songs);
  switch (option) {
    case SongSortOption.titleAZ:
      sorted.sort((a, b) => title(a).toLowerCase().compareTo(title(b).toLowerCase()));
      break;
    case SongSortOption.titleZA:
      sorted.sort((a, b) => title(b).toLowerCase().compareTo(title(a).toLowerCase()));
      break;
    case SongSortOption.artist:
      sorted.sort((a, b) => artist(a).toLowerCase().compareTo(artist(b).toLowerCase()));
      break;
    case SongSortOption.album:
      sorted.sort((a, b) => album(a).toLowerCase().compareTo(album(b).toLowerCase()));
      break;
    case SongSortOption.durationLongest:
      sorted.sort((a, b) => duration(b).compareTo(duration(a)));
      break;
    case SongSortOption.durationShortest:
      sorted.sort((a, b) => duration(a).compareTo(duration(b)));
      break;
  }
  return sorted;
}
