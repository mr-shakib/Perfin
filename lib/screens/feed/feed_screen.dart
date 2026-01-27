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
          // Create a combined list of items with their dates
          final List<MapEntry<DateTime, Widget>> items = [];

          // Add transactions with their dates
          for (final transaction in transactionProvider.transactions) {
            items.add(MapEntry(
              transaction.date,
              TransactionDetailCard(transaction: transaction),
            ));
          }

          // Add goals with their creation/update dates
          for (final goal in goalProvider.goals) {
            items.add(MapEntry(
              goal.createdAt,
              GoalDetailCard(goal: goal),
            ));
          }

          // Sort all items by date (most recent first)
          items.sort((a, b) => b.key.compareTo(a.key));

          // Extract just the widgets
          final List<Widget> pages = items.map((item) => item.value).toList();

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
