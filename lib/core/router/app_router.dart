import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/songs/songs_screen.dart';
import '../../features/albums/albums_screen.dart';
import '../../features/albums/album_detail_screen.dart';
import '../../features/artists/artists_screen.dart';
import '../../features/artists/artist_detail_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/now_playing/now_playing_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/playlists/playlist_detail_screen.dart';
import '../../features/genres/genres_screen.dart';
import '../../features/folders/folders_screen.dart';
import '../../features/settings/about_screen.dart';
import '../widgets/app_shell.dart';

/// Route path constants — referenced by name elsewhere instead of
/// hardcoded strings, so renames are a one-line change.
///
/// Bottom nav stays Home/Songs/Albums/Artists/Settings (the brief's
/// original spec); Favorites/Playlists/Genres/Folders/Search are
/// reached as stacked pushes from Home sections or Settings, not as
/// additional tabs.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const songs = '/songs';
  static const albums = '/albums';
  static const artists = '/artists';
  static const settings = '/settings';
  static const nowPlaying = '/now-playing';
  static const search = '/search';
  static const favorites = '/favorites';
  static const playlists = '/playlists';
  static const playlistDetail = '/playlists/detail'; // + /:name
  static const genres = '/genres';
  static const folders = '/folders';
  static const albumDetail = '/albums/detail'; // + /:id/:title
  static const artistDetail = '/artists/detail'; // + /:name
  static const about = '/about';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Full-screen player — deliberately outside the ShellRoute so it
      // covers the bottom nav + mini player, per the brief's
      // "Beautiful Full Screen Player" spec.
      GoRoute(
        path: AppRoutes.nowPlaying,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NowPlayingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        ),
      ),

      // Stacked routes reached from Home ("See all") or Settings —
      // not bottom-nav tabs, per the brief's original nav spec.
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.playlists,
        builder: (context, state) => const PlaylistsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.playlistDetail}/:name',
        builder: (context, state) => PlaylistDetailScreen(
          playlistName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.genres,
        builder: (context, state) => const GenresScreen(),
      ),
      GoRoute(
        path: AppRoutes.folders,
        builder: (context, state) => const FoldersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.albumDetail}/:id/:title',
        builder: (context, state) => AlbumDetailScreen(
          albumId: int.parse(state.pathParameters['id']!),
          albumTitle: Uri.decodeComponent(state.pathParameters['title']!),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.artistDetail}/:name',
        builder: (context, state) => ArtistDetailScreen(
          artistName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),

      // ShellRoute keeps the bottom nav bar + mini player persistent
      // across the five main tabs, per the brief's navigation spec.
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.songs,
            builder: (context, state) => const SongsScreen(),
          ),
          GoRoute(
            path: AppRoutes.albums,
            builder: (context, state) => const AlbumsScreen(),
          ),
          GoRoute(
            path: AppRoutes.artists,
            builder: (context, state) => const ArtistsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
