import 'package:flutter/material.dart';

class ApplicationTokenField extends StatelessWidget {
  final TextEditingController controller;

  const ApplicationTokenField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Application Token',
        hintText: 'Enter the application token',
        prefixIcon: Icon(
          Icons.vpn_key,
          color: colorScheme.primary,
        ),
      ),
      validator: _validateApplicationToken,
    );
  }

  String? _validateApplicationToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an application token';
    }
    return null;
  }
}
