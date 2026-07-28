import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/screens/login_screen.dart';
import 'package:gotify_client/services/auth_service.dart';
import 'package:gotify_client/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets(
    'loginScreen_whenAuthenticationMethodToggled_thenShowsCredentialFields',
    (WidgetTester tester) async {
      // Arrange
      final MockAuthService authService = MockAuthService();
      when(authService.loadAuth).thenAnswer((_) async => AuthState.initial());
      final AuthProvider authProvider = AuthProvider(authService: authService);
      addTearDown(authProvider.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: Builder(
              builder: (BuildContext context) => Theme(
                data: AppTheme.getLightTheme(context),
                child: const Scaffold(body: LoginScreen()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final Finder authenticationToggle = find.text(
        'Use username & password instead',
      );
      await tester.ensureVisible(authenticationToggle);
      await tester.tap(authenticationToggle);
      await tester.pump();

      // Assert
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Client Token'), findsNothing);
      expect(find.text('Login with your credentials'), findsOneWidget);
    },
  );
}
