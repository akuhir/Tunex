import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/song_actions_sheet.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

/// Instant search across songs, artists, and albums (genres/folders
/// join once their own tabs exist — see Roadmap). Filters the already
/// -loaded [libraryProvider] data client-side; the library is small
/// enough (a personal music collection, not a streaming catalogue)
/// that there's no need for indexing or debounced remote queries.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final query = _query.trim().toLowerCase();

    final matchingSongs = query.isEmpty
        ? <Song>[]
        : library.songs.where((s) {
            return s.title.toLowerCase().contains(query) ||
                s.artist.toLowerCase().contains(query) ||
                s.album.toLowerCase().contains(query);
          }).toList();

    final matchingArtists = query.isEmpty
        ? <String>[]
        : library.artistNames
            .where((a) => a.toLowerCase().contains(query))
            .toList();

    final matchingAlbums = query.isEmpty
        ? <String>[]
        : library.albums
            .map((a) => a.title)
            .where((title) => title.toLowerCase().contains(query))
            .toList();

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
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists, albums…',
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _EmptySearchHint()
                : (matchingSongs.isEmpty &&
                        matchingArtists.isEmpty &&
                        matchingAlbums.isEmpty)
                    ? const _NoResultsHint()
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        children: [
                          if (matchingArtists.isNotEmpty) ...[
                            _ResultSectionLabel('Artists'),
                            ...matchingArtists.map(
                              (name) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.card,
                                  child: Icon(Icons.person_rounded,
                                      color: AppColors.textSecondary),
                                ),
                                title: Text(name),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (matchingAlbums.isNotEmpty) ...[
                            _ResultSectionLabel('Albums'),
                            ...matchingAlbums.map(
                              (title) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.album_rounded,
                                    color: AppColors.textSecondary),
                                title: Text(title),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (matchingSongs.isNotEmpty) ...[
                            _ResultSectionLabel('Songs'),
                            ...matchingSongs.map(
                              (song) => SongTile(
                                song: song,
                                onTap: () => ref
                                    .read(playbackProvider.notifier)
                                    .playQueue(
                                      matchingSongs,
                                      startIndex: matchingSongs.indexOf(song),
                                    ),
                                onMoreTap: () =>
                                    showSongActionsSheet(context, song: song),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _ResultSectionLabel extends StatelessWidget {
  final String label;
  const _ResultSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _EmptySearchHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search your library',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsHint extends StatelessWidget {
  const _NoResultsHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results found',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
