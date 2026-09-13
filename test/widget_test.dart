// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abrag/features/auth/presentation/screens/login_screen.dart';
import 'package:abrag/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:abrag/features/auth/data/auth_repository.dart';
import 'package:abrag/shared/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    final mockAuthRepository = MockAuthRepository();

    // Just need a basic stream to prevent StreamProvider from crashing
    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('ar')],
          locale: Locale('ar'),
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of email and password fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    // Verify presence of the login button (AppButton since the UI redesign)
    expect(find.byType(AppButton), findsOneWidget);
  });
}
