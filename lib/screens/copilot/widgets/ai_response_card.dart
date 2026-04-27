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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI avatar
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: GestureDetector(
            onLongPress: () => _copy(context),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
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
                        backgroundColor: AppColors.primary.withValues(alpha: 0.07),
                        color: AppColors.primary,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_outlined,
                        size: 12,
                        color: AppColors.primaryLight.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Hold to copy',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryLight.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
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
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
