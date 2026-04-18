/// Professional role-based avatar fallback system.
///
/// Plagit is a hospitality hiring platform — when a candidate doesn't want
/// to upload a personal photo, we offer a polished, work-focused avatar
/// instead of leaving an empty placeholder. The visual language must feel
/// **human, premium, and trustworthy** — not flat, not cartoonish, not
/// game-like.
///
/// ── How the avatar renders ──
///
/// Each avatar identifier resolves to a real photographic headshot from a
/// curated catalog (see [_AvatarPhotoCatalog]). The renderer fetches the
/// photo via `NetworkImage`, frames it with face-centered cropping, and
/// overlays a small subtle role pill in the corner so the viewer reads
/// "real hospitality professional in this role" rather than "generic
/// system avatar".
///
/// ── Why real photos, not icons ──
///
/// Earlier iterations of this system used Material `face_*` icons over
/// role-themed gradients. The result felt like a flat placeholder, not a
/// credible work profile. Real photographic headshots are the only way to
/// hit the visual bar this product needs (smiling, premium, role-appropriate).
/// All photos in the catalog come from Unsplash's permissive license and
/// are already proven to load in this codebase — see the catalog for the
/// full list. Production deploys should commission a custom-licensed photo
/// set so each role has unique imagery; the catalog is the single point
/// of curation.
///
/// ── Identifier format ──
///
/// Avatars are encoded as a single string that fits inside the existing
/// `photoUrl` field on `CandidateProfile`. No DB migration needed — every
/// surface that already renders `ProfilePhoto(photoUrl: ...)` automatically
/// renders the system avatar when the URL starts with `avatar:`.
///
///     avatar:<role>:<gender>:<variant>
///     avatar:chef:male:1
///     avatar:bartender:female:1
///     avatar:host:neutral:1
library;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// ROLE — canonical hospitality roles supported by the avatar system
// ═══════════════════════════════════════════════════════════════

/// Canonical hospitality roles for the avatar system.
///
/// Plagit's full role catalog has 130+ titles; we collapse them down to
/// the ten roles that have meaningful, distinct visual identity in the
/// avatar system. Anything outside this list falls back to [generic],
/// which still renders a polished avatar (just without role iconography).
enum AvatarRole {
  waiter,
  bartender,
  chef,
  host,
  manager,
  barista,
  receptionist,
  housekeeping,
  sommelier,
  eventStaff,
  generic;

  /// Human-readable label for the picker UI.
  String get label => switch (this) {
        waiter => 'Waiter',
        bartender => 'Bartender',
        chef => 'Chef',
        host => 'Host / Hostess',
        manager => 'Manager',
        barista => 'Barista',
        receptionist => 'Receptionist',
        housekeeping => 'Housekeeping',
        sommelier => 'Sommelier',
        eventStaff => 'Event Staff',
        generic => 'Hospitality',
      };

  /// Material icon shown in the small role pill in the avatar's corner.
  /// Chosen so each pill is immediately readable at 12-14px without text.
  IconData get badgeIcon => switch (this) {
        waiter => Icons.room_service,
        bartender => Icons.local_bar,
        chef => Icons.restaurant_menu,
        host => Icons.support_agent,
        manager => Icons.work,
        barista => Icons.local_cafe,
        receptionist => Icons.desk,
        housekeeping => Icons.cleaning_services,
        sommelier => Icons.wine_bar,
        eventStaff => Icons.celebration,
        generic => Icons.handshake,
      };

  /// Brand-aligned accent for the role pill background. Subtle, not the
  /// dominant element — the photo is the dominant element now.
  Color get accent => switch (this) {
        waiter => const Color(0xFF00B5B0),
        bartender => const Color(0xFFD97706),
        chef => const Color(0xFFC2410C),
        host => const Color(0xFF6B5BD0),
        manager => const Color(0xFF1A1C24),
        barista => const Color(0xFF6F4E2A),
        receptionist => const Color(0xFF4F46E5),
        housekeeping => const Color(0xFF14B8A6),
        sommelier => const Color(0xFF5C1530),
        eventStaff => const Color(0xFFBE185D),
        generic => const Color(0xFF1A9090),
      };

