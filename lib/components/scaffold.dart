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
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF9FAFB) // Gray-50
          : const Color(0xFF1F2937), // Gray-800
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1F2937), // Gray-800
        elevation: 0,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFE5E7EB) // Gray-200
                  : const Color(0xFF374151), // Gray-700
              width: 1,
            ),
          ),
        ),
        child: bottomNavBar,
      ),
    );
  }
}
