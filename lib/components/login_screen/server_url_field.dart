import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/labeled_form_field.dart';
import 'package:gotify_client/utils/auth_form_validator.dart';

class ServerUrlField extends StatelessWidget {
  final TextEditingController controller;

  const ServerUrlField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return LabeledFormField(
      label: 'Server URL',
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'https://gotify.example.com',
          prefixIcon: Icon(Icons.link, color: colorScheme.primary),
          suffixIcon: Icon(
            Icons.check_circle,
            color: colorScheme.primary.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        validator: AuthFormValidator.validateServerUrl,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
