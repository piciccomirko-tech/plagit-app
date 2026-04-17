/// Business identity fallback chain.
///
/// Hospitality businesses on Plagit can present in many ways — some have
/// a polished brand logo, some only have venue photos, and a brand-new
/// business may have neither. This widget renders whichever asset is
/// strongest, falling through a priority chain so the surface never
/// looks empty:
///
///   1. **Logo** — `logoUrl` if set
///   2. **Venue cover** — `coverImage` if set
///   3. **First gallery image** — `galleryImages.first` if any
///   4. **Category fallback** — gradient + category icon + initials
///
/// The category fallback is intentionally branded (not generic): each
/// hospitality category has its own icon and gradient so even a brand-new
/// restaurant looks like a restaurant, a hotel looks like a hotel, etc.
/// The result is a polished, premium identity slot rather than the empty
/// grey circle a missing image would normally produce.
library;

import 'package:flutter/material.dart';
import 'package:plagit/core/widgets/professional_avatar.dart';

const _tealMain = Color(0xFF00B5B0);

/// Source the [BusinessIdentity] widget actually rendered. Returned by
/// [BusinessIdentitySource.classify] so Admin views can label the chain
/// position with the same enum the widget uses internally.
enum BusinessIdentitySource {
  logo,
  coverImage,
  galleryImage,
  categoryFallback,
  none;

  String get label => switch (this) {
        logo => 'Brand logo',
        coverImage => 'Venue cover',
        galleryImage => 'Venue photo',
        categoryFallback => 'Category fallback',
        none => 'No identity',
      };

  /// Maps the source to the unified [IdentityType] enum so a single
  /// `IdentityTypeBadge` widget can render the badge for both candidate
  /// photos and business identity slots.
  IdentityType get identityType => switch (this) {
        logo => IdentityType.realPhoto,
        coverImage => IdentityType.realPhoto,
        galleryImage => IdentityType.realPhoto,
        categoryFallback => IdentityType.fallback,
        none => IdentityType.none,
      };

  /// Inspects a [BusinessProfile]-shaped record and reports which slot
  /// the [BusinessIdentity] widget will render. Pass the same args you
  /// pass to the widget so the classification stays consistent.
  static BusinessIdentitySource classify({
    String? logoUrl,
    String? coverImage,
    List<String> galleryImages = const [],
  }) {
    if (logoUrl != null && logoUrl.isNotEmpty) return logo;
    if (coverImage != null && coverImage.isNotEmpty) {
      return BusinessIdentitySource.coverImage;
    }
    if (galleryImages.isNotEmpty) return galleryImage;
    return categoryFallback;
  }
}

// ═══════════════════════════════════════════════════════════════
// Category fallback — icon + gradient per hospitality category
// ═══════════════════════════════════════════════════════════════

/// Internal helper that maps a free-text business category string to a
/// fallback icon + brand-aligned gradient. Loose keyword matching so
/// "Restaurant & Bar" → restaurant; "Boutique Hotel" → hotel; etc.
class _CategoryStyle {
  final IconData icon;
  final List<Color> gradient;
  const _CategoryStyle(this.icon, this.gradient);

