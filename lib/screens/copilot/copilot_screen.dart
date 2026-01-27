import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ai_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import 'widgets/ai_response_card.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/suggested_questions_list.dart';
import 'widgets/loading_indicator.dart';
import 'conversation_history_screen.dart';

/// Perfin AI Assistant Tab - Conversational AI Interface
/// Requirements: 6.1-6.10
class CopilotScreen extends StatefulWidget {
  const CopilotScreen({super.key});

  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends State<CopilotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    final aiProvider = context.read<AIProvider>();
    aiProvider.sendCopilotQuery(message);
    _messageController.clear();

    // Auto-scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSuggestedQuestion(String question) {
    _messageController.text = question;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: Stack(
        children: [
          // Main content
          Consumer<AIProvider>(
            builder: (context, aiProvider, _) {
              final hasMessages = aiProvider.chatHistory.isNotEmpty;

              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Header that scrolls away
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Perfin',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -1,
                              ),
                            ),
                            Row(
                              children: [
                                // New conversation button
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 24,
                                  color: const Color(0xFF666666),
                                  onPressed: () {
                                    context.read<AIProvider>().createNewConversation();
                                  },
                                  tooltip: 'New conversation',
                                ),
                                const SizedBox(width: 8),
                                // Conversation history button
                                IconButton(
                                  icon: const Icon(Icons.history),
                                  iconSize: 24,
                                  color: const Color(0xFF666666),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ConversationHistoryScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: 'Conversation history',
                                ),
                                const SizedBox(width: 8),
                                // Clear current conversation button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  iconSize: 24,
                                  color: const Color(0xFF666666),
                                  onPressed: () {
                                    _showClearHistoryDialog();
                                  },
                                  tooltip: 'Clear current conversation',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Chat content
                  if (!hasMessages)
                    SliverFillRemaining(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SuggestedQuestionsList(
                            onQuestionTap: _handleSuggestedQuestion,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: 100 + MediaQuery.of(context).padding.bottom,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == aiProvider.chatHistory.length) {
                              if (aiProvider.state == LoadingState.loading) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 16, left: 20, right: 20),
                                  child: LoadingIndicator(),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final message = aiProvider.chatHistory[index];
                            final isUser = message.role == MessageRole.user;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
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
                          childCount: aiProvider.chatHistory.length + 
                              (aiProvider.state == LoadingState.loading ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Input field positioned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ChatInputField(
              controller: _messageController,
              onSend: _handleSendMessage,
            ),
          ),
        ],
      ),
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

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear Chat History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Are you sure you want to clear this conversation? This action cannot be undone.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AIProvider>().clearChatHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
