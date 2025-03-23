// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message sent successfully'),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  void _showErrorMessage() {
    final colorScheme = Theme.of(context).colorScheme;
    final errorMessage =
        Provider.of<MessageProvider>(context, listen: false).error ??
            'Failed to send message';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  void _updatePriorityValue(int value) {
    setState(() => _priority = value);
  }

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
              _buildTitleField(),
              const SizedBox(height: 24),
              _buildMessageField(),
              const SizedBox(height: 24),
              _buildPrioritySection(),
              const SizedBox(height: 24),
              _buildApplicationTokenField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter message title',
        prefixIcon: Icon(
          Icons.title,
          color: colorScheme.primary,
        ),
      ),
      validator: _validateTitle,
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  Widget _buildMessageField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        labelText: 'Message',
        hintText: 'Enter your message content',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Icon(
            Icons.message,
            color: colorScheme.primary,
          ),
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

  Widget _buildPrioritySection() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color priorityColor = AppTheme.getPriorityColor(context, _priority);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      PriorityType.fromNumeric(_priority).toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: priorityColor,
                  inactiveTrackColor: priorityColor.withValues(alpha: 0.2),
                  thumbColor: priorityColor,
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _priority.toDouble(),
                  min: PriorityType.min.numericValue.toDouble(),
                  max: PriorityType.max.numericValue.toDouble(),
                  divisions: PriorityType.max.numericValue -
                      PriorityType.min.numericValue,
                  label: _priority.toString(),
                  onChanged: (double value) =>
                      _updatePriorityValue(value.toInt()),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _priorityChip(PriorityType.low),
                  _priorityChip(PriorityType.medium),
                  _priorityChip(PriorityType.high),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildApplicationTokenField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _applicationTokenController,
      decoration: InputDecoration(
        labelText: 'Application Token',
        hintText: 'Enter the application token',
        prefixIcon: Icon(
          Icons.vpn_key,
          color: colorScheme.primary,
        ),
      ),
      validator: _validateApplicationToken,
    );
  }

  String? _validateApplicationToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an application token';
    }
    return null;
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _sendMessage,
        icon: _isSending
            ? Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.send),
        label: Text(
          'Send Message',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(PriorityType priority) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _priority == priority.numericValue;
    final Color priorityColor =
        AppTheme.getPriorityColor(context, priority.numericValue);
    return GestureDetector(
      onTap: () => _updatePriorityValue(priority.numericValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? priorityColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? priorityColor
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          priority.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? priorityColor : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
