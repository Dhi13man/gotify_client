import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/bottom_nav_bar.dart';
import 'package:gotify_client/components/common/scaffold.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/screens/login_screen.dart';
import 'package:gotify_client/screens/message_list_screen.dart';
import 'package:gotify_client/screens/send_message_screen.dart';
import 'package:gotify_client/theme/app_theme.dart';
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
        theme: AppTheme.getLightTheme(context),
        darkTheme: AppTheme.getDarkTheme(context),
        themeMode: ThemeMode.system,
        home: HomeWrapper(),
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
  static const List<Widget> screens = [
    MessageListScreen(),
    SendMessageScreen(),
    MessageListScreen(),
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: LoginScreen());
    }

    // Initialize the message provider with auth data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false)
          .initialize(authProvider.authState);
    });

    return AppScaffold(
      body: screens[_currentIndex],
      bottomNavBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
  }
}
