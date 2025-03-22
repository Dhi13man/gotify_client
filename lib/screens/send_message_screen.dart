import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({Key? key}) : super(key: key);

  @override
  SendMessageScreenState createState() => SendMessageScreenState();
}

class SendMessageScreenState extends State<SendMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _priority = 3;
  int _applicationId = 1; // Default application ID
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      final success = await Provider.of<MessageProvider>(context, listen: false)
          .sendMessage(
        title: _titleController.text,
        message: _messageController.text,
        priority: _priority,
        applicationId: _applicationId,
      );

      setState(() {
        _isSending = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<MessageProvider>(context, listen: false).error ??
                  'Failed to send message',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Priority: $_priority',
                  style: const TextStyle(fontSize: 16),
                ),
                Slider(
                  value: _priority.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _priority.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _priority = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _priorityChip('Low', 1),
                    _priorityChip('Normal', 3),
                    _priorityChip('High', 7),
                    _priorityChip('Urgent', 10),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Application ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _applicationId.toString(),
                  onChanged: (value) {
                    setState(() {
                      _applicationId = int.tryParse(value) ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
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
                        : const Text('Send Message',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(String label, int value) {
    return FilterChip(
      label: Text(label),
      selected: _priority == value,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _priority = value;
          });
        }
      },
    );
  }
}
