import 'package:flutter/material.dart';
import 'package:gotify_client/app.dart';
import 'package:gotify_client/services/notification_service.dart';
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

  // Initialize notifications
  final notificationService = NotificationService();
  notificationService.initialize();
  runApp(const GotifyClientApp());
}
