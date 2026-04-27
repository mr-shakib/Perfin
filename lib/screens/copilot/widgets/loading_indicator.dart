import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI avatar
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(index: 0, controller: _controller),
              const SizedBox(width: 5),
              _Dot(index: 1, controller: _controller),
              const SizedBox(width: 5),
              _Dot(index: 2, controller: _controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  const _Dot({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final delay = index * 0.25;
        final v = ((controller.value - delay) % 1.0);
        final t = v < 0.4 ? v / 0.4 : v < 0.7 ? 1.0 : (1.0 - (v - 0.7) / 0.3);
        final offset = -6.0 * t.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Color.lerp(
                AppColors.primaryLight,
                AppColors.secondary,
                t.clamp(0.0, 1.0),
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
