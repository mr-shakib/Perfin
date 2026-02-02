import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/currency_provider.dart';

/// Form for creating new goals
/// Requirements: 9.2-9.6
class CreateGoalForm extends StatefulWidget {
  const CreateGoalForm({super.key});

  @override
  State<CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends State<CreateGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _linkedCategoryId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A1A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target date'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = _currentAmountController.text.isEmpty
          ? 0.0
          : double.parse(_currentAmountController.text);

      await goalProvider.createGoal(
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        targetDate: _selectedDate!,
        currentAmount: currentAmount,
        linkedCategoryId: _linkedCategoryId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Goal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: const Color(0xFF666666),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Goal name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Goal Name *',
                        hintText: 'e.g., Emergency Fund, Vacation',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 16),

                    // Target amount field
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, _) => TextFormField(
                        controller: _targetAmountController,
                        decoration: InputDecoration(
                          labelText: 'Target Amount *',
                          hintText: '0.00',
                          prefixText: '${currencyProvider.currentCurrency.symbol} ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                        ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a target amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid amount';
                          }
                          if (amount <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Current amount field (optional)
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, _) => TextFormField(
                        controller: _currentAmountController,
                        decoration: InputDecoration(
                          labelText: 'Current Amount (Optional)',
                          hintText: '0.00',
                          prefixText: '${currencyProvider.currentCurrency.symbol} ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                        ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Please enter a valid amount';
                            }
                            if (amount < 0) {
                              return 'Amount cannot be negative';
                            }
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Target date field
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Target Date *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select date'
                              : DateFormat('MMM d, yyyy').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? const Color(0xFF999999)
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: const Color(0xFFCCCCCC),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Create Goal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
