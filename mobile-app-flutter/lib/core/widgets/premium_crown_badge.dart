/// Canonical premium-identity badge.
///
/// Single source of truth for premium visual identity across the
/// Plagit app. Every screen that needs to mark a user / state as
/// premium should render this widget instead of a bespoke crown.
///
/// Design tokens (approved — do not drift):
///   • Background: radial gradient `#FFF9EC → #FAEBC8` with an
///     off-center light source at `(-0.25, -0.35)` — reads as a
///     polished champagne medallion with an implied highlight.
///   • Border: `#CFA15F` at 18% alpha — vintage-gold hairline.
///   • Shadow: `#CFA15F` at 10% alpha — barely-there gold lift.
///   • Crown glyph: `PhosphorIconsFill.crown` in `#CFA15F`
///     (warm vintage gold) — soft filled crown with jewel points.
///     The Regular outline variant read too faintly on the champagne
///     medallion; the filled variant is more readable while staying
///     elegant because the fill colour is the same warm gold used
///     before, not a darker or more saturated tone.
///   • Crown size ratio: ~45% of outer diameter (slightly tighter
///     than the outline's 48% so the filled glyph doesn't feel
///     chunkier than the outline did — reclaim the pixels the fill
///     adds to the visual weight by shrinking the glyph a hair).
///   • Optical centering: small negative Y offset (crown glyphs
///     sit low in their bounding box, so we lift them up a hair).
///
/// Everything scales from the single [size] parameter so callers
/// never have to think about blur / offset / ratio math.
library;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ── Canonical premium palette ──
const Color kPremiumChampagneTop = Color(0xFFFFF9EC);
const Color kPremiumChampagneBottom = Color(0xFFFAEBC8);
const Color kPremiumGold = Color(0xFFCFA15F);

class PremiumCrownBadge extends StatelessWidget {
  /// Outer diameter of the circular medallion in logical pixels.
  /// Everything else (glyph size, shadow, optical centering)
  /// derives from this value.
  final double size;

  const PremiumCrownBadge({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    // Derived dimensions. Calibrated against the approved reference
    // (size=42 → glyph=19 filled, blur=10, offset=2, optical=-0.5).
    // Glyph ratio dropped 0.48 → 0.45 to offset the extra visual
    // weight the filled variant adds vs the outline.
    final glyphSize = (size * 0.45).roundToDouble();
    final shadowBlur = size * 0.24;
    final shadowOffsetY = size * 0.05;
    final borderWidth = size < 36 ? 0.5 : 0.6;
    final opticalOffsetY = -(size * 0.012);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.25, -0.35),
          radius: 1.0,
          colors: [kPremiumChampagneTop, kPremiumChampagneBottom],
        ),
        border: Border.all(
          color: kPremiumGold.withValues(alpha: 0.18),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: kPremiumGold.withValues(alpha: 0.10),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffsetY),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0, opticalOffsetY),
        child: PhosphorIcon(
          PhosphorIconsFill.crown,
          size: glyphSize,
          color: kPremiumGold,
        ),
      ),
    );
  }
}
