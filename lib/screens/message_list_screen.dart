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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false).loadMessages();
    });
  }

  String _formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, y HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red[700]!;
    if (priority >= 4) return Colors.amber[700]!;
    return Colors.blue[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gotify Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MessageProvider>(context, listen: false)
                  .loadMessages();
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          if (messageProvider.isLoading && messageProvider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.error != null &&
              messageProvider.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${messageProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      messageProvider.loadMessages();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (messageProvider.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => messageProvider.loadMessages(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messageProvider.messages.length,
              itemBuilder: (context, index) {
                final message = messageProvider.messages[index];
                return _buildMessageCard(message);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SendMessageScreen()),
          );
        },
        tooltip: 'Send Message',
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget _buildMessageCard(Message message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPriorityColor(message.priority).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: _getPriorityColor(message.priority).withValues(alpha: .8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Padding(
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
                    _formatDateTime(message.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
