import 'package:flutter/widgets.dart';

/// Centralized language-name localization helper.
///
/// The backend stores the `candidate.languages` field as English labels
/// (e.g. "English, Italian, Arabic") or — less commonly — ISO codes
/// ('en', 'it'). To show that data in the UI we want the user's active
/// locale, not the stored value: an Italian user must see "Inglese",
/// "Italiano", "Arabo" instead of the raw English labels.
///
/// This helper is the single source of truth for that mapping. It accepts
/// either an ISO 639-1 code, the English full name, or the language's
/// native endonym (e.g. "Italiano", "العربية") and returns the display
/// string for the current `Localizations.localeOf(context)`.
///
/// If the active locale isn't explicitly covered, we fall back to the
/// English label — keeping behaviour safe for every unsupported UI
/// locale while still recognising the input.
///
/// NOTE: nothing here changes what the app stores or sends to the
/// backend. The persisted `profile.languages` field remains in its
/// original English form / ISO codes. Only the on-screen presentation
/// is translated.

// Canonical ISO 639-1 codes for the 33 languages Plagit supports in
// the language picker. Keeping the list in sync with
// `LanguageItem.all` in `lib/widgets/language_picker.dart`.
const List<String> _supportedIsoCodes = [
  'en', 'it', 'fr', 'es', 'de', 'pt', 'ar', 'ru', 'zh', 'ja',
  'ko', 'hi', 'tr', 'pl', 'nl', 'ro', 'el', 'sv', 'da', 'fi',
  'no', 'hr', 'bg', 'cs', 'hu', 'th', 'vi', 'id', 'ms', 'tl',
  'sw', 'uk', 'sr',
];

