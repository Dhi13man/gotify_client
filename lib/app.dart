import 'package:flutter/material.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/screens/login_screen.dart';
import 'package:gotify_client/screens/message_list_screen.dart';
import 'package:provider/provider.dart';

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
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            color: Colors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
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
