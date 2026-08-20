import '../services/permission_service.dart' as platform_permissions;

/// Backward-compatible facade using the same platform-aware permission logic.
class PermissionService {
  static Future<bool> hasAudioPermission() => platform_permissions.PermissionService.hasAudioPermission();
  static Future<bool> requestAudioPermission() => platform_permissions.PermissionService.requestAudioPermission();
  static Future<bool> isPermanentlyDenied() => platform_permissions.PermissionService.isPermanentlyDenied();
  static Future<void> openSettings() => platform_permissions.PermissionService.openSettings();
}
