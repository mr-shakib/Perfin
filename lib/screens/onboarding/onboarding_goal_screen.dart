import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

// Color constants
const Color _kScreenBackground = Color(0xFFFFF8DB);
const Color _kCardBackground = Color(0xFFFFFCE2);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kTextNavy = Color(0xFF303E50); // Same as button color
const Color _kTextMedium = Color(0xFF4A5568);
const Color _kCardBorder = Color(0xFFE5E5E5);

/// Screen 1: Savings Goal Selection
class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  String? _selectedGoal;

  final List<Map<String, String>> _goals = [
    {
      'id': 'starter',
      'title': 'Starter: Save 5% of income',
      'description': 'Perfect for beginners',
    },
    {
      'id': 'builder',
      'title': 'Builder: Save 10% of income',
      'description': 'Recommended',
    },
    {
      'id': 'aggressive',
      'title': 'Aggressive: Save 20% of income',
      'description': 'For serious savers',
    },
    {
      'id': 'custom',
      'title': 'Custom: Set my own amount',
      'description': 'Personalize your target',
    },
  ];

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
                      'Savings Target',
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
                      'What\'s your monthly savings goal?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _kTextNavy,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subheadline
                    Text(
                      'Choose a target to build your safety net.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Goal Options
                    ..._goals.map((goal) => _buildGoalCard(goal)),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, String> goal) {
    final isSelected = _selectedGoal == goal['id'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGoal = goal['id'];
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kCardBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _kButtonNavy : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _kButtonNavy : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _kTextNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedGoal != null
            ? () async {
                // Save the selection
                await context.read<OnboardingProvider>().setSavingsGoal(_selectedGoal!);
                // Navigate to next screen
                if (mounted) {
                  Navigator.pushNamed(context, '/onboarding/categories');
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kButtonNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kCardBorder,
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
