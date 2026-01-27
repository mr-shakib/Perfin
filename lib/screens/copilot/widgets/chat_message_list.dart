import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_message.dart';
import 'ai_response_card.dart';
import 'loading_indicator.dart';

/// Scrollable list of chat messages
/// Requirements: 6.1, 6.4
class ChatMessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isLoading;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isLoading = false,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages are added
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          widget.scrollController.animateTo(
            widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == widget.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LoadingIndicator(),
          );
        }

        final message = widget.messages[index];
        final isUser = message.role == MessageRole.user;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: isUser 
                ? CrossAxisAlignment.end 
                : CrossAxisAlignment.start,
            children: [
              // Message bubble
              if (isUser)
                _buildUserMessage(message)
              else
                AIResponseCard(message: message),
              
              // Timestamp
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    return GestureDetector(
      onLongPress: () => _copyMessage(message.content),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy,
              size: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(timestamp);
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}
