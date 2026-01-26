import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Color constants
const Color _kScreenBackground = Color(0xFFFFF8DB);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kTextNavy = Color(0xFF303E50); // Same as button color
const Color _kTextMedium = Color(0xFF4A5568);
const Color _kChipUnselected = Color(0xFFFFFCE2);

/// Screen 2: Category Selection
class OnboardingCategoriesScreen extends StatefulWidget {
  const OnboardingCategoriesScreen({super.key});

  @override
  State<OnboardingCategoriesScreen> createState() => _OnboardingCategoriesScreenState();
}

class _OnboardingCategoriesScreenState extends State<OnboardingCategoriesScreen> {
  final Set<String> _selectedCategories = {};

  final List<Map<String, String>> _categories = [
    {'id': 'rent', 'label': '🏠 Rent/Mortgage'},
    {'id': 'dining', 'label': '🍔 Dining Out'},
    {'id': 'groceries', 'label': '🛒 Groceries'},
    {'id': 'transport', 'label': '🚌 Transport'},
    {'id': 'health', 'label': '💊 Health'},
    {'id': 'entertainment', 'label': '🎬 Entertainment'},
    {'id': 'travel', 'label': '✈️ Travel'},
    {'id': 'debt', 'label': '💳 Debt Payoff'},
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
                      'Categories',
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
                      'Where does your money go?',
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
                      'Select the expenses you want to track closely.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Category Chips Grid
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _categories.map((category) {
                        return _buildCategoryChip(category);
                      }).toList(),
                    ),
                    
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

  Widget _buildCategoryChip(Map<String, String> category) {
    final isSelected = _selectedCategories.contains(category['id']);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(category['id']);
          } else {
            _selectedCategories.add(category['id']!);
          }
        });
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kButtonNavy : _kChipUnselected,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          category['label']!,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _kTextNavy,
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
        onPressed: _selectedCategories.isNotEmpty
            ? () {
                Navigator.pushNamed(context, '/onboarding/benefits');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kButtonNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E5E5),
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
