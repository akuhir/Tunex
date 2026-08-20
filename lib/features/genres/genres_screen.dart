import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/repositories/permission_service.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

class GenresScreen extends ConsumerWidget {
  const GenresScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    if (library.status == LibraryStatus.loading) return const SafeArea(child: SkeletonSongList(itemCount: 8));
    if (library.status == LibraryStatus.permissionDenied || library.status == LibraryStatus.permissionPermanentlyDenied) {
      return SafeArea(child: PermissionRequestView(permanentlyDenied: library.status == LibraryStatus.permissionPermanentlyDenied,
        onRequestPermission: () => ref.read(libraryProvider.notifier).scan(), onOpenSettings: PermissionService.openSettings));
    }
    final genres = <String, List<dynamic>>{};
    for (final song in library.songs) { genres.putIfAbsent('All Music', () => []).add(song); }
    final songs = library.songs;
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal, AppSpacing.md, AppSpacing.pageHorizontal, AppSpacing.sm), child: Align(alignment: Alignment.centerLeft, child: Text('Genres', style: Theme.of(context).textTheme.headlineLarge))),
      Expanded(child: songs.isEmpty ? EmptyLibraryView(onRescan: () => ref.read(libraryProvider.notifier).scan()) : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal), itemCount: genres.length,
        itemBuilder: (_, i) => ListTile(contentPadding: EdgeInsets.zero,
          leading: Container(width:48,height:48,decoration:BoxDecoration(gradient:AppColors.brandGradient,borderRadius:BorderRadius.circular(AppRadius.sm)),child:const Icon(Icons.category_rounded,color:Colors.white)),
          title: const Text('All Music'), subtitle: Text('${songs.length} songs'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _GenreSongsScreen(songs: songs))),
        ),
      )),
    ]));
  }
}

class _GenreSongsScreen extends ConsumerWidget {
  final List songs; const _GenreSongsScreen({required this.songs});
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(backgroundColor:AppColors.background, appBar:AppBar(title:const Text('All Music')),
    body:ListView.builder(padding:const EdgeInsets.symmetric(horizontal:AppSpacing.pageHorizontal), itemCount:songs.length,
      itemBuilder:(_,i)=>SongTile(song:songs[i], onTap:()=>ref.read(playbackProvider.notifier).playQueue(songs.cast(),startIndex:i))));
}
