import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_timer_provider.dart';
import 'widgets/accent_picker_sheet.dart';
import 'widgets/sleep_timer_sheet.dart';
import 'widgets/sort_picker_sheet.dart';

/// Settings tab — Dark Theme, Accent Color, Sort Songs, Sort Albums,
/// Scan Device Again, Sleep Timer, About, all with real behavior:
/// - Accent Color opens a picker that recolors the whole app live
/// - Sort Songs/Albums persist and apply on the Songs/Albums tabs
/// - Sleep Timer counts down and pauses playback when it ends
/// - Scan Device Again triggers a real library rescan
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final isScanning = library.status == LibraryStatus.loading;
    final accentName = ref.watch(accentProvider);
    final songSort = ref.watch(songSortProvider);
    final albumSort = ref.watch(albumSortProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.lg),
          const _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Theme',
            trailingText: 'Always on',
          ),
          _SettingsTile(
            icon: Icons.palette_rounded,
            label: 'Accent Color',
            trailingText: accentName,
            onTap: () => showAccentPickerSheet(context),
          ),
          _SettingsTile(
            icon: Icons.sort_by_alpha_rounded,
            label: 'Sort Songs',
            trailingText: songSort.label,
            onTap: () => showSortPickerSheet(
              context,
              title: 'Sort Songs',
              options: SongSortOption.values.map((option) {
                return (
                  label: option.label,
                  isSelected: option == songSort,
                  onTap: () =>
                      ref.read(songSortProvider.notifier).setSort(option),
                );
              }).toList(),
            ),
          ),
          _SettingsTile(
            icon: Icons.sort_rounded,
            label: 'Sort Albums',
            trailingText: albumSort.label,
            onTap: () => showSortPickerSheet(
              context,
              title: 'Sort Albums',
              options: AlbumSortOption.values.map((option) {
                return (
                  label: option.label,
                  isSelected: option == albumSort,
                  onTap: () =>
                      ref.read(albumSortProvider.notifier).setSort(option),
                );
              }).toList(),
            ),
          ),
          _SettingsTile(
            icon: Icons.refresh_rounded,
            label: isScanning ? 'Scanning…' : 'Scan Device Again',
            trailingText:
                library.status == LibraryStatus.ready
                    ? '${library.songs.length} songs'
                    : null,
            onTap: isScanning
                ? null
                : () => ref.read(libraryProvider.notifier).scan(),
          ),
          _SettingsTile(
            icon: Icons.bedtime_rounded,
            label: 'Sleep Timer',
            trailingText: sleepTimer.isActive && sleepTimer.remaining != null
                ? '${sleepTimer.remaining!.inMinutes}:${(sleepTimer.remaining!.inSeconds % 60).toString().padLeft(2, '0')}'
                : 'Off',
            onTap: () => showSleepTimerSheet(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About',
            onTap: () => context.push(AppRoutes.about),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '${AppConstants.appName} · v1.0.0',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (trailingText != null) ...[
                  Flexible(
                    child: Text(
                      trailingText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
