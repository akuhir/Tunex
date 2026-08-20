import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/models/song.dart';
import '../../data/services/lyrics_service.dart';

class LyricsScreen extends StatelessWidget {
  final Song song;
  const LyricsScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lyrics')),
      body: FutureBuilder<String?>(
        future: LyricsService.load(song.filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final lyrics = snapshot.data?.trim();
          if (lyrics == null || lyrics.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No lyrics found for this track.\n\nAdd a matching .lrc file beside the audio file.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: SelectableText(
              lyrics,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          );
        },
      ),
    );
  }
}
