import 'package:flutter/material.dart';
import 'package:gotify_client/utils/auth_form_validator.dart';

class CredentialFields extends StatefulWidget {
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
  State<CredentialFields> createState() => _CredentialFieldsState();
}

class _CredentialFieldsState extends State<CredentialFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.usernameController,
          decoration: InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: Icon(Icons.person, color: colorScheme.primary),
          ),
          validator: AuthFormValidator.validateUsername,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.passwordController,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: AuthFormValidator.validatePassword,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: widget.onEditingComplete,
        ),
      ],
    );
  }
}
