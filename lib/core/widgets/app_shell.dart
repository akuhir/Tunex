import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/playback_provider.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import 'mini_player.dart';

/// The persistent scaffold around all five main tabs: bottom
/// navigation bar + (conditionally) the mini player docked above it,
/// per the brief's Navigation + Mini Player spec.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    (route: AppRoutes.home, icon: Icons.home_rounded, label: 'Home'),
    (route: AppRoutes.songs, icon: Icons.music_note_rounded, label: 'Songs'),
    (route: AppRoutes.albums, icon: Icons.album_rounded, label: 'Albums'),
    (route: AppRoutes.artists, icon: Icons.mic_rounded, label: 'Artists'),
    (route: AppRoutes.settings, icon: Icons.settings_rounded, label: 'Settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((t) => t.route == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playback.currentSong != null)
            MiniPlayer(
              song: playback.currentSong!,
              isPlaying: playback.isPlaying,
              isBuffering: playback.isBuffering,
              progress: playback.duration.inMilliseconds > 0
                  ? playback.position.inMilliseconds /
                      playback.duration.inMilliseconds
                  : 0,
              onPlayPause: () =>
                  ref.read(playbackProvider.notifier).togglePlayPause(),
              onExpand: () => context.push(AppRoutes.nowPlaying),
            ),
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => context.go(_tabs[index].route),
            items: _tabs
                .map(
                  (tab) => BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
