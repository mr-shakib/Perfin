import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../models/chat_message.dart';
import '../../../theme/app_colors.dart';

class AIResponseCard extends StatelessWidget {
  final ChatMessage message;
  const AIResponseCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.auto_awesome,
              color: AppColors.primary, size: 15),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: GestureDetector(
            onLongPress: () => _copy(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                border: Border.all(color: const Color(0xFFEBE8E0), width: 1),
              ),
              child: MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    height: 1.55,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF475569),
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.07),
                    color: AppColors.primary,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _copy(BuildContext context) {
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
  }
}
