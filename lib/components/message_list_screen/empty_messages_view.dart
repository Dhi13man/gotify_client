import 'package:flutter/material.dart';
import 'package:gotify_client/theme/app_theme.dart';

class EmptyMessagesView extends StatelessWidget {
  const EmptyMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.getTextTertiaryColor(context),
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here, unless they have been filtered out.',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
