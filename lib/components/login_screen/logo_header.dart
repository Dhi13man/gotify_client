import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final bool showAdvancedLogin;

  const LogoHeader({
    super.key,
    required this.showAdvancedLogin,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const Icon(Icons.notifications_active, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Gotify',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          showAdvancedLogin
              ? 'Login with your credentials'
              : 'Enter your client token to continue',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
