import 'package:hive_flutter/hive_flutter.dart';

/// Local persistence for anything that must survive app restarts but
/// isn't part of the device's own MediaStore: favorite song ids,
/// playlists, listening history for "Most Played", and app settings
/// (accent color, sort order).
///
/// Uses Hive directly with primitive types (no generated adapters) —
/// favorites are a `Set<String>` of song ids, playlists are a
/// `Map<String, List<String>>` of playlist name to ordered song ids.
/// This keeps the schema simple and avoids codegen churn while the
/// data shape is still likely to change across phases.
class HiveService {
  HiveService._();

  static const _favoritesBoxName = 'favorites';
  static const _playlistsBoxName = 'playlists';
  static const _historyBoxName = 'history';
  static const _settingsBoxName = 'settings';

  static late Box<dynamic> _favoritesBox;
  static late Box<dynamic> _playlistsBox;
  static late Box<dynamic> _historyBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _favoritesBox = await Hive.openBox(_favoritesBoxName);
    _playlistsBox = await Hive.openBox(_playlistsBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Box<dynamic> get favoritesBox => _favoritesBox;
  static Box<dynamic> get playlistsBox => _playlistsBox;
  static Box<dynamic> get historyBox => _historyBox;
  static Box<dynamic> get settingsBox => _settingsBox;
}
