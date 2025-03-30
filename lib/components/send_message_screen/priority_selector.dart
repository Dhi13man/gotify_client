import 'package:flutter/material.dart';
import 'package:gotify_client/components/send_message_screen/priority_chip.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/theme/app_theme.dart';

class PrioritySelector extends StatelessWidget {
  final int priority;
  final ValueChanged<int> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.priority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = AppTheme.getPriorityColor(context, priority);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      PriorityType.fromNumeric(priority).toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: priorityColor,
                  inactiveTrackColor: priorityColor.withValues(alpha: 0.2),
                  thumbColor: priorityColor,
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: priority.toDouble(),
                  min: PriorityType.min.numericValue.toDouble(),
                  max: PriorityType.max.numericValue.toDouble(),
                  divisions: PriorityType.max.numericValue -
                      PriorityType.min.numericValue,
                  label: priority.toString(),
                  onChanged: (double value) => onPriorityChanged(value.toInt()),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PriorityChip(
                    priority: PriorityType.low,
                    isSelected: priority == PriorityType.low.numericValue,
                    onTap: () =>
                        onPriorityChanged(PriorityType.low.numericValue),
                  ),
                  PriorityChip(
                    priority: PriorityType.medium,
                    isSelected: priority == PriorityType.medium.numericValue,
                    onTap: () =>
                        onPriorityChanged(PriorityType.medium.numericValue),
                  ),
                  PriorityChip(
                    priority: PriorityType.high,
                    isSelected: priority == PriorityType.high.numericValue,
                    onTap: () =>
                        onPriorityChanged(PriorityType.high.numericValue),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
