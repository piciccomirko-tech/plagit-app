import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

/// Reusable avatar — shows a decoded base64 photo or gradient initials fallback.
/// Mirrors ProfileAvatarView.swift.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double hue;
  final double size;
  final bool verified;
  final String? countryCode;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.initials,
    this.hue = 0.5,
    this.size = 44,
    this.verified = false,
    this.countryCode,
  });

  Uint8List? _decodePhoto() {
    final url = photoUrl;
    if (url == null || url.isEmpty) return null;
    String base64Str = url;
    final idx = url.indexOf(';base64,');
    if (idx != -1) {
      base64Str = url.substring(idx + 8);
    }
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  String _flagEmoji(String code) {
    if (code.length != 2) return '';
    final c = code.toUpperCase();
    final first = 0x1F1E6 + c.codeUnitAt(0) - 0x41;
    final second = 0x1F1E6 + c.codeUnitAt(1) - 0x41;
    return String.fromCharCodes([first, second]);
  }

  @override
  Widget build(BuildContext context) {
    final decoded = _decodePhoto();
    final hsl1 = HSLColor.fromAHSL(1.0, hue * 360, 0.40, 0.92);
    final hsl2 = HSLColor.fromAHSL(1.0, hue * 360, 0.55, 0.78);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main circle
          if (decoded != null)
            ClipOval(
              child: Image.memory(
                decoded,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsCircle(hsl1, hsl2),
              ),
            )
          else
            _initialsCircle(hsl1, hsl2),

          // Verified badge — bottom-right
          if (verified)
            Positioned(
              right: -(size * 0.04),
              bottom: -(size * 0.04),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(1),
                child: Icon(
                  Icons.verified,
                  size: size * 0.22,
                  color: AppColors.teal,
                ),
              ),
            ),

          // Country flag — bottom-left
          if (countryCode != null && countryCode!.isNotEmpty)
            Positioned(
              left: -(size * 0.04),
              bottom: -(size * 0.04),
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _flagEmoji(countryCode!),
                  style: TextStyle(fontSize: size * 0.18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initialsCircle(HSLColor c1, HSLColor c2) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1.toColor(), c2.toColor()],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
