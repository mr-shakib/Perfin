import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/goal_provider.dart' as goal_provider;
import '../../providers/ai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/transaction_provider.dart' show LoadingState;
import '../../models/goal.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import 'widgets/goal_progress_chart.dart';
import 'widgets/ai_feasibility_card.dart';
import 'widgets/goal_prioritization_card.dart';

/// Full-screen view of goal details with AI insights
/// Requirements: 9.1-9.12, 10.1-10.10
class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAIInsights();
    });
  }

  Future<void> _loadAIInsights() async {
    if (!mounted) return;

    final goalProvider = context.read<goal_provider.GoalProvider>();
    final aiProvider = context.read<AIProvider>();
    final authProvider = context.read<AuthProvider>();

    final goal = goalProvider.getGoalById(widget.goalId);
    if (goal == null || authProvider.user == null) return;

    // Load AI feasibility analysis
    await aiProvider.analyzeGoalFeasibility(goal);

    // Load goal prioritization if multiple goals exist
    if (goalProvider.activeGoals.length > 1) {
      await aiProvider.prioritizeGoals(goalProvider.activeGoals);
    }
  }

  void _showAddMoneyDialog(Goal goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money to Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: \$${_formatAmount(goal.currentAmount)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Amount to Add',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'This will be recorded as an expense transaction',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amountToAdd = double.tryParse(controller.text);
              if (amountToAdd != null && amountToAdd > 0) {
                try {
                  final authProvider = context.read<AuthProvider>();
                  final transactionProvider = context.read<TransactionProvider>();
                  
                  // Create a transaction for this goal contribution
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: amountToAdd,
                    category: 'Savings', // You might want to make this configurable
                    type: TransactionType.expense,
                    date: DateTime.now(),
                    notes: 'Added to goal: ${goal.name}',
                    userId: authProvider.user!.id,
                    linkedGoalId: goal.id,
                  );
                  
                  // Save the transaction
                  await transactionProvider.addTransaction(transaction);
                  
                  // Update goal progress
                  final newTotal = goal.currentAmount + amountToAdd;
                  await context.read<goal_provider.GoalProvider>().updateGoalProgress(
                        goalId: goal.id,
                        userId: authProvider.user!.id,
                        newAmount: newTotal,
                      );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added \$${amountToAdd.toStringAsFixed(2)}! New total: \$${newTotal.toStringAsFixed(2)}'),
                        backgroundColor: const Color(0xFF4CAF50),
                        action: SnackBarAction(
                          label: 'View',
                          textColor: Colors.white,
                          onPressed: () {
                            // Could navigate to transactions tab
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFF44336),
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount greater than zero'),
                    backgroundColor: const Color(0xFFF44336),
                  ),
                );
              }
            },
            child: const Text('Add & Record'),
          ),
        ],
      ),
    );
  }

  void _showSetAmountDialog(Goal goal) {
    final controller = TextEditingController(
      text: goal.currentAmount.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the exact current amount',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Current Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 0) {
                try {
                  final authProvider = context.read<AuthProvider>();
                  await context.read<goal_provider.GoalProvider>().updateGoalProgress(
                        goalId: goal.id,
                        userId: authProvider.user!.id,
                        newAmount: amount,
                      );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Amount updated'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFF44336),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authProvider = context.read<AuthProvider>();
                await context.read<goal_provider.GoalProvider>().deleteGoal(
                      goalId: goal.id,
                      userId: authProvider.user!.id,
                    );
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal deleted'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: const Color(0xFFF44336),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markAsComplete(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete'),
        content: Text('Congratulations! Mark "${goal.name}" as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authProvider = context.read<AuthProvider>();
                await context.read<goal_provider.GoalProvider>().markGoalComplete(
                      goalId: goal.id,
                      userId: authProvider.user!.id,
                    );
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Goal completed!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: const Color(0xFFF44336),
                    ),
                  );
                }
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(
        backgroundColor: AppColors.creamLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<goal_provider.GoalProvider>(
            builder: (context, goalProvider, _) {
              final goal = goalProvider.getGoalById(widget.goalId);
              if (goal == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
                onSelected: (value) {
                  switch (value) {
                    case 'delete':
                      _showDeleteConfirmation(goal);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Color(0xFFF44336)),
                        SizedBox(width: 12),
                        Text('Delete Goal'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer3<goal_provider.GoalProvider, AIProvider, AuthProvider>(
        builder: (context, goalProvider, aiProvider, authProvider, _) {
          final goal = goalProvider.getGoalById(widget.goalId);

          if (goal == null) {
            return const Center(
              child: Text('Goal not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal header
                _buildGoalHeader(goal),

                const SizedBox(height: 24),

                // Progress chart
                GoalProgressChart(goal: goal),

                const SizedBox(height: 24),

                // AI Feasibility analysis
                AIFeasibilityCard(
                  analysis: aiProvider.currentFeasibilityAnalysis,
                  isLoading: aiProvider.state == LoadingState.loading,
                ),

                const SizedBox(height: 24),

                // Goal prioritization (if multiple goals)
                if (goalProvider.activeGoals.length > 1)
                  GoalPrioritizationCard(
                    prioritization: aiProvider.currentPrioritization,
                    goals: goalProvider.activeGoals,
                    isLoading: aiProvider.state == LoadingState.loading,
                  ),

                const SizedBox(height: 24),

                // Action buttons
                if (!goal.isCompleted) _buildActionButtons(goal),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalHeader(Goal goal) {
    final progressPercentage = goal.progressPercentage.clamp(0.0, 100.0);
    final daysRemaining = goal.daysRemaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal name
        Text(
          goal.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 16),

        // Amount progress with Add Money button
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Amount',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatAmount(goal.currentAmount)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'of \$${_formatAmount(goal.targetAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Quick Add Money button
            if (!goal.isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddMoneyDialog(goal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Add Money',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => _showSetAmountDialog(goal),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      'Set',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressPercentage / 100,
            minHeight: 12,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF1A1A1A),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '${progressPercentage.toStringAsFixed(1)}% complete',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),

        const SizedBox(height: 16),

        // Info chips
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInfoChip(
              icon: Icons.calendar_today,
              label: DateFormat('MMM d, yyyy').format(goal.targetDate),
              sublabel: '$daysRemaining days left',
            ),
            _buildInfoChip(
              icon: Icons.savings_outlined,
              label: '\$${_formatAmount(goal.requiredMonthlySavings)}/month',
              sublabel: 'Required savings',
            ),
          ],
        ),

        if (goal.isManualTracking) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Color(0xFFFF9800),
                ),
                SizedBox(width: 8),
                Text(
                  'Manually tracked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF666666),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Goal goal) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _markAsComplete(goal),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.check_circle, size: 24),
        label: const Text(
          'Mark as Complete',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return NumberFormat('#,##0').format(amount);
    }
    return amount.toStringAsFixed(0);
  }
}
