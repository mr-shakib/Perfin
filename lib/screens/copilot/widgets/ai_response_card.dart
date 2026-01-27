import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../models/chat_message.dart';

/// Display AI response with formatting
/// Requirements: 7.1-7.10
class AIResponseCard extends StatelessWidget {
  final ChatMessage message;

  const AIResponseCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = message.metadata ?? {};
    final dataReferences = metadata['dataReferences'] as List<dynamic>?;
    final calculations = metadata['calculations'] as List<dynamic>?;

    return GestureDetector(
      onLongPress: () => _copyMessage(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI response text with markdown support
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  height: 1.5,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1A1A1A),
                ),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  backgroundColor: Color(0xFFE5E5E5),
                  color: Color(0xFF1A1A1A),
                ),
                listBullet: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

            // Calculations
            if (calculations != null && calculations.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCalculations(calculations.cast<String>()),
            ],

            // Data references
            if (dataReferences != null && dataReferences.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDataReferences(dataReferences),
            ],
          ],
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI response copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCalculations(List<String> calculations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                size: 16,
                color: Color(0xFF0369A1),
              ),
              SizedBox(width: 6),
              Text(
                'Calculations',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0369A1),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...calculations.map((calc) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $calc',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF075985),
                fontFamily: 'monospace',
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDataReferences(List<dynamic> dataReferences) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9D5FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.source_outlined,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
              SizedBox(width: 6),
              Text(
                'Data Sources',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dataReferences.take(3).map((ref) {
            final refMap = ref as Map<String, dynamic>;
            final description = refMap['description'] as String? ?? 'Unknown';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $description',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B21A8),
                ),
              ),
            );
          }),
          if (dataReferences.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${dataReferences.length - 3} more',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C3AED),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
