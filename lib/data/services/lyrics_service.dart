import 'dart:io';

/// Finds and parses `.lrc` lyric files for a song, per the brief's
/// "Lyrics (LRC if available)".
///
/// Per product direction, Tunex shows lyrics as plain text — it does
/// **not** highlight/scroll the current line in sync with playback.
/// That means we only need the lyric text itself, not the per-line
/// timestamps LRC encodes; [LyricsService.load] strips timestamp tags
/// (`[00:12.34]`) and metadata tags (`[ar:...]`, `[ti:...]`, etc.) and
/// returns clean, readable lines.
class LyricsService {
  LyricsService._();

  static final RegExp _timestampTag = RegExp(r'\[\d{2}:\d{2}(\.\d{1,3})?\]');
  static final RegExp _metadataTag = RegExp(r'^\[[a-zA-Z]+:.*\]$');

  /// Looks for a `.lrc` file next to the audio file with the same base
  /// name — e.g. `Midnight Drive.mp3` → `Midnight Drive.lrc` — which is
  /// the near-universal convention lyric-tagging tools and manually
  /// -placed LRC files follow. Returns null if no such file exists or
  /// it can't be read.
  static Future<String?> load(String audioFilePath) async {
    final lrcPath = _lrcPathFor(audioFilePath);
    final file = File(lrcPath);

    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      return _stripLrcTags(raw);
    } catch (_) {
      // Unreadable/corrupt file — treat the same as "no lyrics found"
      // rather than surfacing a file-system error to the user.
      return null;
    }
  }

  static String _lrcPathFor(String audioFilePath) {
    final dotIndex = audioFilePath.lastIndexOf('.');
    final withoutExtension =
        dotIndex == -1 ? audioFilePath : audioFilePath.substring(0, dotIndex);
    return '$withoutExtension.lrc';
  }

  static String _stripLrcTags(String raw) {
    final lines = raw.split('\n');
    final cleaned = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (_metadataTag.hasMatch(trimmed)) continue; // [ar:Artist], [ti:Title], etc.

      final withoutTimestamps = trimmed.replaceAll(_timestampTag, '').trim();
      if (withoutTimestamps.isNotEmpty) {
        cleaned.add(withoutTimestamps);
      }
    }

    return cleaned.join('\n');
  }
}
