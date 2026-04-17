import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

const _tealMain = Color(0xFF2BB8B0);

/// Premium location card — shows a stylized map preview + address + "Open in Maps".
///
/// Designed for the candidate-facing job/business detail pages so candidates
/// can quickly understand exactly where the venue is located before applying.
class LocationCard extends StatelessWidget {
  final String address;
  final String? area; // e.g. "Milan, Italy"
  final double? latitude;
  final double? longitude;
  final double height;

  const LocationCard({
    super.key,
    required this.address,
    this.area,
    this.latitude,
    this.longitude,
    this.height = 160,
  });

  /// Soft neutral fallback while the OSM tile loads or if it fails.
  Widget _mapPlaceholder() {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: const Center(
        child: CupertinoActivityIndicator(color: _tealMain),
      ),
    );
  }

  /// Opens the location in the platform's native maps app.
  ///
  /// Priority:
  /// 1. Apple Maps (iOS native)
  /// 2. Google Maps app (iOS, if installed)
  /// 3. Native Android intent
  /// 4. Google Maps web (fallback)
  ///
  /// When coordinates exist, they are ALWAYS the primary signal — never relies
  /// on a vague text query that could resolve to the wrong city.
  Future<void> _openInMaps() async {
    final hasCoords = latitude != null && longitude != null;
    final encodedAddress = Uri.encodeComponent(address);

    final List<Uri> candidates = [];

    if (!kIsWeb) {
      if (Platform.isIOS) {
        // Apple Maps: when we have coordinates, use the `ll` param (drops a pin
        // at the exact coords) and `q` only as the pin label. When we don't,
        // use `address` (a more reliable Apple Maps param than `q`).
        if (hasCoords) {
          candidates.add(Uri.parse('maps://?ll=$latitude,$longitude&q=$encodedAddress'));
        } else {
          candidates.add(Uri.parse('maps://?address=$encodedAddress'));
        }
        // Google Maps iOS app fallback
        if (hasCoords) {
          candidates.add(Uri.parse('comgooglemaps://?center=$latitude,$longitude&q=$latitude,$longitude($encodedAddress)&zoom=16'));
        } else {
          candidates.add(Uri.parse('comgooglemaps://?q=$encodedAddress'));
        }
      } else if (Platform.isAndroid) {
        // Native Android intent
        if (hasCoords) {
          // geo:lat,lng?q=lat,lng(label) — pin lands exactly on the coordinates
          candidates.add(Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encodedAddress)'));
        } else {
          candidates.add(Uri.parse('geo:0,0?q=$encodedAddress'));
        }
      }
    }

    // Web fallback — always uses precise coordinates if available
    if (hasCoords) {
      candidates.add(Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'));
    } else {
      candidates.add(Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress'));
    }

    // Try each candidate in order
    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (ok) return;
        }
      } catch (_) {
        continue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;

    return GestureDetector(
      onTap: _openInMaps,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══════════════════════════════════════════
              // MAP PREVIEW (OpenStreetMap static tile)
              // ══════════════════════════════════════════
              SizedBox(
                height: height,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Real OSM tile (no API key required)
                    if (hasCoords)
                      Image.network(
                        'https://staticmap.openstreetmap.de/staticmap.php?center=$latitude,$longitude&zoom=15&size=800x400&maptype=mapnik',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _mapPlaceholder();
                        },
                        errorBuilder: (_, _, _) => _mapPlaceholder(),
                      )
                    else
                      _mapPlaceholder(),

                    // Subtle vignette for pin legibility (much lighter than before)
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.2,
                          colors: [
                            Color(0x00000000),
                            Color(0x14000000),
                          ],
                        ),
                      ),
                    ),

                    // ── Premium center pin: pulse ring + marker ──
                    Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _tealMain.withValues(alpha: 0.12),
                              ),
                            ),
                            // Inner ring
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _tealMain.withValues(alpha: 0.18),
                              ),
                            ),
                            // Solid marker dot
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _tealMain,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: _tealMain.withValues(alpha: 0.40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── "Get directions" floating chip (top-right) ──
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.location_north_fill, size: 11, color: _tealMain),
                            const SizedBox(width: 5),
                            Text(
                              AppLocalizations.of(context).directionsAction,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _tealMain,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════════
              // ADDRESS BLOCK — clean typography, no chrome
              // ══════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (area != null && area!.isNotEmpty)
                      Text(
                        area!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _tealMain,
                          letterSpacing: 0.8,
                        ),
                      ),
                    if (area != null && area!.isNotEmpty) const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.arrow_up_right_square_fill, size: 11, color: Color(0xFFAEAEB2)),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context).tapToOpenInMaps,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.40),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// _MapGridPainter removed — placeholder is now a clean neutral loading state.
// Real map preview comes from OpenStreetMap static tiles.
