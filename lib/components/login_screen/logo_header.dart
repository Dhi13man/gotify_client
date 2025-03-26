import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final bool showAdvancedLogin;

  const LogoHeader({
    super.key,
    required this.showAdvancedLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_active,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Gotify',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          showAdvancedLogin
              ? 'Login with your credentials'
              : 'Enter your client token to continue',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
