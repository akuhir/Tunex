import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'app_logo_image.dart';

/// Full-page prompt shown when Tunex doesn't yet have permission to
/// read on-device audio. Two variants:
///   - normal: "Allow Access" re-triggers the OS permission dialog
///   - permanently denied: user has to be routed to app settings,
///     since Android won't show the dialog again otherwise
class PermissionRequestView extends StatelessWidget {
  final bool permanentlyDenied;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  const PermissionRequestView({
    super.key,
    required this.permanentlyDenied,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogoImage(size: 72),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Access your music',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tunex needs permission to read audio files stored on '
              'your device. Nothing ever leaves your phone.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: permanentlyDenied ? onOpenSettings : onRequestPermission,
                child: Text(permanentlyDenied ? 'Open Settings' : 'Allow Access'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a scan completed successfully but found zero supported
/// audio files on the device.
class EmptyLibraryView extends StatelessWidget {
  final VoidCallback onRescan;

  const EmptyLibraryView({super.key, required this.onRescan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.library_music_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No music found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add some MP3, FLAC, or M4A files to your device, '
              'then rescan.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRescan,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the scan itself threw (rare — corrupt MediaStore entry,
/// platform channel error, etc).
class LibraryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LibraryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong scanning your library',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
