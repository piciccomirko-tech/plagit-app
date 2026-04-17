import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plagit/core/widgets/professional_avatar.dart';

const _tealMain = Color(0xFF00B5B0);

/// Single source of truth for profile imagery across the app.
///
/// Plagit is a hospitality hiring platform — profile photos must read like
/// professional headshots, not casual social-media avatars. This widget:
///
///   • Renders a real photo when `photoUrl` (network, asset, or base64) is
///     present, with **face-centered framing** (`Alignment.topCenter` +
///     `BoxFit.cover`) so headshots always show the head and shoulders.
///   • Falls back to a clean two-stop gradient circle with bold initials
///     when no photo is available — same hue derivation everywhere so a
///     given person's fallback colour is stable across screens.
///   • Supports an optional verified seal badge in the bottom-right corner
///     and an optional thin white ring (used on dark hero cards).
///
/// Use the `square` variant for a slightly more "ID card / passport photo"
/// feel — same image, rounded-square frame instead of full circle.
class ProfilePhoto extends StatelessWidget {
  /// Network URL, local asset path, or `data:image/...;base64,...` string.
  final String? photoUrl;

  /// Two-character initials shown when there is no photo.
  final String initials;

  /// Diameter (or side length, for `square` mode).
  final double size;

  /// When true, renders as a rounded square instead of a full circle —
  /// reads more like a passport / ID photo. Defaults to circle.
  final bool square;

  /// Optional small verified seal in the bottom-right corner.
  final bool verified;

  /// Optional white ring around the photo — used on dark backgrounds
  /// (hero cards, dark sheets) so the photo doesn't bleed into the bg.
  final bool ring;

  /// Override the seed used to generate the fallback gradient hue. Defaults
  /// to a hash of `initials` so the same name always gets the same colour.
  final String? hueSeed;

  const ProfilePhoto({
    super.key,
    required this.initials,
    this.photoUrl,
    this.size = 44,
    this.square = false,
    this.verified = false,
    this.ring = false,
    this.hueSeed,
  });

  /// Returns a stable hue (0-360) seeded from the seed string.
  double get _hue => ((hueSeed ?? initials).hashCode % 360).abs().toDouble();

  /// Builds the actual image provider, handling all 3 supported sources.
  ImageProvider? _resolveImage() {
    final src = photoUrl;
    if (src == null || src.isEmpty) return null;
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return NetworkImage(src);
    }
    if (src.startsWith('data:image')) {
      try {
        final base64Part = src.split(',').last;
        return MemoryImage(base64Decode(base64Part));
      } catch (_) {
        return null;
      }
    }
    return AssetImage(src);
  }

  BorderRadius get _radius =>
      square ? BorderRadius.circular(size * 0.22) : BorderRadius.circular(size / 2);

  @override
  Widget build(BuildContext context) {
    // ── Professional avatar fallback ──
    // If `photoUrl` carries an `avatar:role:gender:variant` identifier
    // (i.e. the user opted to use a system avatar instead of uploading a
    // personal photo), render the role-themed avatar here. Every existing
    // call site automatically picks this up — no API change needed.
    final avatar = ProfessionalAvatar.tryParse(photoUrl);
    if (avatar != null) {
      Widget avatarLayer = ProfessionalAvatarView(
        avatar: avatar,
        size: size,
        square: square,
      );
      if (ring) {
        avatarLayer = Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(square ? size * 0.22 + 2 : (size + 4) / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: avatarLayer,
        );
      }
      if (!verified) return avatarLayer;
      final badgeSize = (size * 0.28).clamp(14.0, 22.0);
      return SizedBox(
        width: ring ? size + 4 : size,
        height: ring ? size + 4 : size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatarLayer,
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: _tealMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  CupertinoIcons.checkmark,
                  size: badgeSize * 0.55,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final image = _resolveImage();
    final hue = _hue;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
            HSLColor.fromAHSL(1, (hue + 30) % 360, 0.50, 0.50).toColor(),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
    );

    final photoLayer = image == null
        ? fallback
        : ClipRRect(
            borderRadius: _radius,
            child: Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Face-centered framing — Alignment(0, -0.35) biases the crop
              // toward the upper third of the image, which is where the face
              // sits in a standard head-and-shoulders headshot.
              alignment: const Alignment(0, -0.35),
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: _radius,
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: size * 0.30,
                    height: size * 0.30,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: _tealMain,
                    ),
                  ),
                );
              },
            ),
          );

    Widget result = photoLayer;
    if (ring) {
      result = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(square ? size * 0.22 + 2 : (size + 4) / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: result,
      );
    }

    if (!verified) return result;

    // Verified seal — sized as ~25% of the photo, anchored bottom-right
    final badgeSize = (size * 0.28).clamp(14.0, 22.0);
    return SizedBox(
      width: ring ? size + 4 : size,
      height: ring ? size + 4 : size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: _tealMain,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                CupertinoIcons.checkmark,
                size: badgeSize * 0.55,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
