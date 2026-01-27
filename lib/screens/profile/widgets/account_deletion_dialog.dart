import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';

/// Account deletion dialog - Clean Minimal Design
class AccountDeletionDialog extends StatefulWidget {
  final String userId;
  final AuthProvider authProvider;

  const AccountDeletionDialog({
    super.key,
    required this.userId,
    required this.authProvider,
  });

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final _confirmationController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3B30)),
          SizedBox(width: 8),
          Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 20,
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
            'This action cannot be undone. All your data will be permanently deleted:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '• All transactions\n• All budgets\n• All goals\n• Account information',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Type DELETE to confirm:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: InputDecoration(
              hintText: 'DELETE',
              filled: true,
              fillColor: AppColors.creamLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F0F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F0F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1A1A1A),
                  width: 2,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _handleDelete,
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    if (_confirmationController.text.trim() != 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type DELETE to confirm'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('transactions').delete().eq('user_id', widget.userId);
      await supabase.from('budgets').delete().eq('user_id', widget.userId);
      await supabase.from('goals').delete().eq('user_id', widget.userId);
      await supabase.from('chat_messages').delete().eq('user_id', widget.userId);
      await supabase.from('notification_preferences').delete().eq('user_id', widget.userId);
      await supabase.from('profiles').delete().eq('user_id', widget.userId);

      await widget.authProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }
}
