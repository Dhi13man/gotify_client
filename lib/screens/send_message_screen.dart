// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/form_field.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/utils/form_validator.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/components/send_message_screen/priority_selector.dart';
import 'package:gotify_client/components/send_message_screen/submit_button.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  SendMessageScreenState createState() => SendMessageScreenState();
}

class SendMessageScreenState extends State<SendMessageScreen> {
  static const int defaultPriority = PriorityType.mediumValue;
  static const String defaultApplicationToken = '';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _applicationTokenController = TextEditingController();
  int _priority = defaultPriority;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _applicationTokenController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final success = await _submitMessage();
      if (!mounted) return;

      if (success) {
        _showSuccessMessage();
      } else {
        _showErrorMessage();
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<bool> _submitMessage() async {
    return Provider.of<MessageProvider>(context, listen: false).sendMessage(
      title: _titleController.text,
      message: _messageController.text,
      priority: _priority,
      applicationToken: _applicationTokenController.text.trim(),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Message sent successfully')),
    );
  }

  void _showErrorMessage() {
    final errorMessage =
        Provider.of<MessageProvider>(context, listen: false).error ??
            'Failed to send message';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _updatePriorityValue(int value) => setState(() => _priority = value);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Title',
                hintText: 'Enter message title',
                prefixIcon: Icons.title,
                controller: _titleController,
                validator: AppFormValidator.validateNotEmpty,
              ),
              const SizedBox(height: 24),
              AppFormField(
                label: 'Message',
                hintText: 'Enter message content',
                prefixIcon: Icons.message,
                controller: _messageController,
                validator: AppFormValidator.validateNotEmpty,
              ),
              const SizedBox(height: 24),
              ObscurableFormField(
                label: 'Application Token',
                hintText: 'Enter the application token',
                controller: _applicationTokenController,
                prefixIcon: Icons.vpn_key,
                validator: AppFormValidator.validateNotEmpty,
              ),
              const SizedBox(height: 24),
              PrioritySelector(
                priority: _priority,
                onPriorityChanged: _updatePriorityValue,
              ),
              const SizedBox(height: 32),
              SubmitButton(
                isLoading: _isSending,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
