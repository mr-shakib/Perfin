import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Color constants
const Color _kScreenBackground = Color(0xFFFFF8DB);
const Color _kCardBackground = Color(0xFFFFFCE2);
const Color _kAccentOrange = Color(0xFFFF7A4A);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kTextNavy = Color(0xFF303E50); // Same as button color
const Color _kTextMedium = Color(0xFF4A5568);

/// Screen 3: Benefits/Value Proposition
class OnboardingBenefitsScreen extends StatelessWidget {
  const OnboardingBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kScreenBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: _kTextNavy,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Why PerFin?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _kTextNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Hero Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Headline
                    const Text(
                      'The path to financial freedom',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _kTextNavy,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Benefit Cards
                    _buildBenefitCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Track Effortlessly',
                      description: 'Connect your accounts for automatic expense categorization.',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildBenefitCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Spot Trends',
                      description: 'Visualize your spending habits to find places to save.',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildBenefitCard(
                      icon: Icons.shield_rounded,
                      title: 'Build Wealth',
                      description: 'Set goals and watch your net worth grow over time.',
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContinueButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kAccentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: _kAccentOrange,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kTextNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _kTextMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/onboarding/notifications');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _kButtonNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Continue',
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
