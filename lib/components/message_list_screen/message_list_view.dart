import 'package:flutter/material.dart';
import 'package:gotify_client/components/message_list_screen/date_header.dart';
import 'package:gotify_client/components/message_list_screen/message_card.dart';
import 'package:gotify_client/models/message_model.dart';

class MessageListView extends StatelessWidget {
  final Map<String, List<Message>> groupedMessages;
  final Future<void> Function() onRefresh;
  final Function(Message) onDeletePressed;

  const MessageListView({
    super.key,
    required this.groupedMessages,
    required this.onRefresh,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in groupedMessages.entries) ...[
            DateHeader(title: entry.key),
            const SizedBox(height: 8),
            ...entry.value.map((message) => MessageCard(
                  message: message,
                  onDeletePressed: onDeletePressed,
                )),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
