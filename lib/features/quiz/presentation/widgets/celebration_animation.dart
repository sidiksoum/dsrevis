import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';

class CelebrationAnimation extends StatelessWidget {
  const CelebrationAnimation({super.key, required this.isSuccess});
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      return Lottie.network(
        'https://assets3.lottiefiles.com/packages/lf20_touoh4ky.json',
        width: 220,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events_rounded, size: 80, color: AppColors.success),
        ),
      );
    } else {
      return Lottie.network(
        'https://assets9.lottiefiles.com/packages/lf20_5n8ybbpa.json',
        width: 220,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events_rounded, size: 80, color: AppColors.primary),
        ),
      );
    }
  }
}
