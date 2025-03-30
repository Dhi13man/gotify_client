import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/form_field.dart';
import 'package:gotify_client/utils/form_validator.dart';

class CredentialFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onEditingComplete;

  const CredentialFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: 'Username',
          hintText: 'Enter your username',
          controller: usernameController,
          prefixIcon: Icons.person,
          validator: AppFormValidator.validateNotEmpty,
          textInputAction: TextInputAction.next,
        ),
        ObscurableFormField(
          label: 'Password',
          hintText: 'Enter your password',
          controller: passwordController,
          prefixIcon: Icons.lock,
          validator: AppFormValidator.validateNotEmpty,
          textInputAction: TextInputAction.done,
          onEditingComplete: onEditingComplete,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
