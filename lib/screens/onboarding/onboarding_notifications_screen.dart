import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/notification_helper.dart';

// Color constants
const Color _kScreenBackground = Color(0xFFFFF8DB);
const Color _kCardBackground = Color(0xFFFFFCE2);
const Color _kAccentOrange = Color(0xFFFF7A4A);
const Color _kButtonNavy = Color(0xFF303E50);
const Color _kTextNavy = Color(0xFF303E50); // Same as button color
const Color _kTextMedium = Color(0xFF4A5568);

/// Screen 4: Notification Setup
class OnboardingNotificationsScreen extends StatefulWidget {
  const OnboardingNotificationsScreen({super.key});

  @override
  State<OnboardingNotificationsScreen> createState() => _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState extends State<OnboardingNotificationsScreen> {
  bool _dailyDigest = true;
  bool _billReminders = true;
  bool _budgetAlerts = true;
  bool _permissionRequested = false;
  final NotificationHelper _notificationHelper = NotificationHelper();

  Future<void> _requestNotificationPermission() async {
    if (_permissionRequested) return;
    
    try {
      // Initialize and request permissions
      await _notificationHelper.initialize();
      final granted = await _notificationHelper.requestPermissions();
      
      setState(() {
        _permissionRequested = true;
      });
      
      if (granted) {
        debugPrint('Notification permissions granted');
      } else {
        debugPrint('Notification permissions denied');
      }
    } catch (e) {
      // Permission denied or error - user can still continue
      debugPrint('Error requesting notification permissions: $e');
      setState(() {
        _permissionRequested = true;
      });
    }
  }

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
                      'Notifications',
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
                    
                    
                    const SizedBox(height: 20),
                    
                    // Headline
                    const Text(
                      'Never miss a bill or overspend',
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
                      'Customize how you want to be updated.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _kTextMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Lottie Animation
                    Lottie.asset(
                      'assets/json/notification.json',
                    ),
                    
                    
                    const SizedBox(height: 32),
                    
                    // Notification Settings
                    _buildNotificationToggle(
                      'Daily Spend Digest',
                      'Get a summary of your daily expenses',
                      _dailyDigest,
                      (value) => setState(() => _dailyDigest = value),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildNotificationToggle(
                      'Bill Due Reminders',
                      'Never miss a payment deadline',
                      _billReminders,
                      (value) => setState(() => _billReminders = value),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildNotificationToggle(
                      'Over-budget Alerts',
                      'Stay informed when you exceed limits',
                      _budgetAlerts,
                      (value) => setState(() => _budgetAlerts = value),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Finish Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildFinishButton(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNotificationToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kTextNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _kTextMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _kAccentOrange, // Orange thumb
            activeTrackColor: _kButtonNavy, // Navy track background
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // Ensure notification permission is requested
          await _requestNotificationPermission();
          
          // Save the notification preferences
          await context.read<OnboardingProvider>().setNotificationPreferences(
            dailyDigest: _dailyDigest,
            billReminders: _billReminders,
            budgetAlerts: _budgetAlerts,
          );
          
          // Navigate to next screen
          if (mounted) {
            Navigator.pushNamed(context, '/onboarding/weekly-review');
          }
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
