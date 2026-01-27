import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/suggested_questions_list.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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

            // Chat content
            Expanded(
              child: Consumer<AIProvider>(
                builder: (context, aiProvider, _) {
                  final hasMessages = aiProvider.chatHistory.isNotEmpty;

                  if (!hasMessages) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SuggestedQuestionsList(
                          onQuestionTap: _handleSuggestedQuestion,
                        ),
                      ),
                    );
                  }

                  return ChatMessageList(
                    messages: aiProvider.chatHistory,
                    scrollController: _scrollController,
                    isLoading: aiProvider.state == LoadingState.loading,
                  );
                },
              ),
            ),

            // Input field
            ChatInputField(
              controller: _messageController,
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
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
