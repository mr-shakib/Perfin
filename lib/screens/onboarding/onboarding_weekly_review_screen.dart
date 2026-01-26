import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

// Color constants
const Color _kScreenBackground = Color(0xFFFFF8DB);
const Color _kCardBackground = Color(0xFFFFFCE2);
const Color _kAccentOrange = Color(0xFFFF7A4A);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kTextNavy = Color(0xFF303E50);
const Color _kTextMedium = Color(0xFF4A5568);

/// Screen 5: Weekly Review Day Selector
class OnboardingWeeklyReviewScreen extends StatefulWidget {
  const OnboardingWeeklyReviewScreen({super.key});

  @override
  State<OnboardingWeeklyReviewScreen> createState() => _OnboardingWeeklyReviewScreenState();
}

class _OnboardingWeeklyReviewScreenState extends State<OnboardingWeeklyReviewScreen> {
  int _selectedDay = 6; // Default to Sunday (index 6)

  final List<Map<String, String>> _days = [
    {'label': 'Mo', 'full': 'Monday'},
    {'label': 'Tu', 'full': 'Tuesday'},
    {'label': 'We', 'full': 'Wednesday'},
    {'label': 'Th', 'full': 'Thursday'},
    {'label': 'Fr', 'full': 'Friday'},
    {'label': 'Sa', 'full': 'Saturday'},
    {'label': 'Su', 'full': 'Sunday'},
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
                      'Weekly Review',
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
                      'Build your "Money Date"',
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
                      'Consistency is the secret to wealth. Pick a day to review your finances.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Day Selector
                    _buildDaySelector(),
                    
                    const SizedBox(height: 16),
                    
                    // Caption
                    Text(
                      'We will remind you to check your balances on this day.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Stat Card
                    _buildStatCard(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Next Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_days.length, (index) {
        final isSelected = _selectedDay == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = index;
            });
          },
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _kAccentOrange : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _kAccentOrange : _kTextMedium.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          _days[index]['label']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kTextMedium.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _days[index]['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _kTextNavy : _kTextMedium.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fire Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kAccentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text content
          Expanded(
            child: Text(
              'Users who review their spending once a week save 20% more annually.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kTextNavy,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final onboardingProvider = context.read<OnboardingProvider>();
          
          // Save the weekly review day
          await onboardingProvider.setWeeklyReviewDay(_selectedDay);
          // Mark onboarding as completed
          await onboardingProvider.completeOnboarding();
          // Navigate to login
          navigator.pushReplacementNamed('/login');
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
          'Get Started',
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
