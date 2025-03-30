import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/form_field.dart';
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
    return AppFormField(
      label: 'Server URL',
      hintText: 'https://gotify.example.com',
      controller: controller,
      prefixIcon: Icons.link,
      validator: AuthFormValidator.validateServerUrl,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      suffixWidget: Icon(
        Icons.check_circle,
        color: colorScheme.primary.withValues(alpha: 0.5),
        size: 20,
      ),
    );
  }
}