  /// Maps a free-text role string from `CandidateProfile.role` (or any
  /// other free-text source) to a canonical [AvatarRole]. Loose keyword
  /// matching so "Head Chef", "Sous Chef", "Pastry Chef" all resolve to
  /// [chef]. Anything unrecognised becomes [generic].
  static AvatarRole fromRoleText(String? text) {
    if (text == null || text.isEmpty) return generic;
    final t = text.toLowerCase();
    if (t.contains('chef') || t.contains('cook') || t.contains('kitchen')) {
      return chef;
    }
    if (t.contains('bartender') || t.contains('mixologist')) return bartender;
    if (t.contains('barista') || t.contains('coffee')) return barista;
    if (t.contains('sommelier') || t.contains('wine')) return sommelier;
    if (t.contains('housekeep') || t.contains('room attendant') || t.contains('cleaner')) {
      return housekeeping;
    }
    if (t.contains('reception') || t.contains('front desk') || t.contains('concierge')) {
      return receptionist;
    }
    if (t.contains('event') || t.contains('banquet')) return eventStaff;
    if (t.contains('manager') || t.contains('supervisor') || t.contains('director')) {
      return manager;
    }
    if (t.contains('host') || t.contains('hostess')) return host;
    if (t.contains('waiter') || t.contains('waitress') || t.contains('server') ||
        t.contains('runner') || t.contains('floor')) {
      return waiter;
    }
    return generic;
  }
}

// ═══════════════════════════════════════════════════════════════
// GENDER — three options, never required for the user to disclose
// ═══════════════════════════════════════════════════════════════

/// Avatar gender presentation. Always optional — the picker defaults to
/// the first available option for the chosen role so a candidate never
/// has to make a gender disclosure to use the system.
enum AvatarGender {
  male,
  female,
  neutral;

  String get label => switch (this) {
        male => 'Male',
        female => 'Female',
        neutral => 'Neutral',
      };
}

// ═══════════════════════════════════════════════════════════════
// ProfessionalAvatar — value type that round-trips through a String
// ═══════════════════════════════════════════════════════════════

/// A specific avatar choice — role + gender + variant.
///
/// Encoded as `avatar:<role>:<gender>:<variant>` so it can be stored in
/// the existing `photoUrl` field with no model migration. Decode via
/// [tryParse]; check membership via [isAvatarId].
@immutable
class ProfessionalAvatar {
  final AvatarRole role;
  final AvatarGender gender;

  /// 1-based index. Future variants can extend beyond 1 without breaking
  /// older stored IDs. The catalog determines which variants actually
  /// have a real photo behind them.
  final int variant;

  const ProfessionalAvatar({
    required this.role,
    required this.gender,
    this.variant = 1,
  });

  /// Encoded identifier — safe to store in `photoUrl`.
  String get id => 'avatar:${role.name}:${gender.name}:$variant';

  /// Whether a given string is an avatar identifier (vs a real URL).
  static bool isAvatarId(String? value) =>
      value != null && value.startsWith('avatar:');

  /// Parses an `avatar:role:gender:variant` string. Returns null on any
  /// malformed input — callers should treat null as "not an avatar" and
  /// fall through to whatever they were going to render before.
  static ProfessionalAvatar? tryParse(String? value) {
    if (!isAvatarId(value)) return null;
    final parts = value!.split(':');
    if (parts.length < 4) return null;
    final role = AvatarRole.values.where((r) => r.name == parts[1]).firstOrNull;
    final gender =
        AvatarGender.values.where((g) => g.name == parts[2]).firstOrNull;
    final variant = int.tryParse(parts[3]) ?? 1;
    if (role == null || gender == null) return null;
    return ProfessionalAvatar(role: role, gender: gender, variant: variant);
  }

  /// The actual photographic URL backing this avatar. Returns null if
  /// the catalog has no entry for this combination — callers should
  /// fall through to the initials gradient in that case.
  String? get photoUrl => _AvatarPhotoCatalog.lookup(role, gender, variant);

  /// All (gender, variant) combinations available for the given role,
  /// sorted by gender (male, female, neutral) then variant. Used by the
  /// picker to enumerate the variant grid.
  static List<ProfessionalAvatar> availableForRole(AvatarRole role) {
    return _AvatarPhotoCatalog.availableForRole(role);
  }

