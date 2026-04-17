/// Locale-aware currency helpers used across the app so the UI shows the
/// right symbol without any FX conversion — the numeric amount stays
/// identical, only the symbol changes with the active locale.
///
/// Mapping (current production locales):
///   - `en` → £ (Plagit launched in the UK market)
///   - `it` → €
///   - `ar` → € (European hospitality market default)
///   - default → € (safe non-GBP fallback until we add per-market rules)
library;

import 'package:flutter/widgets.dart';

/// Currency symbol for the active locale in [context].
String currencySymbolForLocale(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  switch (code) {
    case 'en':
      return '£';
    case 'it':
      return '€';
    case 'ar':
      return '€';
    default:
      return '€';
  }
}

/// Locale-aware price string with decimals (e.g. `£79.99`, `€79.99`).
String formatPrice(BuildContext context, num amount, {int decimals = 2}) {
  return '${currencySymbolForLocale(context)}${amount.toStringAsFixed(decimals)}';
}

/// Locale-aware price string without decimals (e.g. `£39`, `€39`).
String formatPriceInt(BuildContext context, num amount) {
  return '${currencySymbolForLocale(context)}${amount.toInt()}';
}

/// Rewrites any currency symbol (£/€/$) inside a display string to match the
/// active locale. Used to normalize compensation strings coming from backend
/// / mock data (which may be stored in GBP) so Italian users always see €, etc.
String localizeCompensation(BuildContext context, String raw) {
  final target = currencySymbolForLocale(context);
  return raw.replaceAll(RegExp(r'[£€\$]'), target);
}
