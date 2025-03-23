import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/components/priority_indicator.dart';
import 'package:intl/intl.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  MessageListScreenState createState() => MessageListScreenState();
}

class MessageListScreenState extends State<MessageListScreen> {
  String _selectedFilter = 'All';

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
          'Are you sure you want to delete this message: "${message.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('CANCEL', style: TextStyle(color: colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('DELETE', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to delete message'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: Consumer<MessageProvider>(
            builder: (context, messageProvider, _) {
              if (messageProvider.isLoading &&
                  messageProvider.messages.isEmpty) {
                return _buildLoadingView();
              }

              if (messageProvider.error != null &&
                  messageProvider.messages.isEmpty) {
                return _buildErrorView(messageProvider);
              }

              if (messageProvider.messages.isEmpty) {
                return _buildEmptyView();
              }

              final filteredMessages =
                  _filterMessages(messageProvider.messages);
              final groupedMessages = _groupMessagesByDate(filteredMessages);

              return _buildMessageList(groupedMessages);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip('High Priority'),
            const SizedBox(width: 8),
            _buildFilterChip('Medium Priority'),
            const SizedBox(width: 8),
            _buildFilterChip('Low Priority'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  List<Message> _filterMessages(List<Message> messages) {
    switch (_selectedFilter) {
      case 'High Priority':
        return messages.where((message) => message.priority >= 8).toList();
      case 'Medium Priority':
        return messages
            .where((message) => message.priority >= 4 && message.priority < 8)
            .toList();
      case 'Low Priority':
        return messages.where((message) => message.priority < 4).toList();
      default:
        return messages;
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
    try {
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
    } catch (e) {
      return 'Other';
    }
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(MessageProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${provider.error}',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFD1D5DB) // Gray-300
                : const Color(0xFF6B7280), // Gray-500
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(Map<String, List<Message>> groupedMessages) {
    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in groupedMessages.entries) ...[
            _buildDateHeader(entry.key),
            const SizedBox(height: 8),
            ...entry.value.map((message) => _buildMessageCard(message)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFF6B7280) // Gray-500
              : const Color(0xFF9CA3AF), // Gray-400
        ),
      ),
    );
  }

  Widget _buildMessageCard(Message message) {
    return Dismissible(
      key: Key('message-${message.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteMessage(message),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDismiss(message),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriorityIndicator(priority: message.priority),
                  Text(
                    _formatTimeAgo(message.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF6B7280) // Gray-500
                          : const Color(0xFF9CA3AF), // Gray-400
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      message.appid.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'App ID: ${message.appid}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.title.isNotEmpty ? message.title : 'Notification',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF4B5563) // Gray-600
                      : const Color(0xFFD1D5DB), // Gray-300
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(Message message) async {
    final colorScheme = Theme.of(context).colorScheme;

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Message'),
            content: Text('Are you sure you want to delete this message?'),
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
        false; // Default to false if dialog returns null
  }

  String _formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, y HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeAgo(String dateString) {
    try {
      final now = DateTime.now();
      final date = DateTime.parse(dateString).toLocal();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return _formatDateTime(dateString);
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}
