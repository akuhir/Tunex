import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_logo_image.dart';
import 'widgets/about_tunex_card.dart';
import 'widgets/contact_card.dart';
import 'widgets/developer_profile_card.dart';
import 'widgets/footer_section.dart';

/// About Tunex — the developer profile, the app's story, contact
/// links, and a footer. Assembled from reusable, independently
/// -editable cards ([DeveloperProfileCard], [AboutTunexCard],
/// [ContactCard], [FooterSection]) rather than one large build method,
/// so each section can be tweaked or reordered without touching the
/// others.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.ambientGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  'About Tunex',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: AppLogoImage(size: 32),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const DeveloperProfileCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const AboutTunexCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const ContactCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const FooterSection(version: '1.0.0'),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