/// ISO code → localized display name, keyed by UI locale.
///
/// Only the app's three fully-translated locales (`en`, `it`, `ar`)
/// are present. For any other UI locale the helper falls back to the
/// `en` value so the user sees the canonical English label rather
/// than the raw backend string.
const Map<String, Map<String, String>> _languageNames = {
  'en': {
    'en': 'English',
    'it': 'Inglese',
    'ar': '\u0627\u0644\u0625\u0646\u062C\u0644\u064A\u0632\u064A\u0629',
    'es': 'Inglés',
  },
  'it': {
    'en': 'Italian',
    'it': 'Italiano',
    'ar': '\u0627\u0644\u0625\u064A\u0637\u0627\u0644\u064A\u0629',
    'es': 'Italiano',
  },
  'fr': {
    'en': 'French',
    'it': 'Francese',
    'ar': '\u0627\u0644\u0641\u0631\u0646\u0633\u064A\u0629',
    'es': 'Francés',
  },
  'es': {
    'en': 'Spanish',
    'it': 'Spagnolo',
    'ar': '\u0627\u0644\u0625\u0633\u0628\u0627\u0646\u064A\u0629',
    'es': 'Español',
  },
  'de': {
    'en': 'German',
    'it': 'Tedesco',
    'ar': '\u0627\u0644\u0623\u0644\u0645\u0627\u0646\u064A\u0629',
    'es': 'Alemán',
  },
  'pt': {
    'en': 'Portuguese',
    'it': 'Portoghese',
    'ar': '\u0627\u0644\u0628\u0631\u062A\u063A\u0627\u0644\u064A\u0629',
    'es': 'Portugués',
  },
  'ar': {
    'en': 'Arabic',
    'it': 'Arabo',
    'ar': '\u0627\u0644\u0639\u0631\u0628\u064A\u0629',
    'es': 'Árabe',
  },
  'ru': {
    'en': 'Russian',
    'it': 'Russo',
    'ar': '\u0627\u0644\u0631\u0648\u0633\u064A\u0629',
    'es': 'Ruso',
  },
  'zh': {
    'en': 'Chinese',
    'it': 'Cinese',
    'ar': '\u0627\u0644\u0635\u064A\u0646\u064A\u0629',
    'es': 'Chino',
  },
  'ja': {
    'en': 'Japanese',
    'it': 'Giapponese',
    'ar': '\u0627\u0644\u064A\u0627\u0628\u0627\u0646\u064A\u0629',
    'es': 'Japonés',
  },
  'ko': {
    'en': 'Korean',
    'it': 'Coreano',
    'ar': '\u0627\u0644\u0643\u0648\u0631\u064A\u0629',
    'es': 'Coreano',
  },
  'hi': {
    'en': 'Hindi',
    'it': 'Hindi',
    'ar': '\u0627\u0644\u0647\u0646\u062F\u064A\u0629',
    'es': 'Hindi',
  },
  'tr': {
    'en': 'Turkish',
    'it': 'Turco',
    'ar': '\u0627\u0644\u062A\u0631\u0643\u064A\u0629',
    'es': 'Turco',
  },
  'pl': {
    'en': 'Polish',
    'it': 'Polacco',
    'ar': '\u0627\u0644\u0628\u0648\u0644\u0646\u062F\u064A\u0629',
    'es': 'Polaco',
  },
  'nl': {
    'en': 'Dutch',
    'it': 'Olandese',
    'ar': '\u0627\u0644\u0647\u0648\u0644\u0646\u062F\u064A\u0629',
    'es': 'Neerlandés',
  },
  'ro': {
    'en': 'Romanian',
    'it': 'Rumeno',
    'ar': '\u0627\u0644\u0631\u0648\u0645\u0627\u0646\u064A\u0629',
    'es': 'Rumano',
  },
  'el': {
    'en': 'Greek',
    'it': 'Greco',
    'ar': '\u0627\u0644\u064A\u0648\u0646\u0627\u0646\u064A\u0629',
    'es': 'Griego',
  },
  'sv': {
    'en': 'Swedish',
    'it': 'Svedese',
    'ar': '\u0627\u0644\u0633\u0648\u064A\u062F\u064A\u0629',
    'es': 'Sueco',
  },
  'da': {
    'en': 'Danish',
    'it': 'Danese',
    'ar': '\u0627\u0644\u062F\u0646\u0645\u0627\u0631\u0643\u064A\u0629',
    'es': 'Danés',
  },
  'fi': {
    'en': 'Finnish',
    'it': 'Finlandese',
    'ar': '\u0627\u0644\u0641\u0646\u0644\u0646\u062F\u064A\u0629',
    'es': 'Finés',
  },
  'no': {
    'en': 'Norwegian',
    'it': 'Norvegese',
    'ar': '\u0627\u0644\u0646\u0631\u0648\u064A\u062C\u064A\u0629',
    'es': 'Noruego',
  },
  'hr': {
    'en': 'Croatian',
    'it': 'Croato',
    'ar': '\u0627\u0644\u0643\u0631\u0648\u0627\u062A\u064A\u0629',
    'es': 'Croata',
  },
  'bg': {
    'en': 'Bulgarian',
    'it': 'Bulgaro',
    'ar': '\u0627\u0644\u0628\u0644\u063A\u0627\u0631\u064A\u0629',
    'es': 'Búlgaro',
  },
  'cs': {
    'en': 'Czech',
    'it': 'Ceco',
    'ar': '\u0627\u0644\u062A\u0634\u064A\u0643\u064A\u0629',
    'es': 'Checo',
  },
  'hu': {
    'en': 'Hungarian',
    'it': 'Ungherese',
    'ar': '\u0627\u0644\u0645\u062C\u0631\u064A\u0629',
    'es': 'Húngaro',
  },
  'th': {
    'en': 'Thai',
    'it': 'Thailandese',
    'ar': '\u0627\u0644\u062A\u0627\u064A\u0644\u0627\u0646\u062F\u064A\u0629',
    'es': 'Tailandés',
  },
  'vi': {
    'en': 'Vietnamese',
    'it': 'Vietnamita',
    'ar': '\u0627\u0644\u0641\u064A\u062A\u0646\u0627\u0645\u064A\u0629',
    'es': 'Vietnamita',
  },
  'id': {
    'en': 'Indonesian',
    'it': 'Indonesiano',
    'ar': '\u0627\u0644\u0625\u0646\u062F\u0648\u0646\u064A\u0633\u064A\u0629',
    'es': 'Indonesio',
  },
  'ms': {
    'en': 'Malay',
    'it': 'Malese',
    'ar': '\u0627\u0644\u0645\u0627\u0644\u064A\u0632\u064A\u0629',
    'es': 'Malayo',
  },
  'tl': {
    'en': 'Filipino',
    'it': 'Filippino',
    'ar': '\u0627\u0644\u0641\u0644\u0628\u064A\u0646\u064A\u0629',
    'es': 'Filipino',
  },
  'sw': {
    'en': 'Swahili',
    'it': 'Swahili',
    'ar': '\u0627\u0644\u0633\u0648\u0627\u062D\u064A\u0644\u064A\u0629',
    'es': 'Suajili',
  },
  'uk': {
    'en': 'Ukrainian',
    'it': 'Ucraino',
    'ar': '\u0627\u0644\u0623\u0648\u0643\u0631\u0627\u0646\u064A\u0629',
    'es': 'Ucraniano',
  },
  'sr': {
    'en': 'Serbian',
    'it': 'Serbo',
    'ar': '\u0627\u0644\u0635\u0631\u0628\u064A\u0629',
    'es': 'Serbio',
  },
};

/// Inverse lookup: English canonical name (lowercase) → ISO 639-1 code.
/// Built lazily from [_languageNames]. Extra aliases (e.g. "mandarin",
/// "tagalog") are added afterwards to match common backend variations.
final Map<String, String> _englishNameToIso = _buildInverseIndex();

/// Inverse lookup: native endonym (lowercase) → ISO 639-1 code. Lets
/// callers pass "Italiano", "Français", "中文" directly.
final Map<String, String> _nativeNameToIso = _buildNativeNameIndex();

Map<String, String> _buildInverseIndex() {
  final map = <String, String>{};
  _languageNames.forEach((iso, byLocale) {
    final english = byLocale['en'];
    if (english != null) map[english.toLowerCase()] = iso;
  });
  // Common backend aliases that don't have a dedicated ISO entry.
  map['mandarin'] = 'zh';
  map['tagalog'] = 'tl';
  return map;
}

