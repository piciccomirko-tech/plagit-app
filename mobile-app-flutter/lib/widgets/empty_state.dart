import 'package:flutter/material.dart';
import 'package:plagit/core/widgets/empty_state.dart' as core;

/// Legacy compatibility wrapper.
///
/// New call sites should import the canonical core/widgets implementation.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return core.EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: action,
    );
  }
}
