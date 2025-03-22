import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/message_provider.dart';
import 'screens/login_screen.dart';
import 'screens/message_list_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logger
  Logger.root.level = Level.ALL; // Set to show all log levels
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}'
      '${record.stackTrace != null ? '\n${record.stackTrace}' : ''}',
    );
  });

  await _initNotifications();
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const HomeWrapper({Key? key}) : super(key: key);

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

    if (authProvider.isAuthenticated) {
      // Initialize the message provider with auth data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MessageProvider>(context, listen: false)
            .initialize(authProvider.authState);
      });

      return const MessageListScreen();
    }

    return const LoginScreen();
  }
}
