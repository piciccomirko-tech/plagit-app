import 'package:flutter/material.dart';

/// Shows a flag emoji via Text(). Mirrors FlagTextView.swift.
class FlagText extends StatelessWidget {
  final String flag;
  final double size;

  const FlagText(this.flag, {super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Text(flag, style: TextStyle(fontSize: size));
  }
}

/// Guaranteed-visible country badge: shows 2-letter ISO code in a colored rounded rect.
/// Mirrors CountryBadge from FlagTextView.swift.
class CountryBadge extends StatelessWidget {
  final String code;
  final String? flag;

  const CountryBadge({super.key, required this.code, this.flag});

  static String flagEmoji(String code) {
    if (code.length != 2) return '';
    final c = code.toUpperCase();
    final first = 0x1F1E6 + c.codeUnitAt(0) - 0x41;
    final second = 0x1F1E6 + c.codeUnitAt(1) - 0x41;
    return String.fromCharCodes([first, second]);
  }

  Color _colorForCode(String code) {
    final hash = code.codeUnits.fold<int>(0, (acc, v) => acc + v);
    const colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.indigo, Colors.pink,
      Color(0xFF3EB489), Colors.cyan,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForCode(code);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        code.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
