import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/message_provider.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:intl/intl.dart';
import 'send_message_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  MessageListScreenState createState() => MessageListScreenState();
}

class MessageListScreenState extends State<MessageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    await Provider.of<MessageProvider>(context, listen: false).loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gotify Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          if (messageProvider.isLoading && messageProvider.messages.isEmpty) {
            return _buildLoadingView();
          }

          if (messageProvider.error != null &&
              messageProvider.messages.isEmpty) {
            return _buildErrorView(messageProvider);
          }

          if (messageProvider.messages.isEmpty) {
            return _buildEmptyView();
          }

          return _buildMessageList(messageProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSendMessage(context),
        tooltip: 'Send Message',
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(MessageProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: ${provider.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(MessageProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.messages.length,
        itemBuilder: (context, index) =>
            _buildMessageCard(provider.messages[index]),
      ),
    );
  }

  Widget _buildMessageCard(Message message) {
    final priorityColor = MessageUIUtils.getPriorityColor(message.priority);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageHeader(message, priorityColor),
            _buildMessageContent(message),
            _buildMessageFooter(message),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageHeader(Message message, Color priorityColor) {
    return Container(
      color: priorityColor.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message.title.isNotEmpty ? message.title : 'Notification',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Priority ${message.priority}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message.message,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildMessageFooter(Message message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'App ID: ${message.appid}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            MessageUIUtils.formatDateTime(message.date),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSendMessage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SendMessageScreen()),
    );
  }
}

/// Utility class for message UI formatting
class MessageUIUtils {
  static String formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, y HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  static Color getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red[700]!;
    if (priority >= 4) return Colors.amber[700]!;
    return Colors.blue[700]!;
  }
}
