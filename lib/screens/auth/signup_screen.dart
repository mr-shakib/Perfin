import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_header.dart';
import 'widgets/signup_form_fields.dart';
import 'widgets/signup_buttons.dart';

/// Clean flat design signup screen
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
  void initState() {
    super.initState();
    
    // Add listeners to validate fields when they lose focus
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        _validateNameField();
      }
    });
    
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _validateEmailField();
      }
    });
    
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePasswordField();
      }
    });
    
    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        _validateConfirmPasswordField();
      }
    });
  }

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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _validateNameField() {
    final value = _nameController.text;
    if (value.trim().isEmpty) {
      _showErrorSnackbar('Name is required');
    } else if (value.trim().length < 2) {
      _showErrorSnackbar('Name must be at least 2 characters');
    }
  }

  void _validateEmailField() {
    final value = _emailController.text;
    if (value.trim().isEmpty) {
      _showErrorSnackbar('Email is required');
    } else if (!value.contains('@')) {
      _showErrorSnackbar('Please enter a valid email');
    }
  }

  void _validatePasswordField() {
    final value = _passwordController.text;
    if (value.isEmpty) {
      _showErrorSnackbar('Password is required');
    } else if (value.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
    }
  }

  void _validateConfirmPasswordField() {
    final value = _confirmPasswordController.text;
    if (value.isEmpty) {
      _showErrorSnackbar('Please confirm your password');
    } else if (value != _passwordController.text) {
      _showErrorSnackbar('Passwords do not match');
    }
  }

  bool _validateAllFields() {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.trim().isEmpty) {
      _showErrorSnackbar('Name is required');
      _nameFocusNode.requestFocus();
      return false;
    }
    if (name.trim().length < 2) {
      _showErrorSnackbar('Name must be at least 2 characters');
      _nameFocusNode.requestFocus();
      return false;
    }
    if (email.trim().isEmpty) {
      _showErrorSnackbar('Email is required');
      _emailFocusNode.requestFocus();
      return false;
    }
    if (!email.contains('@')) {
      _showErrorSnackbar('Please enter a valid email');
      _emailFocusNode.requestFocus();
      return false;
    }
    if (password.isEmpty) {
      _showErrorSnackbar('Password is required');
      _passwordFocusNode.requestFocus();
      return false;
    }
    if (password.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
      _passwordFocusNode.requestFocus();
      return false;
    }
    if (confirmPassword.isEmpty) {
      _showErrorSnackbar('Please confirm your password');
      _confirmPasswordFocusNode.requestFocus();
      return false;
    }
    if (confirmPassword != password) {
      _showErrorSnackbar('Passwords do not match');
      _confirmPasswordFocusNode.requestFocus();
      return false;
    }
    return true;
  }

  Future<void> _handleSignup() async {
    if (!_validateAllFields()) return;

    if (!_agreedToTerms) {
      _showErrorSnackbar('Please agree to the Terms & Conditions');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating account...'),
          duration: Duration(seconds: 30),
        ),
      );
    }
    
    await authProvider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    
    // Hide loading indicator
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/onboarding/goal');
    } else if (authProvider.errorMessage != null) {
      _showErrorSnackbar(authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.015),
                const AuthHeader(),
                SizedBox(height: size.height * 0.025),
                const AuthLogo(),
                SizedBox(height: size.height * 0.015),
                const AuthTitle(
                  title: 'Create Account',
                  subtitle: 'Sign up to start managing your finances',
                ),
                SizedBox(height: size.height * 0.025),
                SignupNameField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  nextFocusNode: _emailFocusNode,
                ),
                SizedBox(height: size.height * 0.015),
                SignupEmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  nextFocusNode: _passwordFocusNode,
                ),
                SizedBox(height: size.height * 0.015),
                SignupPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextFocusNode: _confirmPasswordFocusNode,
                ),
                SizedBox(height: size.height * 0.015),
                SignupConfirmPasswordField(
                  controller: _confirmPasswordController,
                  passwordController: _passwordController,
                  focusNode: _confirmPasswordFocusNode,
                  onSubmit: _handleSignup,
                ),
                SizedBox(height: size.height * 0.015),
                TermsCheckbox(
                  onChanged: (value) => setState(() => _agreedToTerms = value),
                ),
                SizedBox(height: size.height * 0.02),
                SignupButton(onPressed: _handleSignup),
                const Spacer(),
                const LoginLink(),
                SizedBox(height: size.height * 0.015),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
