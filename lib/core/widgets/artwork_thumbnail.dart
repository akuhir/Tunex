import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Album/track artwork tile.
///
/// Pass [id] (a MediaStore id) together with [type] to load real
/// artwork via `on_audio_query`'s [QueryArtworkWidget] — use
/// [ArtworkType.AUDIO] with a song id, or [ArtworkType.ALBUM] with an
/// album id. Without an [id] — or when there's no embedded art — this
/// falls back to the branded gradient placeholder with a music-note
/// glyph, so every call site works whether or not real data is
/// available yet.
class ArtworkThumbnail extends StatelessWidget {
  final double size;
  final double borderRadius;
  final int? id;
  final ArtworkType type;
  final bool circular;

  const ArtworkThumbnail({
    super.key,
    this.size = 56,
    this.borderRadius = AppRadius.sm,
    this.id,
    this.type = ArtworkType.AUDIO,
    this.circular = false,
  });

  Widget _placeholder(double radius) {
    final isBounded = size.isFinite;
    return Container(
      width: isBounded ? size : null,
      height: isBounded ? size : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: AppColors.brandGradient,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white.withOpacity(0.85),
          size: isBounded ? size * 0.42 : 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = circular ? size / 2 : borderRadius;

    if (id == null) {
      return _placeholder(radius);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: id!,
        type: type,
        artworkFit: BoxFit.cover,
        artworkWidth: size.isFinite ? size : 200,
        artworkHeight: size.isFinite ? size : 200,
        artworkBorder: BorderRadius.circular(radius),
        keepOldArtwork: true,
        nullArtworkWidget: _placeholder(radius),
        errorBuilder: (context, error, stackTrace) => _placeholder(radius),
      ),
    );
  }
}

