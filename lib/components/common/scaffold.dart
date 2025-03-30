import 'package:flutter/material.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.bottomNavBar,
  });

  final Widget body;
  final Widget bottomNavBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.notifications, size: 24),
            SizedBox(width: 12),
            Text(
              'Gotify Messages',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
        elevation: 0,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
