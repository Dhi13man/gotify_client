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
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    final MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    // First, optimistically remove the message from the local state
    messageProvider.removeMessageLocally(message.id);
    final result = await messageProvider.deleteMessage(message.id);

    if (!mounted) return;

    if (result) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: const Text('Message deleted successfully')),
      );
    } else {
      // Restore the message if deletion failed
      messageProvider.restoreMessage(message);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: const Text('Failed to delete message')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(Message message) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Message'),
            content:
                const Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  'DELETE',
                  style: TextStyle(color: colorScheme.error),
                ),
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

  String _getDateGroupKey(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    final DateTime localDate = date.toLocal();
    final DateTime messageDate =
        DateTime(localDate.year, localDate.month, localDate.day);
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(localDate);
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

              final filteredMessages =
                  filterMessages(messageProvider.messages, _selectedFilter);
              final groupedMessages = _groupMessagesByDate(filteredMessages);

              if (groupedMessages.isEmpty) {
                return const EmptyMessagesView();
              }

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
