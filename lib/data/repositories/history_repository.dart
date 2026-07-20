import '../services/hive_service.dart';

/// Tracks per-song play counts and last-played timestamps, so Home's
/// "Most Played" and "Recently Played" rails reflect real listening
/// behavior instead of the Phase 3 shuffled-sample placeholder.
///
/// Stored as two parallel maps in one Hive box: `playCount` (songId →
/// int) and `lastPlayed` (songId → millisecondsSinceEpoch). Simple key
/// -value maps are enough here — this never needs querying beyond
/// "give me everything, sorted."
class HistoryRepository {
  static const _playCountKey = 'play_count';
  static const _lastPlayedKey = 'last_played';

  Map<String, int> _playCounts() {
    final raw = HiveService.historyBox.get(_playCountKey, defaultValue: {});
    return Map<String, int>.from(raw as Map);
  }

  Map<String, int> _lastPlayed() {
    final raw = HiveService.historyBox.get(_lastPlayedKey, defaultValue: {});
    return Map<String, int>.from(raw as Map);
  }

  /// Call when a song starts playing — increments its play count and
  /// stamps it as most-recently-played.
  Future<void> recordPlay(String songId) async {
    final counts = _playCounts();
    counts[songId] = (counts[songId] ?? 0) + 1;
    await HiveService.historyBox.put(_playCountKey, counts);

    final lastPlayed = _lastPlayed();
    lastPlayed[songId] = DateTime.now().millisecondsSinceEpoch;
    await HiveService.historyBox.put(_lastPlayedKey, lastPlayed);
  }

  /// Song ids ordered by play count, most-played first. Ids with no
  /// recorded plays are omitted — callers should fall back to
  /// something else (e.g. recently added) when this is empty.
  List<String> mostPlayedIds({int limit = 20}) {
    final counts = _playCounts();
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Song ids ordered by most recently played first.
  List<String> recentlyPlayedIds({int limit = 20}) {
    final lastPlayed = _lastPlayed();
    final sorted = lastPlayed.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}
