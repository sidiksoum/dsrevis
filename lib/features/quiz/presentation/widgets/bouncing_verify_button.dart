import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BouncingVerifyButton extends StatefulWidget {
  const BouncingVerifyButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  @override
  State<BouncingVerifyButton> createState() => _BouncingVerifyButtonState();
}

class _BouncingVerifyButtonState extends State<BouncingVerifyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = isEnabled ? Offset(0, -6 * _controller.value) : Offset.zero;
        return Transform.translate(
          offset: offset,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                if (isEnabled)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3 * _controller.value + 0.15),
                    blurRadius: 10 + 4 * _controller.value,
                    offset: Offset(0, 4 + 4 * _controller.value),
                  )
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon, size: 22),
              label: Text(widget.label),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        );
      },
    );
  }
}
