import 'package:flutter/material.dart';

class TitleField extends StatelessWidget {
  final TextEditingController controller;
  
  const TitleField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter message title',
        prefixIcon: Icon(
          Icons.title,
          color: colorScheme.primary,
        ),
      ),
      validator: _validateTitle,
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }
}
