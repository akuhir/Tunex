import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// The Tunex splash sequence, per brief:
///   1. Logo fades in + scales slightly, with a purple/cyan glow
///   2. A soft continuous floating animation while holding
///   3. The whole scene fades into Home
///
/// Uses the real Tunex logo asset (assets/images/tunex_logo.png) —
/// the image already bakes in the "TUNEX / FEEL THE MUSIC" wordmark,
/// so there's no separate text layer to keep in sync with it.
///
/// No login, no onboarding — this is the only screen shown before Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _floatController;
  late final AnimationController _exitController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _glow;
  late final Animation<double> _floatOffset;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Entrance: logo fade + scale + glow, all driven by one controller
    // so the timings stay relative to each other.
    _logoController = AnimationController(
      vsync: this,
      duration: AppDurations.splashGlow,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _glow = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
    );

    // Continuous gentle float, loops for as long as splash is visible.
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Exit: whole scene fades to reveal Home underneath.
    _exitController = AnimationController(
      vsync: this,
      duration: AppDurations.splashExitFade,
    );
    _exitFade = CurvedAnimation(parent: _exitController, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _logoController.forward();
    await Future.delayed(AppDurations.splashHoldBeforeExit);
    if (!mounted) return;
    await _exitController.forward();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _floatController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
          [_logoController, _floatController, _exitController],
        ),
        builder: (context, _) {
          return Opacity(
            opacity: 1.0 - _exitFade.value,
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.ambientGradient),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, _floatOffset.value),
                  child: Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _GlowingLogo(
                        glowStrength: _glow.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The logo image with a soft animated glow behind it, matching the
/// purple/cyan ambient glow described in the brief. The glow is drawn
/// as a separate blurred gradient circle behind the image rather than
/// baked into the PNG, so [glowStrength] can animate it independently.
class _GlowingLogo extends StatelessWidget {
  final double glowStrength;

  const _GlowingLogo({required this.glowStrength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45 * glowStrength),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.30 * glowStrength),
                  blurRadius: 80,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/tunex_logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
