import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form_fields.dart';
import 'widgets/login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final onboardingDone = context.read<OnboardingProvider>().isCompleted;
      Navigator.pushReplacementNamed(
        context,
        onboardingDone ? '/dashboard' : '/onboarding/goal',
      );
    } else if (authProvider.errorMessage != null) {
      _showError(authProvider.errorMessage!);
    }
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
                const SizedBox(height: 32),
                const AuthLogo(),
                const SizedBox(height: 24),
                const AuthTitle(
                  title: 'Welcome Back',
                  subtitle: 'Login to manage your finances',
                ),
                const SizedBox(height: 32),
                LoginEmailField(controller: _emailController),
                const SizedBox(height: 16),
                LoginPasswordField(
                  controller: _passwordController,
                  onSubmit: _handleLogin,
                ),
                const SizedBox(height: 12),
                const RememberMeAndForgot(),
                const SizedBox(height: 28),
                LoginButton(onPressed: _handleLogin),
                const SizedBox(height: 32),
                const SignUpLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
