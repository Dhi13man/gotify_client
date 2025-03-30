import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/form_field.dart';
import 'package:gotify_client/utils/auth_form_validator.dart';

class TokenField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEditingComplete;

  const TokenField({
    super.key,
    required this.controller,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ObscurableFormField(
      label: 'Client Token',
      hintText: 'Enter your client token',
      controller: controller,
      prefixIcon: Icons.vpn_key,
      validator: AuthFormValidator.validateToken,
      textInputAction: TextInputAction.done,
      onEditingComplete: onEditingComplete,
    );
  }
}
