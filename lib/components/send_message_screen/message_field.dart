import 'package:flutter/material.dart';

class MessageField extends StatelessWidget {
  final TextEditingController controller;

  const MessageField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Message',
        hintText: 'Enter your message content',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Icon(Icons.message),
        ),
      ),
      maxLines: 5,
      validator: _validateMessage,
    );
  }

  String? _validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a message';
    }
    return null;
  }
}
