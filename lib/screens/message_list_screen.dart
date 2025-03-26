import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/components/message_list_screen/filter_bar.dart';
import 'package:gotify_client/screens/loading_screen.dart';
import 'package:gotify_client/screens/error_screen.dart';
import 'package:gotify_client/components/message_list_screen/empty_messages_view.dart';
import 'package:gotify_client/components/message_list_screen/message_list_view.dart';
import 'package:gotify_client/models/enums.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:intl/intl.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  MessageListScreenState createState() => MessageListScreenState();
}

class MessageListScreenState extends State<MessageListScreen> {
  PriorityType _selectedFilter = PriorityType.min;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    await Provider.of<MessageProvider>(context, listen: false).loadMessages();
  }

  Future<void> _deleteMessage(Message message) async {
    // Store context objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    // First, optimistically remove the message from the local state
    messageProvider.removeMessageLocally(message.id);
    final result = await messageProvider.deleteMessage(message.id);

    if (!mounted) return;

    if (result) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Message deleted successfully'),
          backgroundColor: colorScheme.primary,
        ),
      );
    } else {
      // Restore the message if deletion failed
      messageProvider.restoreMessage(message);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to delete message'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(Message message) async {
    final colorScheme = Theme.of(context).colorScheme;

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Message'),
            content:
                const Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('CANCEL',
                    style: TextStyle(color: colorScheme.primary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child:
                    Text('DELETE', style: TextStyle(color: colorScheme.error)),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && mounted) {
      await _deleteMessage(message);
    }
  }

  Map<String, List<Message>> _groupMessagesByDate(List<Message> messages) {
    final Map<String, List<Message>> grouped = {};

    for (final message in messages) {
      final dateKey = _getDateGroupKey(message.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(message);
    }

    return grouped;
  }

  String _getDateGroupKey(String dateString) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final date = DateTime.parse(dateString).toLocal();
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterBar(
          selectedFilter: _selectedFilter,
          onFilterChanged: (PriorityType filter) =>
              setState(() => _selectedFilter = filter),
        ),
        Expanded(
          child: Consumer<MessageProvider>(
            builder: (context, messageProvider, _) {
              if (messageProvider.isLoading &&
                  messageProvider.messages.isEmpty) {
                return const LoadingScreen();
              }

              if (messageProvider.error != null &&
                  messageProvider.messages.isEmpty) {
                return ErrorScreen(
                  errorMessage: messageProvider.error,
                  onRetry: _loadMessages,
                );
              }

              if (messageProvider.messages.isEmpty) {
                return const EmptyMessagesView();
              }

              final filteredMessages =
                  filterMessages(messageProvider.messages, _selectedFilter);
              final groupedMessages = _groupMessagesByDate(filteredMessages);

              return MessageListView(
                groupedMessages: groupedMessages,
                onRefresh: _loadMessages,
                onDeletePressed: _showDeleteConfirmation,
              );
            },
          ),
        ),
      ],
    );
  }
}
