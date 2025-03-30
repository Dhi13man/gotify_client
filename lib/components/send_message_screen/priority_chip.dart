import 'package:flutter/material.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/theme/app_theme.dart';

class PriorityChip extends StatelessWidget {
  final PriorityType priority;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityChip({
    super.key,
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color priorityColor =
        AppTheme.getPriorityColor(context, priority.numericValue);
    final Color borderColor = AppTheme.getBorderColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? priorityColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? priorityColor : borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          priority.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? priorityColor
                : AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ),
    );
  }
}
