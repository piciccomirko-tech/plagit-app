import 'package:flutter/material.dart';

/// Shared preservation-first selection mode header.
///
/// Keeps selection state ownership in the screen while removing duplicated
/// top-bar layout code.
class AppSelectionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final String? title;
  final TextStyle titleStyle;
  final TextStyle actionStyle;

  const AppSelectionBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.title,
    this.titleStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1C24),
      letterSpacing: -0.2,
    ),
    this.actionStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Color(0xFF00B5B0),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final label = title ?? '$selectedCount selected';
    return Padding(
      padding: padding,
      child: Row(
        children: [
          leading ??
              GestureDetector(
                onTap: onCancel,
                behavior: HitTestBehavior.opaque,
                child: Text('Cancel', style: actionStyle),
              ),
          Expanded(
            child: Center(child: Text(label, style: titleStyle)),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
