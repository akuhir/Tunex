import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/repositories/music_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum ArtworkType { AUDIO, ALBUM }

class ArtworkThumbnail extends StatelessWidget {
  final double size;
  final double borderRadius;
  final int? id;
  final ArtworkType type;
  final bool circular;
  const ArtworkThumbnail({super.key, this.size=56, this.borderRadius=AppRadius.sm, this.id, this.type=ArtworkType.AUDIO, this.circular=false});

  Widget _placeholder(double radius) => Container(width: size.isFinite ? size : null, height: size.isFinite ? size : null,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), gradient: AppColors.brandGradient),
    child: Center(child: Icon(Icons.music_note_rounded, color: Colors.white.withOpacity(.85), size: size.isFinite ? size*.42 : 32)));

  @override Widget build(BuildContext context) {
    final radius = circular ? size/2 : borderRadius;
    if (id == null) return _placeholder(radius);
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: FutureBuilder<Uint8List?>(
      future: MusicRepository().artwork(id!, album: type == ArtworkType.ALBUM),
      builder: (context, snap) {
        if (snap.hasData && snap.data!.isNotEmpty) return Image.memory(snap.data!, fit: BoxFit.cover, width: size.isFinite ? size : 200, height: size.isFinite ? size : 200, errorBuilder: (_,__,___)=>_placeholder(radius));
        return _placeholder(radius);
      },
    ));
  }
}
