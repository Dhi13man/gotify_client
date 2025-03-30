import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/labeled_form_field.dart';
import 'package:gotify_client/utils/auth_form_validator.dart';

class TokenField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onEditingComplete;

  const TokenField({
    super.key,
    required this.controller,
    required this.onEditingComplete,
  });

  @override
  State<TokenField> createState() => _TokenFieldState();
}

class _TokenFieldState extends State<TokenField> {
  bool _obscureToken = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return LabeledFormField(
      label: 'Client Token',
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Enter your client token',
          prefixIcon: Icon(Icons.vpn_key, color: colorScheme.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureToken ? Icons.visibility : Icons.visibility_off,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureToken = !_obscureToken),
          ),
        ),
        validator: AuthFormValidator.validateToken,
        obscureText: _obscureToken,
        textInputAction: TextInputAction.done,
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }
}
