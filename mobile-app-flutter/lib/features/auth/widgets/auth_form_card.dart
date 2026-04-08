import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

/// Rounded card container used for auth form fields.
/// Mirrors the SwiftUI `.plagitCardBackground` rounded card pattern.
class AuthFormCard extends StatelessWidget {
  final List<Widget> children;
  const AuthFormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(const Divider(height: 1, color: AppColors.divider));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: separated,
        ),
      ),
    );
  }
}

/// Single row inside an AuthFormCard — icon + text field.
class AuthFormField extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  const AuthFormField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: textInputAction ?? TextInputAction.next,
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

/// Eye toggle button for password fields.
class PasswordToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;
  const PasswordToggle({super.key, required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: AppColors.tertiary,
      ),
    );
  }
}

/// Error banner shown above buttons when auth fails.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.urgent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.urgent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppColors.urgent),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
