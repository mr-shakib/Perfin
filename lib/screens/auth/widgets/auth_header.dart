import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  final double? size;

  const AuthLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120 ;
    return Center(
      child: Image.asset(
        'assets/images/login_moscot.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
