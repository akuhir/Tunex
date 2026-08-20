import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Wraps `permission_handler` for the one permission Tunex actually
/// needs: read access to on-device audio.
///
/// Android's media permission model changed in API 33 (Android 13):
/// - API < 33: `Permission.storage`
/// - API >= 33: `Permission.audio` (scoped media permission)
///
/// Important: [MusicRepository.scanSongs] does NOT gate on
/// [hasAudioPermission] before attempting the real scan anymore — a
/// confirmed real-device case (Android 11, TECNO OEM build) showed
/// Android's Settings screen reporting the permission as Allowed while
/// this class's status check kept reporting not-granted regardless.
/// This service is now only used as the fallback permission-request UI
/// flow, triggered when the actual MediaStore query fails outright —
/// not as a gate that runs before every attempt.
class PermissionService {
  PermissionService._();

  static int? _cachedSdkInt;

  static Future<int> _sdkInt() async {
    if (_cachedSdkInt != null) return _cachedSdkInt!;
    final info = await DeviceInfoPlugin().androidInfo;
    _cachedSdkInt = info.version.sdkInt;
    if (kDebugMode) {
      debugPrint('[Tunex] Android SDK int: $_cachedSdkInt');
    }
    return _cachedSdkInt!;
  }

  /// The permission that's actually real on this device's OS version.
  static Future<Permission> _relevantPermission() async {
    final sdkInt = await _sdkInt();
    return sdkInt >= 33 ? Permission.audio : Permission.storage;
  }

  static Future<bool> hasAudioPermission() async {
    final permission = await _relevantPermission();
    final status = await permission.status;
    if (kDebugMode) {
      debugPrint('[Tunex] hasAudioPermission — using $permission, status: $status');
    }
    return status.isGranted;
  }

  /// Requests audio permission and returns whether it was granted.
  static Future<bool> requestAudioPermission() async {
    final permission = await _relevantPermission();
    if (kDebugMode) {
      debugPrint('[Tunex] requesting $permission...');
    }
    final result = await permission.request();
    if (kDebugMode) {
      debugPrint('[Tunex] $permission.request() -> $result');
    }
    return result.isGranted;
  }

  /// True if the user has permanently denied permission ("Don't ask
  /// again") — in that case we should route them to app settings
  /// instead of requesting again.
  static Future<bool> isPermanentlyDenied() async {
    final permission = await _relevantPermission();
    final status = await permission.status;
    if (kDebugMode) {
      debugPrint('[Tunex] isPermanentlyDenied — $permission status: $status');
    }
    return status.isPermanentlyDenied;
  }

  static Future<void> openSettings() => openAppSettings();
}
