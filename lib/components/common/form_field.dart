import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/labeled_form_field.dart';

/// A reusable form field component for standard input fields
/// with support for various input decorations and validation.
class AppFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final EdgeInsetsGeometry padding;
  final Widget? suffixWidget;

  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.padding = const EdgeInsets.only(bottom: 20),
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledFormField(
      label: label,
      padding: padding,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixWidget,
        ),
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
      ),
    );
  }
}

/// A specialized form field for password/token input with toggleable visibility.
class ObscurableFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final EdgeInsetsGeometry padding;

  const ObscurableFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.hintText,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onEditingComplete,
    this.padding = const EdgeInsets.only(bottom: 20),
  });

  @override
  State<ObscurableFormField> createState() => _ObscurableFormFieldState();
}

class _ObscurableFormFieldState extends State<ObscurableFormField> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return LabeledFormField(
      label: widget.label,
      padding: widget.padding,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(widget.prefixIcon),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        validator: widget.validator,
        obscureText: _obscureText,
        textInputAction: widget.textInputAction,
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }
}
