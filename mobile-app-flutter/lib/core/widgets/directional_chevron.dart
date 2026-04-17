import 'package:flutter/material.dart';

/// Back-navigation chevron that auto-mirrors in RTL (arabic).
/// Renders `chevron_left` in LTR, `chevron_right` in RTL.
class BackChevron extends StatelessWidget {
  final double size;
  final Color? color;
  const BackChevron({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      rtl ? Icons.chevron_right : Icons.chevron_left,
      size: size,
      color: color,
    );
  }
}

/// Forward/disclosure chevron that auto-mirrors in RTL (arabic).
/// Renders `chevron_right` in LTR, `chevron_left` in RTL.
class ForwardChevron extends StatelessWidget {
  final double size;
  final Color? color;
  const ForwardChevron({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      rtl ? Icons.chevron_left : Icons.chevron_right,
      size: size,
      color: color,
    );
  }
}
