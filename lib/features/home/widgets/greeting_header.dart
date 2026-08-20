import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_text.dart';

/// "Good evening" / "Good morning" greeting shown at the top of Home,
/// time-aware per the brief's "beautiful greeting section".
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              GradientText(
                'Feel Every Beat',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.push(AppRoutes.search),
        ),
      ],
    );
  }
}