  ProfessionalAvatar copyWith({
    AvatarRole? role,
    AvatarGender? gender,
    int? variant,
  }) =>
      ProfessionalAvatar(
        role: role ?? this.role,
        gender: gender ?? this.gender,
        variant: variant ?? this.variant,
      );

  @override
  bool operator ==(Object other) =>
      other is ProfessionalAvatar &&
      other.role == role &&
      other.gender == gender &&
      other.variant == variant;

  @override
  int get hashCode => Object.hash(role, gender, variant);
}

// ═══════════════════════════════════════════════════════════════
// _AvatarPhotoCatalog — the curated photo URL pool
// ═══════════════════════════════════════════════════════════════

/// Curated map of (role, gender, variant) → real Unsplash headshot URL.
///
/// Every URL in this catalog has been verified to load — they are all
/// already in use elsewhere in the codebase. To extend the catalog, add
/// more entries; every avatar identifier resolves through here.
///
/// Some photos are reused across roles where the visual is generic
/// enough to fit (a smiling professional in business attire works for
/// host, manager, and waiter contexts). Production deploys should
/// commission a custom photo set so every role has unique imagery.
class _AvatarPhotoCatalog {
  static const _photos = <String, String>{
    // ── Waiter ──
    'waiter:female:1':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop&crop=faces&q=80',
    'waiter:male:1':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&h=600&fit=crop&crop=faces&q=80',
    'waiter:neutral:1':
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Bartender ──
    'bartender:female:1':
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600&h=600&fit=crop&crop=faces&q=80',
    'bartender:male:1':
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Chef ──
    'chef:male:1':
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=600&h=600&fit=crop&crop=faces&q=80',
    'chef:female:1':
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Host / Hostess ──
    'host:male:1':
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=600&h=600&fit=crop&crop=faces&q=80',
    'host:female:1':
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Manager ──
    'manager:female:1':
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600&h=600&fit=crop&crop=faces&q=80',
    'manager:male:1':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Barista ──
    'barista:female:1':
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&h=600&fit=crop&crop=faces&q=80',
    'barista:male:1':
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=600&h=600&fit=crop&q=80',

    // ── Receptionist ──
    'receptionist:female:1':
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600&h=600&fit=crop&crop=faces&q=80',
    'receptionist:male:1':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Sommelier ──
    'sommelier:male:1':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&h=600&fit=crop&crop=faces&q=80',
    'sommelier:female:1':
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Housekeeping ──
    'housekeeping:female:1':
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&h=600&fit=crop&crop=faces&q=80',

    // ── Event staff ──
    'eventStaff:female:1':
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600&h=600&fit=crop&crop=faces&q=80',
    'eventStaff:male:1':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&h=600&fit=crop&crop=faces&q=80',
  };

  static String? lookup(AvatarRole role, AvatarGender gender, int variant) {
    return _photos['${role.name}:${gender.name}:$variant'];
  }

