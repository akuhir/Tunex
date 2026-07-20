import 'package:permission_handler/permission_handler.dart';

/// Centralizes the runtime permission needed to read the device's audio
/// library via MediaStore (`on_audio_query`).
///
/// On Android 13+ (API 33+) this maps to `READ_MEDIA_AUDIO`; on older
/// versions `permission_handler` falls back to `READ_EXTERNAL_STORAGE`.
/// Callers should not need to know which one applies — that's handled
/// by `Permission.audio` itself.
class PermissionService {
  /// Whether we currently have permission to read audio files.
  static Future<bool> hasAudioPermission() async {
    final status = await Permission.audio.status;
    return status.isGranted;
  }

  /// Requests audio permission from the user. Returns true if granted.
  static Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status.isGranted;
  }

  /// Whether the user has permanently denied the permission (e.g. by
  /// checking "don't ask again"), meaning we should direct them to
  /// app settings instead of requesting again.
  static Future<bool> isPermanentlyDenied() async {
    final status = await Permission.audio.status;
    return status.isPermanentlyDenied;
  }

  /// Opens the app's system settings page, for use after a permanent
  /// denial so the user can grant the permission manually.
  static Future<bool> openSettings() {
    return openAppSettings();
  }
}
