import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_colors.dart';

/// Manage Budget Screen
/// Allows users to set monthly budget and category budgets
class ManageBudgetScreen extends StatefulWidget {
  const ManageBudgetScreen({super.key});

  @override
  State<ManageBudgetScreen> createState() => _ManageBudgetScreenState();
}

class _ManageBudgetScreenState extends State<ManageBudgetScreen> {
  final _monthlyBudgetController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {};
  bool _isLoading = false;
  List<String> _categories = [];

  final List<String> _defaultCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final budgetProvider = context.read<BudgetProvider>();
    
    // Get existing categories from budget provider
    final existingCategories = budgetProvider.categoryBudgets.keys.toSet();
    
    // Try to get categories from transactions if available
    try {
      final transactionProvider = context.read<TransactionProvider>();
      final transactionCategories = transactionProvider.transactions
          .map((t) => t.category)
          .toSet();
      existingCategories.addAll(transactionCategories);
    } catch (e) {
      // TransactionProvider might not be available, continue with existing categories
    }
    
    // Combine with default categories
    final allCategories = {..._defaultCategories, ...existingCategories}.toList()
      ..sort();
    
    setState(() {
      _categories = allCategories;
    });
    
    _initializeControllers();
  }

  void _initializeControllers() {
    final budgetProvider = context.read<BudgetProvider>();
    
    // Set monthly budget if exists
    if (budgetProvider.monthlyBudget != null) {
      _monthlyBudgetController.text = budgetProvider.monthlyBudget!.amount.toStringAsFixed(0);
    }

    // Set category budgets if exist
    for (var category in _categories) {
      final controller = TextEditingController();
      final amount = budgetProvider.categoryBudgets[category];
      if (amount != null) {
        controller.text = amount.toStringAsFixed(0);
      }
      _categoryControllers[category] = controller;
    }
  }

  @override
  void dispose() {
    _monthlyBudgetController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveBudgets() async {
    setState(() {
      _isLoading = true;
    });

    final budgetProvider = context.read<BudgetProvider>();

    try {
      // Save monthly budget if set
      if (_monthlyBudgetController.text.isNotEmpty) {
        final amount = double.parse(_monthlyBudgetController.text);
        await budgetProvider.setMonthlyBudget(amount);
      }

      // Save category budgets
      for (var entry in _categoryControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          final amount = double.parse(entry.value.text);
          await budgetProvider.setCategoryBudget(entry.key, amount);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budgets saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save budgets: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(
        backgroundColor: AppColors.creamLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Budgets',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A1A1A),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Monthly Budget Section
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set your total spending limit for the month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBudgetField(
                  controller: _monthlyBudgetController,
                  hint: 'Enter monthly budget',
                ),

                const SizedBox(height: 40),

                // Category Budgets Section
                const Text(
                  'Category Budgets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set spending limits for each category',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),

                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBudgetField(
                          controller: _categoryControllers[category]!,
                          hint: 'Enter budget for $category',
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudgets,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Budgets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBudgetField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        prefixText: '\$ ',
        hintText: hint,
        filled: true,
        fillColor: AppColors.creamLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
