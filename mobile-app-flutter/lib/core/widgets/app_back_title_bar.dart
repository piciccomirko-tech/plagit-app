import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared preservation-first header: back button, centered title, trailing.
///
/// The API is intentionally small so screens can keep their current
/// structure and visuals while removing duplicated header row code.
class AppBackTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color backBackgroundColor;
  final BorderRadius backBorderRadius;
  final Widget? backIcon;
  final TextStyle titleStyle;
  final double leadingSize;
  final double trailingMinWidth;

  const AppBackTitleBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 12),
    this.backBackgroundColor = const Color(0xFFF9FAFB),
    this.backBorderRadius = const BorderRadius.all(Radius.circular(18)),
    this.backIcon,
    this.titleStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1C1C1E),
      letterSpacing: -0.2,
    ),
    this.leadingSize = 36,
    this.trailingMinWidth = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: leadingSize,
              height: leadingSize,
              decoration: BoxDecoration(
                color: backBackgroundColor,
                borderRadius: backBorderRadius,
              ),
              child: Center(
                child:
                    backIcon ??
                    const Icon(
                      CupertinoIcons.chevron_left,
                      size: 16,
                      color: Color(0xFF1A1C24),
                    ),
              ),
            ),
          ),
          Expanded(
            child: Center(child: Text(title, style: titleStyle)),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: trailingMinWidth),
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ?? const SizedBox(width: 36, height: 36),
            ),
          ),
        ],
      ),
    );
  }
}
