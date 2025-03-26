import 'package:flutter/material.dart';

class VersionInfo extends StatelessWidget {
  final String version;

  const VersionInfo({
    super.key,
    this.version = 'v1.0.0',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Gotify Client $version',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}
