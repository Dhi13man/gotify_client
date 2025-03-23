import 'package:flutter/material.dart';
import 'package:gotify_client/theme/app_theme.dart';

class PriorityIndicator extends StatelessWidget {
  final int priority;
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getPriorityColor(context, priority);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            priority.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF6B7280)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        ],
      ],
    );
  }
}
