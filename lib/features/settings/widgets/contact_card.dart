import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/developer_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/glass_container.dart';

/// The "Connect With Me" card — four large tappable rows launching
/// email/WhatsApp/X/Telegram. None of the underlying contact strings
/// (email address, phone number, usernames) are ever rendered as
/// visible text — only used internally to build the launch URL. See
/// the security note on [DeveloperInfo] about what "hidden" means here.
///
/// Note on icons: Flutter's bundled Material icon set doesn't include
/// the actual trademarked Gmail/WhatsApp/X/Telegram logos, so each row
/// uses a closely representative icon combined with that platform's
/// recognizable brand color, rather than the literal logo asset.
class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open that link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connect With Me', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _ContactRow(
            icon: Icons.mail_rounded,
            iconColor: const Color(0xFFEA4335), // Gmail red
            title: 'Gmail',
            subtitle: 'Tap to send an email',
            onTap: () => _launch(
              context,
              'mailto:${DeveloperInfo.contactEmail}?subject=Hey%20from%20Tunex',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactRow(
            icon: Icons.chat_bubble_rounded,
            iconColor: const Color(0xFF25D366), // WhatsApp green
            title: 'WhatsApp',
            subtitle: 'Chat with me',
            onTap: () => _launch(context, DeveloperInfo.whatsappUrl),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactRow(
            iconWidget: Text(
              '𝕏',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            iconColor: AppColors.textPrimary,
            title: 'X',
            subtitle: 'Follow me',
            onTap: () => _launch(context, DeveloperInfo.xUrl),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactRow(
            icon: Icons.send_rounded,
            iconColor: const Color(0xFF29B6F6), // Telegram blue
            title: 'Telegram',
            subtitle: 'Message me',
            onTap: () => _launch(context, DeveloperInfo.telegramUrl),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactRow({
    this.icon,
    this.iconWidget,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: iconWidget ?? Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
