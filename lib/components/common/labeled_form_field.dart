import 'package:flutter/material.dart';

/// A reusable labeled form field that combines a label and input field
/// to maintain consistent styling across the application.
class LabeledFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LabeledFormField({
    super.key,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
