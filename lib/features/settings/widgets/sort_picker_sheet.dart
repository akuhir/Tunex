import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// Generic single-select list sheet — used for both "Sort Songs" and
/// "Sort Albums" in Settings. Takes plain (label, isSelected, onTap)
/// tuples rather than being generic over an enum type, so it doesn't
/// need to know about [SongSortOption] vs [AlbumSortOption].
Future<void> showSortPickerSheet(
  BuildContext context, {
  required String title,
  required List<({String label, bool isSelected, VoidCallback onTap})> options,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ...options.map((option) {
            return ListTile(
              title: Text(option.label, style: Theme.of(context).textTheme.bodyLarge),
              trailing: option.isSelected
                  ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                option.onTap();
                Navigator.of(context).pop();
              },
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}
