import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ai_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/transaction_provider.dart' show LoadingState;
import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import 'widgets/ai_response_card.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/suggested_questions_list.dart';
import 'widgets/loading_indicator.dart';
import 'conversation_history_screen.dart';

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

  Future<void> _handleSendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final sub = context.read<SubscriptionProvider>();
    if (!sub.canConsumeAiPrompt()) {
      if (!mounted) return;
      _showQuotaDialog(sub);
      return;
    }

    final ok = await sub.tryConsumeAiPrompt();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to send right now. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;
    context.read<AIProvider>().sendCopilotQuery(message);
    _messageController.clear();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Consumer2<AIProvider, SubscriptionProvider>(
        builder: (context, ai, sub, _) {
          final hasMessages = ai.chatHistory.isNotEmpty;
          return Column(
            children: [
              _Header(
                onNewChat: () => ai.createNewConversation(),
                onHistory: _openHistory,
                hasMessages: hasMessages,
                onClear: hasMessages ? _showClearDialog : null,
              ),
              Expanded(
                child: hasMessages
                    ? _MessageList(
                        ai: ai,
                        scrollController: _scrollController,
                      )
                    : _EmptyState(
                        onQuestionTap: (q) {
                          _messageController.text = q;
                        },
                      ),
              ),
              ChatInputField(
                controller: _messageController,
                onSend: _handleSendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  void _openHistory() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ConversationHistoryScreen()),
      );

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear chat?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This conversation will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AIProvider>().clearChatHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showQuotaDialog(SubscriptionProvider sub) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('AI Limit Reached',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            '${sub.currentPlan.displayName} plan: ${sub.aiPromptsUsed}/'
            '${sub.aiPromptsLimit ?? 0} prompts used.\n\n'
            'Upgrade to Pro for unlimited AI.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Upgrade',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onHistory;
  final bool hasMessages;
  final VoidCallback? onClear;

  const _Header({
    required this.onNewChat,
    required this.onHistory,
    required this.hasMessages,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6F2),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 12),
              child: Row(
                children: [
                  // Avatar + title
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 17),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Perfin AI',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2333),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (onClear != null)
                    _IconBtn(
                      icon: Icons.delete_outline_rounded,
                      onTap: onClear!,
                      tooltip: 'Clear chat',
                    ),
                  _IconBtn(
                    icon: Icons.history_rounded,
                    onTap: onHistory,
                    tooltip: 'History',
                  ),
                  _IconBtn(
                    icon: Icons.add_rounded,
                    onTap: onNewChat,
                    tooltip: 'New chat',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE4E1D8)),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color(0xFF6B7280), size: 22),
        ),
      ),
    );
  }
}

// ── Message list ───────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final AIProvider ai;
  final ScrollController scrollController;
  const _MessageList({required this.ai, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final count = ai.chatHistory.length +
        (ai.state == LoadingState.loading ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: count,
      itemBuilder: (context, i) {
        if (i == ai.chatHistory.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            child: LoadingIndicator(),
          );
        }

        final msg = ai.chatHistory[i];
        final isUser = msg.role == MessageRole.user;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isUser ? _UserBubble(message: msg) : AIResponseCard(message: msg),
              const SizedBox(height: 3),
              Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(fontSize: 10, color: Color(0xFFB0B8C4)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('h:mm a').format(ts);
    return DateFormat('MMM d').format(ts);
  }
}

// ── User bubble ────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Copied'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
              fontSize: 15, color: Colors.white, height: 1.45),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Function(String) onQuestionTap;
  const _EmptyState({required this.onQuestionTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        // Mascot
        Center(
          child: Image.asset(
            'assets/images/perfin_ai.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Ask me anything',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2333),
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Spending, budgets, goals, financial health.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7B808A),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'SUGGESTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFADB3BE),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        SuggestedQuestionsList(onQuestionTap: onQuestionTap),
      ],
    );
  }
}
