import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/artwork_thumbnail.dart';
import '../../core/widgets/library_state_views.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../data/services/permission_service.dart';
import '../../providers/library_provider.dart';

/// Artists tab — circular artist images (gradient placeholder, since
/// `on_audio_query` has no per-artist photo, only artwork keyed by
/// song/album). Real artist names via [libraryProvider]; tapping opens
/// [ArtistDetailScreen] (songs/albums/stats).
class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    Widget body;
    switch (library.status) {
      case LibraryStatus.loading:
        body = const SkeletonSongList(itemCount: 8);
        break;
      case LibraryStatus.permissionDenied:
      case LibraryStatus.permissionPermanentlyDenied:
        body = PermissionRequestView(
          permanentlyDenied:
              library.status == LibraryStatus.permissionPermanentlyDenied,
          onRequestPermission: () => ref.read(libraryProvider.notifier).scan(),
          onOpenSettings: () => PermissionService.openSettings(),
        );
        break;
      case LibraryStatus.error:
        body = LibraryErrorView(
          message: library.errorMessage ?? 'Unknown error',
          onRetry: () => ref.read(libraryProvider.notifier).scan(),
        );
        break;
      case LibraryStatus.ready:
        final artists = library.artistNames;
        body = artists.isEmpty
            ? EmptyLibraryView(
                onRescan: () => ref.read(libraryProvider.notifier).scan(),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.78,
                ),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final name = artists[index];
                  return GestureDetector(
                    onTap: () => context.push(
                      '${AppRoutes.artistDetail}/${Uri.encodeComponent(name)}',
                    ),
                    child: Column(
                      children: [
                        const ArtworkThumbnail(size: 84, circular: true),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
        break;
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Artists', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
