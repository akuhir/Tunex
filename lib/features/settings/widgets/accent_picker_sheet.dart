import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../providers/settings_provider.dart';

Future<void> showAccentPickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => const AccentPickerSheet(),
  );
}

class AccentPickerSheet extends ConsumerWidget {
  const AccentPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAccent = ref.watch(accentProvider);

    return SafeArea(
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
            child: Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
          ),
          ...AppColors.accentPresets.entries.map((entry) {
            final name = entry.key;
            final preset = entry.value;
            final isSelected = name == currentAccent;

            return ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [preset.primary, preset.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded, color: preset.primary)
                  : null,
              onTap: () => ref.read(accentProvider.notifier).setAccent(name),
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
