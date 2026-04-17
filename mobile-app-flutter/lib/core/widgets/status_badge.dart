import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;
  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: large ? 14 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static (Color, Color) _colors(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return (const Color(0xFF707580), const Color(0xFF707580).withValues(alpha: 0.10));
      case 'under review':
        return (const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.10));
      case 'shortlisted':
        return (const Color(0xFF8B5CF6), const Color(0xFF8B5CF6).withValues(alpha: 0.10));
      case 'interview scheduled':
      case 'confirmed':
        return (const Color(0xFF2BB8B0), const Color(0xFF2BB8B0).withValues(alpha: 0.10));
      case 'invited':
        return (const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.10));
      case 'rejected':
        return (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.10));
      case 'withdrawn':
        return (const Color(0xFF707580), const Color(0xFF707580).withValues(alpha: 0.10));
      case 'hired':
        return (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.10));
      case 'active':
        return (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.10));
      case 'draft':
        return (const Color(0xFF707580), const Color(0xFF707580).withValues(alpha: 0.10));
      case 'paused':
        return (const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.10));
      case 'closed':
        return (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.10));
      case 'interview':
        return (const Color(0xFF2BB8B0), const Color(0xFF2BB8B0).withValues(alpha: 0.10));
      default:
        return (const Color(0xFF707580), const Color(0xFF707580).withValues(alpha: 0.10));
    }
  }
}
