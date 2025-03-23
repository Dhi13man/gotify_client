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
  static const int defaultApplicationId = 1;
  static const int defaultPriority = PriorityLevels.normal;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _priority = defaultPriority;
  int _applicationId = defaultApplicationId;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
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
        Navigator.of(context).pop();
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
      applicationId: _applicationId,
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent successfully')),
    );
  }

  void _showErrorMessage() {
    final errorMessage =
        Provider.of<MessageProvider>(context, listen: false).error ??
            'Failed to send message';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updatePriorityValue(int value) {
    setState(() => _priority = value);
  }

  void _updateApplicationId(String value) {
    final parsedValue = int.tryParse(value);
    if (parsedValue != null) {
      setState(() => _applicationId = parsedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Message')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildMessageField(),
                const SizedBox(height: 16),
                _buildPrioritySection(),
                const SizedBox(height: 16),
                _buildApplicationIdField(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        labelText: 'Message',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority: $_priority',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: _priority.toDouble(),
          min: PriorityLevels.min.toDouble(),
          max: PriorityLevels.max.toDouble(),
          divisions: PriorityLevels.max - PriorityLevels.min,
          label: _priority.toString(),
          onChanged: (double value) => _updatePriorityValue(value.toInt()),
        ),
        const SizedBox(height: 8),
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
    );
  }

  Widget _buildApplicationIdField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Application ID',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      initialValue: _applicationId.toString(),
      onChanged: _updateApplicationId,
      validator: _validateApplicationId,
    );
  }

  String? _validateApplicationId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an application ID';
    }
    if (int.tryParse(value) == null) {
      return 'Application ID must be a number';
    }
    return null;
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSending ? null : _sendMessage,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSending
            ? const CircularProgressIndicator()
            : const Text('Send Message', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _priorityChip(String label, int value) {
    return FilterChip(
      label: Text(label),
      selected: _priority == value,
      onSelected: (bool selected) {
        if (selected) {
          _updatePriorityValue(value);
        }
      },
    );
  }
}
