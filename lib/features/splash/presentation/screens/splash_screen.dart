import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Add a slight delay for brand visibility
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final onboardingCompleted = ref.read(onboardingCompletedProvider);
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;

    if (!onboardingCompleted) {
      context.go('/onboarding');
    } else if (isLoggedIn) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Flat bg (no gradient field) so the in-app splash is pixel-identical to
    // the native launch splash (#080C24) and the handoff is seamless.
    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: reduceMotion ? 1 : 0.94, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AbragLogo(size: 128, radius: 36, glow: true),
                  const SizedBox(height: 22),
                  Text(
                    'أبراج',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'إدارة الأملاك الذكية',
                    style: AppTextStyles.bodyS.copyWith(
                      color: colors.ink2,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 54,
            start: 0,
            end: 0,
            child: Center(child: SpinningIcon(size: 20, color: colors.brand)),
          ),
          const PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: SkylineAccent(height: 70, opacity: 0.1),
          ),
        ],
      ),
    );
  }
}
