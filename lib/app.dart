import 'package:flutter/material.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/screens/login_screen.dart';
import 'package:gotify_client/screens/message_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class GotifyClientApp extends StatelessWidget {
  const GotifyClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'Gotify Client',
        theme: ThemeData(
          useMaterial3: true,
          // Use Inter font from Google Fonts
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
          // Custom color scheme matching the design language
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF3B82F6), // --color-primary-500
            onPrimary: Colors.white, // --color-primary-content
            primaryContainer: const Color(0xFFDBEAFE), // --color-primary-100
            secondary: const Color(0xFF8B5CF6), // --color-secondary-500
            onSecondary: Colors.white, // --color-secondary-content
            secondaryContainer:
                const Color(0xFFEDE9FE), // --color-secondary-100
            surface: const Color(0xFFF9FAFB), // --color-base-50
            error: const Color(0xFFEF4444), // --color-error-500
            onError: Colors.white,
          ),
          // Card theme with subtle shadows
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // AppBar styling
          appBarTheme: const AppBarTheme(
            color: Color(0xFF3B82F6), // --color-primary-500
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          // Elevated button styling
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6), // --color-primary-500
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Input decoration
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB)), // --color-base-300
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: Color(0xFF3B82F6), width: 2), // --color-primary-500
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          // Use Inter font from Google Fonts
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
          // Dark theme color scheme
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF60A5FA), // --color-primary-500 (dark mode)
            onPrimary:
                const Color(0xFF1F2937), // --color-primary-content (dark mode)
            primaryContainer:
                const Color(0xFF1E40AF), // --color-primary-200 (dark mode)
            secondary:
                const Color(0xFFA78BFA), // --color-secondary-500 (dark mode)
            onSecondary: const Color(
                0xFF1F2937), // --color-secondary-content (dark mode)
            surface: const Color(0xFF1F2937), // --color-base (dark mode)
            error: const Color(0xFFF87171), // --color-error-500 (dark mode)
            onError:
                const Color(0xFF1F2937), // --color-error-content (dark mode)
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1F2937), // --color-base (dark mode)
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            color: Color(0xFF3B82F6), // --color-primary-500
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        themeMode: ThemeMode.system, // Use system theme by default
        home: const HomeWrapper(),
      ),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  HomeWrapperState createState() => HomeWrapperState();
}

class HomeWrapperState extends State<HomeWrapper> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Initialize the message provider with auth data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false)
          .initialize(authProvider.authState);
    });

    return const MessageListScreen();
  }
}
