import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

/// Official Plagit logo widget. Used in splash, entry, and auth screens.
class PlagitLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool withShadow;

  const PlagitLogo({
    super.key,
    this.size = 80,
    this.borderRadius = 20,
    this.withShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/branding/plagit_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
