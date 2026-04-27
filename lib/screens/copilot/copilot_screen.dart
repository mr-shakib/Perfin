import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ai_provider.dart';
import '../../providers/on_device_ai_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import '../../screens/settings/on_device_ai_settings_screen.dart';
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
      backgroundColor: const Color(0xFFF4F3EE),
      body: Consumer3<AIProvider, SubscriptionProvider, OnDeviceAIProvider>(
        builder: (context, ai, sub, onDevice, _) {
          final hasMessages = ai.chatHistory.isNotEmpty;
          return Column(
            children: [
              _Header(ai: ai, sub: sub, onDevice: onDevice,
                  onNewChat: () => ai.createNewConversation(),
                  onHistory: _openHistory,
                  onClear: _showClearDialog),
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
        title: const Text('Clear conversation?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This conversation will be deleted. This cannot be undone.'),
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
            '${sub.aiPromptsLimit ?? 0} prompts this month.\n'
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
            child: const Text('View Plans',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AIProvider ai;
  final SubscriptionProvider sub;
  final OnDeviceAIProvider onDevice;
  final VoidCallback onNewChat;
  final VoidCallback onHistory;
  final VoidCallback onClear;

  const _Header({
    required this.ai,
    required this.sub,
    required this.onDevice,
    required this.onNewChat,
    required this.onHistory,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = sub.hasUnlimitedAiPrompts
        ? '∞'
        : '${sub.aiPromptsUsed}/${sub.aiPromptsLimit ?? 0}';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              // Title + backend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perfin AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OnDeviceAISettingsScreen()),
                      ),
                      child: _BackendPill(
                        label: ai.activeBackendName,
                        isOnDevice: ai.isUsingOnDevice,
                      ),
                    ),
                  ],
                ),
              ),
              // Usage badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 13, color: AppColors.secondary),
                    const SizedBox(width: 3),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Action icons
              _HeaderIcon(
                icon: Icons.add_rounded,
                tooltip: 'New chat',
                onTap: onNewChat,
              ),
              _HeaderIcon(
                icon: Icons.history_rounded,
                tooltip: 'History',
                onTap: onHistory,
              ),
              _HeaderIcon(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Clear',
                onTap: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendPill extends StatelessWidget {
  final String label;
  final bool isOnDevice;
  const _BackendPill({required this.label, required this.isOnDevice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOnDevice
            ? AppColors.secondary.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnDevice ? Icons.phone_android_outlined : Icons.cloud_outlined,
            size: 10,
            color: isOnDevice ? AppColors.secondary : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isOnDevice ? AppColors.secondary : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _HeaderIcon(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

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
        // Loading indicator at the end
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
              isUser
                  ? _UserBubble(message: msg)
                  : AIResponseCard(message: msg),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFFAFB8C4)),
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
    if (diff.inDays < 7) return DateFormat('EEE h:mm a').format(ts);
    return DateFormat('MMM d').format(ts);
  }
}

// ── User bubble ───────────────────────────────────────────────────────────────

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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Function(String) onQuestionTap;
  const _EmptyState({required this.onQuestionTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          // Hero icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hi, I\'m Perfin AI!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your spending,\nbudgets, goals, and financial health.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.primaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Suggestion chips
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SuggestedQuestionsList(onQuestionTap: onQuestionTap),
        ],
      ),
    );
  }
}
