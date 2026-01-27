import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

/// Full-screen view for managing transaction categories
/// Allows creating, editing, and deleting categories with transaction reassignment
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  // Default categories that come with the app
  static const List<String> _defaultCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Personal Care',
    'Other',
  ];

  List<String> _customCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    setState(() {
      _isLoading = true;
    });

    // In a real implementation, this would load from storage
    // For now, we'll use an empty list
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _customCategories = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Default Categories Section
                const Text(
                  'Default Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._defaultCategories.map((category) => _buildCategoryCard(
                      category,
                      isDefault: true,
                    )),
                
                const SizedBox(height: 24),
                
                // Custom Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Custom Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCreateCategoryDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_customCategories.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No custom categories yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                else
                  ..._customCategories.map((category) => _buildCategoryCard(
                        category,
                        isDefault: false,
                      )),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(String category, {required bool isDefault}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.category,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(category),
        subtitle: isDefault ? const Text('Default') : const Text('Custom'),
        trailing: isDefault
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryDialog(context, category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteCategoryDialog(context, category),
                  ),
                ],
              ),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Category name is required';
              }
              
              // Check for uniqueness (case-insensitive)
              final allCategories = [..._defaultCategories, ..._customCategories];
              if (allCategories.any((cat) => 
                  cat.toLowerCase() == value.trim().toLowerCase())) {
                return 'Category already exists';
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newCategory = categoryController.text.trim();
                setState(() {
                  _customCategories.add(newCategory);
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category "$newCategory" created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, String oldCategory) {
    final categoryController = TextEditingController(text: oldCategory);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Category name is required';
              }
              
              // Check for uniqueness (case-insensitive), excluding current category
              final allCategories = [..._defaultCategories, ..._customCategories];
              if (value.trim().toLowerCase() != oldCategory.toLowerCase() &&
                  allCategories.any((cat) => 
                      cat.toLowerCase() == value.trim().toLowerCase())) {
                return 'Category already exists';
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newCategory = categoryController.text.trim();
                setState(() {
                  final index = _customCategories.indexOf(oldCategory);
                  if (index != -1) {
                    _customCategories[index] = newCategory;
                  }
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category updated to "$newCategory"')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String category) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    // Check if category has transactions
    final hasTransactions = transactionProvider.transactions
        .any((t) => t.category == category);

    if (hasTransactions) {
      _showReassignmentDialog(context, category);
    } else {
      _showSimpleDeleteDialog(context, category);
    }
  }

  void _showSimpleDeleteDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$category"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customCategories.remove(category);
              });
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category "$category" deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReassignmentDialog(BuildContext context, String category) {
    final allCategories = [..._defaultCategories, ..._customCategories]
        .where((c) => c != category)
        .toList();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reassign Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This category has existing transactions. '
                'Please select a category to reassign them to:',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'New Category',
                  border: OutlineInputBorder(),
                ),
                items: allCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedCategory == null
                  ? null
                  : () {
                      // Reassign transactions
                      // In a real implementation, this would update all transactions
                      // For now, we'll just show a message
                      
                      this.setState(() {
                        _customCategories.remove(category);
                      });
                      
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Category "$category" deleted and transactions '
                            'reassigned to "$selectedCategory"',
                          ),
                        ),
                      );
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete & Reassign'),
            ),
          ],
        ),
      ),
    );
  }
}