  /// Sorted list of available (gender, variant) combos for the role.
  /// Sort order: male, female, neutral, then variant ascending.
  static List<ProfessionalAvatar> availableForRole(AvatarRole role) {
    final result = <ProfessionalAvatar>[];
    for (final gender in AvatarGender.values) {
      for (var variant = 1; variant <= 5; variant++) {
        if (_photos.containsKey('${role.name}:${gender.name}:$variant')) {
          result.add(ProfessionalAvatar(
            role: role,
            gender: gender,
            variant: variant,
          ));
        }
      }
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════
// IdentityType — used by Admin views to label the source of an image
// ═══════════════════════════════════════════════════════════════

/// What kind of profile imagery a user actually has — needed by Admin so
/// reviewers can tell at a glance whether a profile is using a real
/// uploaded photo, a system-generated avatar, or no image at all.
enum IdentityType {
  realPhoto,
  systemAvatar,
  fallback,
  none;

  /// Inspects a `photoUrl` value and classifies it. Treats `avatar:`
  /// strings as systemAvatar, http(s)/data:/asset paths as realPhoto.
  static IdentityType classify(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return none;
    if (ProfessionalAvatar.isAvatarId(photoUrl)) return systemAvatar;
    return realPhoto;
  }

  String get label => switch (this) {
        realPhoto => 'Real photo',
        systemAvatar => 'System avatar',
        fallback => 'Fallback identity',
        none => 'No image',
      };

  /// Accent colour for the badge — green for real, teal for avatar,
  /// amber for fallback, secondary grey for none.
  Color get color => switch (this) {
        realPhoto => const Color(0xFF34C759),
        systemAvatar => const Color(0xFF00B5B0),
        fallback => const Color(0xFFF59E33),
        none => const Color(0xFF9EA3AD),
      };

  IconData get icon => switch (this) {
        realPhoto => Icons.photo_camera,
        systemAvatar => Icons.face_retouching_natural,
        fallback => Icons.image_outlined,
        none => Icons.help_outline,
      };
}

// ═══════════════════════════════════════════════════════════════
// ProfessionalAvatarView — pure renderer for a ProfessionalAvatar
// ═══════════════════════════════════════════════════════════════

/// Renders a single [ProfessionalAvatar] as a self-contained widget.
///
/// Layered visual:
///   1. Real photographic headshot via `NetworkImage` with face-centered
///      framing — the dominant element. Falls back to a stable initials
///      gradient if the catalog has no entry for this combination.
///   2. Optional small role pill in the bottom-right corner — subtle,
///      not the dominant element. Off by default below 36 px so it
///      stays legible.
///
/// All sizing scales from [size] so the same widget works at 36 px in a
/// list row and at 120 px in a hero card. The renderer is intentionally
/// stateless and dependency-free so it's safe to embed anywhere.
class ProfessionalAvatarView extends StatelessWidget {
  final ProfessionalAvatar avatar;
  final double size;
  final bool square;

  /// Whether to show the small role pill in the bottom-right corner.
  /// At very small sizes the pill becomes illegible — keep it off
  /// below ~36 px.
  final bool showRoleBadge;

  const ProfessionalAvatarView({
    super.key,
    required this.avatar,
    this.size = 64,
    this.square = false,
    this.showRoleBadge = true,
  });

  BorderRadius get _radius => square
      ? BorderRadius.circular(size * 0.22)
      : BorderRadius.circular(size / 2);

  @override
  Widget build(BuildContext context) {
    final url = avatar.photoUrl;
    final showBadge = showRoleBadge && size >= 36;

    Widget photoLayer;
    if (url != null) {
      photoLayer = ClipRRect(
        borderRadius: _radius,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Bias crop toward upper third — standard headshot framing.
          alignment: const Alignment(0, -0.35),
          errorBuilder: (_, _, _) => _initialsFallback(),
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
                  color: Color(0xFF00B5B0),
                ),
              ),
            );
          },
        ),
      );
    } else {
      photoLayer = _initialsFallback();
    }

    if (!showBadge) return photoLayer;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          photoLayer,
          Positioned(
            right: -2,
            bottom: -2,
            child: _RolePill(
              icon: avatar.role.badgeIcon,
              accent: avatar.role.accent,
              size: (size * 0.30).clamp(18.0, 26.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Initials gradient — only shown when the catalog has no entry for
  /// the requested (role, gender, variant) combo. Stable hue derived
  /// from the role + gender so the same combo always falls back to the
  /// same colour.
  Widget _initialsFallback() {
    final hue = ((avatar.role.name + avatar.gender.name).hashCode % 360)
        .abs()
        .toDouble();
    return Container(
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
      child: Icon(
        avatar.role.badgeIcon,
        size: size * 0.42,
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final double size;
  const _RolePill({required this.icon, required this.accent, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 5,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.56, color: Colors.white),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Identity badge — small pill the Admin views show next to a profile
// ═══════════════════════════════════════════════════════════════

/// Compact pill that displays the [IdentityType] of a profile image.
/// Used by the Admin candidate / business detail screens so reviewers
/// can immediately tell whether a profile uses a real uploaded photo,
/// a system avatar, or a fallback identity image.
class IdentityTypeBadge extends StatelessWidget {
  final IdentityType type;
  final bool compact;
  const IdentityTypeBadge({super.key, required this.type, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: compact ? 10 : 12, color: type.color),
          SizedBox(width: compact ? 3 : 4),
          Text(
            type.label,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: type.color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
