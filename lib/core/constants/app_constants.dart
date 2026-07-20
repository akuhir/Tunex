/// Static brand + config constants used across the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Tunex';
  static const String tagline = 'Feel Every Beat.';

  /// File extensions Tunex scans for on-device, per the brief.
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'wav',
    'flac',
    'aac',
    'ogg',
    'm4a',
  ];

  static const int miniPlayerHeight = 64;
  static const int bottomNavHeight = 64;
}
