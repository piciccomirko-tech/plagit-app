import 'package:flutter/material.dart';

/// Small reusable header action tap target.
///
/// Designed to preserve existing screen output by letting callers provide
/// the exact icon widget they already use, while standardizing tap handling.
class HeaderActionIcon extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;

  const HeaderActionIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: icon,
    );
  }
}
