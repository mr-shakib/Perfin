import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/goal_provider.dart';

/// Data export dialog - Clean Minimal Design
class DataExportDialog extends StatefulWidget {
  final String userId;

  const DataExportDialog({
    super.key,
    required this.userId,
  });

  @override
  State<DataExportDialog> createState() => _DataExportDialogState();
}

class _DataExportDialogState extends State<DataExportDialog> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Export Data',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
      content: const Text(
        'Export all your financial data as a CSV file. This includes transactions, budgets, and goals.',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF666666),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: _isExporting ? null : _handleExport,
          child: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Export',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final budgetProvider = Provider.of<BudgetProvider>(
        context,
        listen: false,
      );
      final goalProvider = Provider.of<GoalProvider>(
        context,
        listen: false,
      );

      final csvContent = _generateCSV(
        transactionProvider,
        budgetProvider,
        goalProvider,
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'perfin_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);

      // Copy to clipboard as well
      await Clipboard.setData(ClipboardData(text: csvContent));

      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00C853), size: 28),
                SizedBox(width: 12),
                Text(
                  'Export Successful',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your data has been exported to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    file.path,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The data has also been copied to your clipboard.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  String _generateCSV(
    TransactionProvider transactionProvider,
    BudgetProvider budgetProvider,
    GoalProvider goalProvider,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('TRANSACTIONS');
    buffer.writeln('ID,Date,Amount,Category,Type,Notes');
    for (final transaction in transactionProvider.transactions) {
      buffer.writeln(
        '${_escapeCsv(transaction.id)},'
        '${transaction.date.toIso8601String()},'
        '${transaction.amount},'
        '${_escapeCsv(transaction.category)},'
        '${transaction.type.name},'
        '${_escapeCsv(transaction.notes ?? '')}',
      );
    }

    buffer.writeln();
    buffer.writeln('BUDGETS');
    buffer.writeln('Category,Monthly Limit');
    for (final entry in budgetProvider.categoryBudgets.entries) {
      buffer.writeln('${_escapeCsv(entry.key)},${entry.value}');
    }

    buffer.writeln();
    buffer.writeln('GOALS');
    buffer.writeln('ID,Name,Target Amount,Current Amount,Target Date,Status');
    for (final goal in goalProvider.goals) {
      buffer.writeln(
        '${_escapeCsv(goal.id)},'
        '${_escapeCsv(goal.name)},'
        '${goal.targetAmount},'
        '${goal.currentAmount},'
        '${goal.targetDate.toIso8601String()},'
        '${goal.isCompleted ? 'Completed' : 'Active'}',
      );
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
