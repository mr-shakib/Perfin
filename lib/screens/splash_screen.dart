import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

// Color constants for splash/onboarding screen
const Color _kBackgroundOrange = Color(0xFFFF7A4A);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kCardCream = Color(0xFFFFF4D7);
const Color _kTextDarkNavy = Color(0xFF1A2B4A);
const Color _kTextMediumGrey = Color(0xFF2D3748);
const Color _kTextLightGrey = Color(0xFF4A5568);

/// Combined splash and onboarding screen with seamless transition
/// Shows logo first, then smoothly reveals onboarding content
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Logo animations (0.0 - 0.4)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    // Card slide animation (0.4 - 0.8)
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    // Content fade animation (0.6 - 1.0)
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start initialization
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start logo animation immediately
    _animationController.forward();
    
    // Wait a bit for providers to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();
    
    try {
      // Ensure providers are loaded
      await Future.wait([
        authProvider.restoreSession(),
        onboardingProvider.loadPreferences(),
      ]);
    } catch (e) {
      // If there's a network error, continue anyway
      debugPrint('Error during initialization: $e');
    }
    
    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    // Check authentication and onboarding status
    final isAuthenticated = authProvider.isAuthenticated;
    final hasCompletedOnboarding = onboardingProvider.isCompleted;

    if (isAuthenticated) {
      // User is authenticated, go to dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (!hasCompletedOnboarding) {
      // User hasn't completed onboarding, show onboarding content
      setState(() {
        _showOnboarding = true;
      });
    } else {
      // User completed onboarding but not logged in, go to login
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundOrange,
      body: Stack(
        children: [
          // Logo - always visible
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Onboarding card - slides up when ready
          if (_showOnboarding)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SlideTransition(
                  position: _cardSlideAnimation,
                  child: FadeTransition(
                    opacity: _cardFadeAnimation,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildContentCard(context),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Bottom content card with moon-shaped curved top edge
  Widget _buildContentCard(BuildContext context) {
    return ClipPath(
      clipper: _MoonCurveClipper(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.52, // Increased from 0.45
        ),
        decoration: const BoxDecoration(
          color: _kCardCream,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 100.0, 32.0, 24.0), // Increased top padding
          child: FadeTransition(
            opacity: _contentFadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text content
                Column(
                  children: [
                    // Headline
                    const Text(
                      'Hey, I\'m PerFin!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _kTextDarkNavy,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Sub-headline
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _kTextMediumGrey,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'I\'m here '),
                          TextSpan(
                            text: 'to brighten',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' your financial future'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Body text
                    const Text(
                      'Let\'s start your journey to financial wellness with smart tracking and insights that help you stay on top of your money.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: _kTextLightGrey,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 72),
                
                // CTA Button
                _buildGetStartedButton(context),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  /// Full-width pill-shaped CTA button
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/onboarding/goal');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _kButtonNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
        ),
        child: const Text(
          'Let\'s get started',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}


/// Custom clipper for moon-shaped curve at the top of the card
class _MoonCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(0, 60);
    
    // Create a concave (moon-shaped) curve at the top
    path.quadraticBezierTo(
      size.width / 2, // Control point X (center)
      0,              // Control point Y (top)
      size.width,     // End point X (right)
      60,             // End point Y
    );
    
    // Draw down the right side
    path.lineTo(size.width, size.height);
    
    // Draw across the bottom
    path.lineTo(0, size.height);
    
    // Close the path back to start
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
