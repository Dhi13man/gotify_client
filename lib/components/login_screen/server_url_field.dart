import 'package:flutter/material.dart';
import 'package:gotify_client/utils/auth_form_validator.dart';
import 'package:gotify_client/theme/app_theme.dart';

class ServerUrlField extends StatelessWidget {
  final TextEditingController controller;

  const ServerUrlField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color textColor = AppTheme.getTextPrimaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server URL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
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
      ],
    );
  }
}
