import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/transaction_detail_card.dart';
import 'widgets/goal_detail_card.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/goal_provider.dart';

/// Feed Screen - TikTok-style vertical scrolling
/// Full-screen cards showing individual transactions and goals
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: Consumer2<TransactionProvider, GoalProvider>(
        builder: (context, transactionProvider, goalProvider, _) {
          // Get transactions sorted by date (most recent first)
          final sortedTransactions = List.from(transactionProvider.transactions)
            ..sort((a, b) => b.date.compareTo(a.date));

          final List<Widget> pages = [
            // Individual transaction cards (most recent first)
            ...sortedTransactions.map((transaction) => 
              TransactionDetailCard(transaction: transaction)
            ),
            // Individual goal cards with progress
            ...goalProvider.goals.map((goal) => 
              GoalDetailCard(goal: goal)
            ),
          ];

          if (pages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: const Color(0xFF999999).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions or goals yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF666666).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: pages,
          );
        },
      ),
    );
  }
}
