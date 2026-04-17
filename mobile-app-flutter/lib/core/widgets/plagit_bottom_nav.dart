import 'package:flutter/material.dart';

/// Shared bottom navigation bar — premium, minimal, consistent across all roles.
class PlagitBottomNav extends StatelessWidget {
  final List<Widget> children;

  const PlagitBottomNav({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.33),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Row(children: children),
        ),
      ),
    );
  }
}
