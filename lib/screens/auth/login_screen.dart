import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form_fields.dart';
import 'widgets/login_buttons.dart';


/// Clean flat design login screen
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
    
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging in...'),
          duration: Duration(seconds: 30),
        ),
      );
    }
    
    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      
      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (authProvider.errorMessage != null) {
        _showErrorWithOfflineOption(authProvider.errorMessage!);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Check if it's a network error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        _showOfflineDialog();
      } else {
        _showErrorWithOfflineOption(e.toString());
      }
    }
  }

  void _showErrorWithOfflineOption(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Continue Offline',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
    );
  }

  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'No Internet Connection',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Unable to connect to the server. You can continue using the app offline with limited features, or check your internet connection and try again.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: const Text(
              'Continue Offline',
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.02),
                const AuthHeader(),
                SizedBox(height: size.height * 0.04),
                const AuthLogo(),
                SizedBox(height: size.height * 0.025),
                const AuthTitle(
                  title: 'Welcome Back',
                  subtitle: 'Login to manage your finances',
                ),
                SizedBox(height: size.height * 0.04),
                LoginEmailField(controller: _emailController),
                SizedBox(height: size.height * 0.02),
                LoginPasswordField(
                  controller: _passwordController,
                  onSubmit: _handleLogin,
                ),
                SizedBox(height: size.height * 0.02),
                const RememberMeAndForgot(),
                SizedBox(height: size.height * 0.03),
                LoginButton(onPressed: _handleLogin),
                SizedBox(height: size.height * 0.025),
                const LoginDivider(),
                SizedBox(height: size.height * 0.025),
                const SocialLoginButtons(),
                const Spacer(),
                const SignUpLink(),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
