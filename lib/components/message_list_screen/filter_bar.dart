import 'package:flutter/material.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  final PriorityType selectedFilter;
  final ValueChanged<PriorityType> onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: PriorityType.values.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: filter.toString(),
                isSelected: selectedFilter == filter,
                onTap: () => onFilterChanged(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color borderColor = AppTheme.getBorderColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : AppTheme.getTextSecondaryColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Helper function to filter messages based on selected filter
List<Message> filterMessages(List<Message> messages, PriorityType filter) {
  return messages
      .where((message) => message.priority >= filter.numericValue)
      .toList();
}