  static _CategoryStyle from(String? category) {
    final c = category?.toLowerCase() ?? '';
    if (c.contains('hotel') || c.contains('resort') || c.contains('lodging')) {
      return const _CategoryStyle(
        Icons.hotel,
        [Color(0xFF2C3E60), Color(0xFF1A1C24)],
      );
    }
    if (c.contains('bar') || c.contains('club') || c.contains('lounge') || c.contains('pub')) {
      return const _CategoryStyle(
        Icons.local_bar,
        [Color(0xFFF59E33), Color(0xFFD97706)],
      );
    }
    if (c.contains('cafe') || c.contains('coffee') || c.contains('bakery')) {
      return const _CategoryStyle(
        Icons.local_cafe,
        [Color(0xFFA77B4E), Color(0xFF6F4E2A)],
      );
    }
    if (c.contains('catering') || c.contains('event') || c.contains('banquet')) {
      return const _CategoryStyle(
        Icons.celebration,
        [Color(0xFFE94A8C), Color(0xFFBE185D)],
      );
    }
    if (c.contains('spa') || c.contains('wellness')) {
      return const _CategoryStyle(
        Icons.spa,
        [Color(0xFF34C5A5), Color(0xFF14B8A6)],
      );
    }
    if (c.contains('fitness') || c.contains('gym')) {
      return const _CategoryStyle(
        Icons.fitness_center,
        [Color(0xFF6676F0), Color(0xFF4F46E5)],
      );
    }
    if (c.contains('cruise') || c.contains('travel') || c.contains('tour')) {
      return const _CategoryStyle(
        Icons.directions_boat_filled,
        [Color(0xFF2C3E60), Color(0xFF008B87)],
      );
    }
    if (c.contains('delivery')) {
      return const _CategoryStyle(
        Icons.delivery_dining,
        [Color(0xFFF59E33), Color(0xFFD97706)],
      );
    }
    if (c.contains('restaurant') || c.contains('bistro') || c.contains('eatery') ||
        c.contains('dining') || c.contains('kitchen') || c.contains('food')) {
      return const _CategoryStyle(
        Icons.restaurant,
        [Color(0xFFEF6C5A), Color(0xFFC2410C)],
      );
    }
    // Generic hospitality fallback — brand teal
    return const _CategoryStyle(
      Icons.storefront,
      [Color(0xFF00B5B0), Color(0xFF1A9090)],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BusinessIdentity widget
// ═══════════════════════════════════════════════════════════════

/// Renders the strongest available identity image for a business,
/// following the priority chain documented at the top of this file.
///
/// Use this anywhere a business avatar would normally appear: hero card
/// on the business profile, business chip in candidate match cards,
/// admin business detail view, etc.
class BusinessIdentity extends StatelessWidget {
  final String? logoUrl;
  final String? coverImage;
  final List<String> galleryImages;
  final String category;
  final String initials;

  /// Diameter (or side length, for `square` mode).
  final double size;

  /// When true, renders as a rounded square (passport / ID card feel).
  /// Defaults to circle which suits avatar slots; switch to square for
  /// hero cards where the imagery should read as a venue photo.
  final bool square;

  const BusinessIdentity({
    super.key,
    required this.initials,
    required this.category,
    this.logoUrl,
    this.coverImage,
    this.galleryImages = const [],
    this.size = 64,
    this.square = false,
  });

  /// Resolves which slot to render — same logic as
  /// [BusinessIdentitySource.classify] but kept inline so the build
  /// path doesn't allocate twice.
  String? get _bestImage {
    if (logoUrl != null && logoUrl!.isNotEmpty) return logoUrl;
    if (coverImage != null && coverImage!.isNotEmpty) return coverImage;
    if (galleryImages.isNotEmpty) return galleryImages.first;
    return null;
  }

  BorderRadius get _radius => square
      ? BorderRadius.circular(size * 0.22)
      : BorderRadius.circular(size / 2);

  @override
  Widget build(BuildContext context) {
    final image = _bestImage;
    if (image != null) {
      return ClipRRect(
        borderRadius: _radius,
        child: SizedBox(
          width: size,
          height: size,
          child: _NetworkOrAsset(
            src: image,
            errorBuilder: (_, _, _) => _buildFallback(),
          ),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final style = _CategoryStyle.from(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.gradient,
        ),
      ),
      child: Stack(
        children: [
          // Subtle top highlight — same trick as ProfessionalAvatarView,
          // gives the slot a "lit from above" feel rather than reading
          // as a flat coloured rectangle.
          ClipRRect(
            borderRadius: _radius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.9,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Category icon — large but slightly offset upward so the
          // initials text below it has room to breathe.
          Align(
            alignment: const Alignment(0, -0.35),
            child: Icon(
              style.icon,
              size: size * 0.36,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          // Initials — small label under the icon. Not the dominant
          // element (the icon is) but it gives the slot a personal anchor.
          Align(
            alignment: const Alignment(0, 0.55),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Image source resolver — supports network, asset, base64
// ═══════════════════════════════════════════════════════════════

class _NetworkOrAsset extends StatelessWidget {
  final String src;
  final ImageErrorWidgetBuilder errorBuilder;
  const _NetworkOrAsset({required this.src, required this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: errorBuilder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(color: Color(0xFFF2F2F7));
        },
      );
    }
    // base64 / data: URLs aren't expected for venue photos in mocks
    // but the model technically supports it — fall through to asset
    // for everything else.
    return Image.asset(src, fit: BoxFit.cover, errorBuilder: errorBuilder);
  }
}

// ═══════════════════════════════════════════════════════════════
// Reference helpers (kept here so callers can pull only this file)
// ═══════════════════════════════════════════════════════════════

/// The single brand-teal constant used by category fallback variants.
/// Re-exported so consumers don't need a second theme import.
const Color businessIdentityBrand = _tealMain;
