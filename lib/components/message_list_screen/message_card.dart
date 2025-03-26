import 'package:flutter/material.dart';
import 'package:gotify_client/components/message_list_screen/priority_indicator.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final Function(Message) onDeletePressed;

  const MessageCard({
    super.key,
    required this.message,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
            SelectableText(
              message.message,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF4B5563) // Gray-600
                    : const Color(0xFFD1D5DB), // Gray-300
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriorityIndicator(priority: message.priority),
                Row(
                  children: [
                    Text(
                      _formatTimeAgo(message.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF6B7280) // Gray-500
                            : const Color(0xFF9CA3AF), // Gray-400
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => onDeletePressed(message),
                      tooltip: 'Delete message',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, y HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return dateString;
    }
  }
}
