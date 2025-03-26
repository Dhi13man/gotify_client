import 'package:flutter/material.dart';

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
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFF6B7280) // Gray-500
              : const Color(0xFF9CA3AF), // Gray-400
        ),
      ),
    );
  }
}
