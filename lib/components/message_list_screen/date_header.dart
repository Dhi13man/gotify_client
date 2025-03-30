import 'package:flutter/material.dart';
import 'package:gotify_client/theme/app_theme.dart';

class DateHeader extends StatelessWidget {
  final String title;

  const DateHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
    );
  }
}
