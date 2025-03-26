import 'package:flutter/material.dart';

/// A dialog that explains how to get a client token from Gotify server
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Getting a Client Token'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'To get a client token:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Log in to your Gotify server web interface'),
            Text('2. Go to "CLIENTS" section'),
            Text('3. Create a new client or select an existing one'),
            Text('4. Copy the generated token'),
            SizedBox(height: 16),
            Text(
              'Note: Client tokens are used for logging into this app. '
              'They are different from application tokens, which are used for sending messages.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
