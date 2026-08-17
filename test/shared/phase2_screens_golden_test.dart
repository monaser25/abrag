import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:abrag/core/config/secure_storage_provider.dart';
import 'package:abrag/core/config/shared_prefs_provider.dart';
import 'package:abrag/core/theme/app_theme.dart';
import 'package:abrag/features/auth/data/auth_repository.dart';
import 'package:abrag/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:abrag/features/auth/presentation/screens/login_screen.dart';
import 'package:abrag/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:abrag/l10n/app_localizations.dart';

import '../support/test_fonts.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// Phase 2 screen goldens (Arabic / RTL, dark theme) — visual reference for
/// the navigation-shell redesign. Regenerate after intentional UI changes:
/// flutter test --update-goldens test/shared/phase2_screens_golden_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadAppFonts);

  Widget appShell({required Widget home, List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );
  }

  Future<void> pumpPhone(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('golden: login screen', (tester) async {
    final repo = _MockAuthRepository();
    when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
    final storage = _MockSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await pumpPhone(
      tester,
      appShell(
        home: const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          secureStorageProvider.overrideWithValue(storage),
        ],
      ),
    );
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/phase2_login_dark_ar.png'),
    );
  });

  testWidgets('golden: onboarding screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpPhone(
      tester,
      appShell(
        home: const OnboardingScreen(),
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      ),
    );
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/phase2_onboarding_dark_ar.png'),
    );
  });

  testWidgets('golden: forgot password screen', (tester) async {
    await pumpPhone(tester, appShell(home: const ForgotPasswordScreen()));
    await expectLater(
      find.byType(ForgotPasswordScreen),
      matchesGoldenFile('goldens/phase2_forgot_password_dark_ar.png'),
    );
  });
}