Map<String, String> _buildNativeNameIndex() {
  // Mirrors the `nativeName` values in `LanguageItem.all`. Duplicated
  // here (rather than imported) to avoid a circular dependency
  // between `core/` and `widgets/`.
  const natives = <String, String>{
    'en': 'English',
    'it': 'Italiano',
    'fr': 'Fran\u00E7ais',
    'es': 'Espa\u00F1ol',
    'de': 'Deutsch',
    'pt': 'Portugu\u00EAs',
    'ar': '\u0627\u0644\u0639\u0631\u0628\u064A\u0629',
    'ru': '\u0420\u0443\u0441\u0441\u043A\u0438\u0439',
    'zh': '\u4E2D\u6587',
    'ja': '\u65E5\u672C\u8A9E',
    'ko': '\uD55C\uAD6D\uC5B4',
    'hi': '\u0939\u093F\u0928\u094D\u0926\u0940',
    'tr': 'T\u00FCrk\u00E7e',
    'pl': 'Polski',
    'nl': 'Nederlands',
    'ro': 'Rom\u00E2n\u0103',
    'el': '\u0395\u03BB\u03BB\u03B7\u03BD\u03B9\u03BA\u03AC',
    'sv': 'Svenska',
    'da': 'Dansk',
    'fi': 'Suomi',
    'no': 'Norsk',
    'hr': 'Hrvatski',
    'bg': '\u0411\u044A\u043B\u0433\u0430\u0440\u0441\u043A\u0438',
    'cs': '\u010Ce\u0161tina',
    'hu': 'Magyar',
    'th': '\u0E44\u0E17\u0E22',
    'vi': 'Ti\u1EBFng Vi\u1EC7t',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'tl': 'Filipino',
    'sw': 'Kiswahili',
    'uk': '\u0423\u043A\u0440\u0430\u0457\u043D\u0441\u044C\u043A\u0430',
    'sr': '\u0421\u0440\u043F\u0441\u043A\u0438',
  };
  return {for (final e in natives.entries) e.value.toLowerCase(): e.key};
}

/// Normalize any incoming token (ISO code, English name, native name)
/// into an ISO 639-1 code. Returns `null` if the token isn't a known
/// language.
String? _tokenToIso(String raw) {
  final key = raw.trim().toLowerCase();
  if (key.isEmpty) return null;
  if (_supportedIsoCodes.contains(key)) return key;
  final fromEnglish = _englishNameToIso[key];
  if (fromEnglish != null) return fromEnglish;
  final fromNative = _nativeNameToIso[key];
  if (fromNative != null) return fromNative;
  return null;
}

/// Returns the display name of a language in the active UI locale.
///
/// Accepts either an ISO code ('en', 'it', 'ar'), an English full name
/// ('English', 'Italian', 'Arabic') or the native endonym ('Italiano',
/// 'العربية', '中文'). Unknown tokens are returned verbatim so the UI
/// never accidentally hides user-entered data.
///
/// The lookup uses `Localizations.localeOf(context).languageCode`.
/// Locales other than `en`, `it`, `ar` fall back to the English label.
String localizedLanguageName(BuildContext context, String rawCodeOrName) {
  final trimmed = rawCodeOrName.trim();
  if (trimmed.isEmpty) return trimmed;
  final iso = _tokenToIso(trimmed);
  if (iso == null) return trimmed;
  final locale = Localizations.localeOf(context).languageCode;
  final entry = _languageNames[iso];
  if (entry == null) return trimmed;
  return entry[locale] ?? entry['en'] ?? trimmed;
}

/// Returns a comma-separated, localized rendering of a CSV language
/// string ("English, Italian" → "Inglese, Italiano" on an Italian
/// device). Any proficiency suffix in parentheses ("(Native)",
/// "(Fluent)") is preserved unchanged. Accepts `/` as an alternate
/// separator. Unknown tokens pass through untouched.
String localizedLanguageCsv(BuildContext context, String raw) {
  if (raw.trim().isEmpty) return raw;
  final parts = raw.split(RegExp(r'[,/]'));
  final mapped = <String>[];
  for (final part in parts) {
    final trimmed = part.trim();
    if (trimmed.isEmpty) continue;
    // Split "Name (suffix)" so we only translate the language portion.
    final match = RegExp(r'^([^(]+?)\s*(\(.+\))?$').firstMatch(trimmed);
    if (match == null) {
      mapped.add(trimmed);
      continue;
    }
    final head = match.group(1)!.trim();
    final suffix = match.group(2);
    final localized = localizedLanguageName(context, head);
    mapped.add(suffix != null ? '$localized $suffix' : localized);
  }
  return mapped.join(', ');
}

/// Returns a localized rendering of a list of language tokens (ISO
/// codes, English names, or native endonyms). Used by the profile
/// card / chip helpers to render the selected-set summary.
String localizedLanguageList(BuildContext context, Iterable<String> tokens) {
  return tokens
      .map((t) => localizedLanguageName(context, t))
      .where((s) => s.isNotEmpty)
      .join(', ');
}
