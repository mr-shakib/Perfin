import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_header.dart';
import 'widgets/signup_form_fields.dart';
import 'widgets/signup_buttons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Check your email',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'We sent a confirmation link to $email.\n\nTap the link in the email, then come back and log in.',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showError('Please agree to the Terms & Conditions');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    await authProvider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/onboarding/goal');
    } else if (authProvider.needsEmailConfirmation) {
      _showEmailConfirmationDialog(_emailController.text.trim());
    } else if (authProvider.errorMessage != null) {
      _showError(authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const AuthHeader(),
                const SizedBox(height: 24),
                const AuthLogo(size: 90),
                const SizedBox(height: 16),
                const AuthTitle(
                  title: 'Create Account',
                  subtitle: 'Sign up to start managing your finances',
                ),
                const SizedBox(height: 28),
                SignupNameField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  nextFocusNode: _emailFocusNode,
                ),
                const SizedBox(height: 14),
                SignupEmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  nextFocusNode: _passwordFocusNode,
                ),
                const SizedBox(height: 14),
                SignupPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextFocusNode: _confirmPasswordFocusNode,
                ),
                const SizedBox(height: 14),
                SignupConfirmPasswordField(
                  controller: _confirmPasswordController,
                  passwordController: _passwordController,
                  focusNode: _confirmPasswordFocusNode,
                  onSubmit: _handleSignup,
                ),
                const SizedBox(height: 16),
                TermsCheckbox(
                  onChanged: (value) => setState(() => _agreedToTerms = value),
                ),
                const SizedBox(height: 24),
                SignupButton(onPressed: _handleSignup),
                const SizedBox(height: 24),
                const LoginLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
