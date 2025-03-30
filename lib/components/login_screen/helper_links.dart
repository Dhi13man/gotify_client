import 'package:flutter/material.dart';

class HelperLinks extends StatelessWidget {
  final VoidCallback onHelpPressed;

  const HelperLinks({
    super.key,
    required this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onHelpPressed,
      icon: const Icon(Icons.help_outline, size: 18),
      label: Text(
        'How to get a client token?',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
