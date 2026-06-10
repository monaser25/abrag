import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'مرحباً بك في أبراج',
      'description': 'النظام المتكامل لإدارة الأملاك بذكاء وسهولة.',
      'icon': 'domain'
    },
    {
      'title': 'إدارة الحجوزات الصيفية',
      'description': 'نظم الحجوزات اليومية وتابع حالة الشقق بشكل فوري.',
      'icon': 'calendar_month'
    },
    {
      'title': 'متابعة عقود الشتاء',
      'description': 'إدارة عقود الطلاب، وتتبع المدفوعات والكهرباء بكل دقة.',
      'icon': 'school'
    },
    {
      'title': 'التقارير والإحصائيات',
      'description': 'احصل على تقارير مالية مفصلة وقم بتصديرها بسهولة.',
      'icon': 'analytics'
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding_completed', true);
    // onboardingCompletedProvider caches its first read; refresh it so the
    // router redirect sees the new flag instead of bouncing back here.
    ref.invalidate(onboardingCompletedProvider);
    if (mounted) context.go('/login');
  }

  /// Per-page accent tints from the prototype: brand, summer, winter, accent.
  Color _tintFor(int index, AbragColors colors) {
    switch (index) {
      case 1:
        return colors.summer;
      case 2:
        return colors.winter;
      case 3:
        return colors.accent;
      default:
        return colors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLast = _currentPage == _onboardingData.length - 1;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AbragLogo(size: 34, radius: 11),
                  AppButton(
                    label: 'تخطي',
                    variant: AppButtonVariant.ghost,
                    small: true,
                    onPressed: _completeOnboarding,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final tint = _tintFor(index, colors);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IllustrationFrame(
                          tint: tint,
                          icon: _getIcon(_onboardingData[index]['icon']!),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          _onboardingData[index]['title']!,
                          style: AppTextStyles.h1.copyWith(color: colors.ink),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _onboardingData[index]['description']!,
                          style:
                              AppTextStyles.body.copyWith(color: colors.ink2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 30),
              child: Column(
                children: [
                  _Dots(
                    count: _onboardingData.length,
                    index: _currentPage,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        _BackSquare(
                          onTap: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: AppButton(
                          label: isLast ? 'ابدأ الآن' : 'التالي',
                          expand: true,
                          onPressed: () {
                            if (isLast) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'domain': return Icons.domain;
      case 'calendar_month': return Icons.calendar_month;
      case 'school': return Icons.school;
      case 'analytics': return Icons.analytics;
      default: return Icons.info;
    }
  }
}

/// Prototype `.illus` frame: tinted gradient panel with a large glowing icon
/// tile and a skyline silhouette along the bottom edge.
class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({required this.tint, required this.icon});

  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 300,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Color.alphaBlend(tint.withValues(alpha: 0.30), colors.bg2),
            colors.bg2,
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: tint,
                    offset: const Offset(0, 20),
                    blurRadius: 50,
                    spreadRadius: -14,
                  ),
                ],
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Center(child: Icon(icon, size: 54, color: Colors.white)),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: SkylineAccent(height: 56, color: tint, opacity: 0.34),
          ),
        ],
      ),
    );
  }
}

/// Prototype `.dots` page indicator: 7px dots, active stretches to 22px amber.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? colors.accent : colors.border2,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Square outline previous-page button (56px, direction-aware chevron).
class _BackSquare extends StatelessWidget {
  const _BackSquare({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: colors.border2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.ink),
      ),
    );
  }
}
