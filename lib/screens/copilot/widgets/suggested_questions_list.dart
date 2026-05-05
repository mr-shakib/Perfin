import 'package:flutter/material.dart';

class SuggestedQuestionsList extends StatelessWidget {
  final Function(String) onQuestionTap;

  const SuggestedQuestionsList({super.key, required this.onQuestionTap});

  static const _questions = [
    ('💰', 'How much did I spend this month?'),
    ('📊', 'Am I on track with my budget?'),
    ('🎯', 'What are my top spending categories?'),
    ('📈', 'How does my spending compare to last month?'),
    ('🔮', 'What will I spend by end of month?'),
    ('💳', 'Can I afford a \$500 purchase?'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _questions.map((q) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _QuestionTile(
            icon: q.$1,
            question: q.$2,
            onTap: () => onQuestionTap(q.$2),
          ),
        );
      }).toList(),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final String icon;
  final String question;
  final VoidCallback onTap;

  const _QuestionTile({
    required this.icon,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E4DA), width: 1),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A2333),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
