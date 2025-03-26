import 'package:flutter/material.dart';

class HelperLinks extends StatelessWidget {
  final VoidCallback onHelpPressed;

  const HelperLinks({
    super.key,
    required this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: onHelpPressed,
      icon: Icon(
        Icons.help_outline,
        size: 18,
        color: colorScheme.primary,
      ),
      label: Text(
        'How to get a client token?',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }
}
