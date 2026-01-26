import 'package:flutter/material.dart';
import 'screens/notification_test_screen.dart';

/// Standalone notification test app
/// Run this with: flutter run -t lib/notification_test_main.dart
void main() {
  runApp(const NotificationTestApp());
}

class NotificationTestApp extends StatelessWidget {
  const NotificationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfin Notification Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationTestScreen(),
    );
  }
}
