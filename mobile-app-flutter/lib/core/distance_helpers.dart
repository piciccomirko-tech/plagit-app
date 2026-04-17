/// Locale-aware distance formatting helpers.
///
/// Plagit's mock/backend data currently stores short distances in miles
/// (e.g. `"1.2 mi"`). For Italian and Arabic locales we display the value
/// in kilometres using an approximate conversion (1 mi ≈ 1.609 km). The
/// numeric precision is rounded to 0-1 decimals depending on the size to
/// match the compact pill layout used in lists.
///
/// NOTE: Proper unit conversion on the backend is a TODO — once the API
/// returns metric distances we can remove the conversion factor here.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

const double _milesToKm = 1.609;

/// Returns a locale-aware distance string. Accepts either a raw display
/// string (e.g. `"1.2 mi"`) or a numeric miles value.
///
/// - `en` → miles (`1.2 mi`)
/// - `it`, `ar`, others → kilometres (`1.9 km` / `١٫٩ كم`)
String localizedDistance(
  BuildContext context,
  String raw, {
  String rawUnit = 'mi',
}) {
  final l = AppLocalizations.of(context);
  final code = Localizations.localeOf(context).languageCode;

  // Extract numeric portion (handles "1.2 mi", "1.2mi", "1.2").
  final trimmed = raw.trim();
  final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(trimmed);
  if (match == null) return raw;

  final value = double.tryParse(match.group(0) ?? '') ?? 0;

  if (code == 'en') {
    return l.distanceMiles(_formatValue(value));
  }

  // Convert miles → km for non-English locales (if source is miles).
  final km = rawUnit == 'mi' ? value * _milesToKm : value;
  return l.distanceKilometers(_formatValue(km));
}

/// Formats a numeric distance with sensible precision (1 decimal when
/// the value is small, integer otherwise).
String _formatValue(double value) {
  if (value >= 10) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
