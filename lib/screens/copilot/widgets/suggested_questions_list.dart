import 'package:flutter/material.dart';

/// Display suggested questions for first-time users
/// Requirements: 6.10
class SuggestedQuestionsList extends StatelessWidget {
  final Function(String) onQuestionTap;

  const SuggestedQuestionsList({
    super.key,
    required this.onQuestionTap,
  });

  static const List<Map<String, String>> _suggestedQuestions = [
    {
      'icon': '💰',
      'question': 'How much did I spend this month?',
    },
    {
      'icon': '📊',
      'question': 'Am I on track with my budget?',
    },
    {
      'icon': '🎯',
      'question': 'What are my top spending categories?',
    },
    {
      'icon': '💳',
      'question': 'Can I afford a \$500 purchase?',
    },
    {
      'icon': '📈',
      'question': 'How does my spending compare to last month?',
    },
    {
      'icon': '🔮',
      'question': 'What will I spend by the end of the month?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Perfin AI image
        Image.asset(
          'assets/images/perfin_ai.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        
        const SizedBox(height: 32),
        
        // Welcome message
        const Text(
          'Meet Perfin',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your AI financial assistant. Ask me anything about your spending, budgets, and financial goals.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Suggested questions label
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Try asking:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Suggested questions grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _suggestedQuestions.length,
          itemBuilder: (context, index) {
            final item = _suggestedQuestions[index];
            return _buildQuestionCard(
              context,
              icon: item['icon']!,
              question: item['question']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context, {
    required String icon,
    required String question,
  }) {
    return GestureDetector(
      onTap: () => onQuestionTap(question),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
