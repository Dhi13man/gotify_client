// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';

/// Constants for priority levels
class PriorityLevels {
  static const int low = 1;
  static const int normal = 3;
  static const int high = 7;
  static const int urgent = 10;
  static const int min = 0;
  static const int max = 10;
}

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  SendMessageScreenState createState() => SendMessageScreenState();
}

class SendMessageScreenState extends State<SendMessageScreen> {
  static const int defaultPriority = PriorityLevels.normal;
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
    final colorScheme = Theme.of(context).colorScheme;

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
                      color: _getPriorityColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getPriorityLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getPriorityColor(),
                  inactiveTrackColor:
                      _getPriorityColor().withValues(alpha: 0.2),
                  thumbColor: _getPriorityColor(),
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _priority.toDouble(),
                  min: PriorityLevels.min.toDouble(),
                  max: PriorityLevels.max.toDouble(),
                  divisions: PriorityLevels.max - PriorityLevels.min,
                  label: _priority.toString(),
                  onChanged: (double value) =>
                      _updatePriorityValue(value.toInt()),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _priorityChip('Low', PriorityLevels.low),
                  _priorityChip('Normal', PriorityLevels.normal),
                  _priorityChip('High', PriorityLevels.high),
                  _priorityChip('Urgent', PriorityLevels.urgent),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Color _getPriorityColor() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_priority >= 8) return colorScheme.error;
    if (_priority >= 4) return const Color(0xFFF59E0B); // Warning color
    return colorScheme.primary;
  }

  String _getPriorityLabel() {
    if (_priority >= 8) return 'Urgent';
    if (_priority >= 4) return 'High';
    if (_priority >= 2) return 'Normal';
    return 'Low';
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

  Widget _priorityChip(String label, int value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _priority == value;

    Color chipColor;
    if (value >= 8) {
      chipColor = colorScheme.error;
    } else if (value >= 4) {
      chipColor = const Color(0xFFF59E0B); // Warning color
    } else {
      chipColor = colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => _updatePriorityValue(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? chipColor
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? chipColor : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
