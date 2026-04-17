import 'package:flutter/widgets.dart';

/// Maps common English exonyms to Italian/Arabic exonyms where the localized
/// form is the natural choice (Rome→Roma, London→Londra). Names that stay
/// unchanged in each locale (Dubai, New York) are left as-is.
///
/// The helper only rewrites the CITY portion. If a string contains a comma
/// (e.g. "Milan, IT"), we split on the first comma, localize the city, and
/// rejoin with the original suffix.
const Map<String, Map<String, String>> _cityExonyms = {
  'London': {'it': 'Londra', 'ar': 'لندن', 'es': 'Londres'},
  'Rome': {'it': 'Roma', 'ar': 'روما', 'es': 'Roma'},
  'Milan': {'it': 'Milano', 'ar': 'ميلانو', 'es': 'Milán'},
  'Florence': {'it': 'Firenze', 'ar': 'فلورنسا', 'es': 'Florencia'},
  'Venice': {'it': 'Venezia', 'ar': 'البندقية', 'es': 'Venecia'},
  'Naples': {'it': 'Napoli', 'ar': 'نابولي', 'es': 'Nápoles'},
  'Turin': {'it': 'Torino', 'ar': 'تورينو', 'es': 'Turín'},
  'Genoa': {'it': 'Genova', 'ar': 'جنوة', 'es': 'Génova'},
  'Bologna': {'it': 'Bologna', 'ar': 'بولونيا', 'es': 'Bolonia'},
  'Paris': {'it': 'Parigi', 'ar': 'باريس', 'es': 'París'},
  'Munich': {'it': 'Monaco di Baviera', 'ar': 'ميونخ', 'es': 'Múnich'},
  'Vienna': {'it': 'Vienna', 'ar': 'فيينا', 'es': 'Viena'},
  'Geneva': {'it': 'Ginevra', 'ar': 'جنيف', 'es': 'Ginebra'},
  'Zurich': {'it': 'Zurigo', 'ar': 'زيورخ', 'es': 'Zúrich'},
  'Brussels': {'it': 'Bruxelles', 'ar': 'بروكسل', 'es': 'Bruselas'},
  'Athens': {'it': 'Atene', 'ar': 'أثينا', 'es': 'Atenas'},
  'Lisbon': {'it': 'Lisbona', 'ar': 'لشبونة', 'es': 'Lisboa'},
  'Madrid': {'it': 'Madrid', 'ar': 'مدريد', 'es': 'Madrid'},
  'Barcelona': {'it': 'Barcellona', 'ar': 'برشلونة', 'es': 'Barcelona'},
  'Berlin': {'it': 'Berlino', 'ar': 'برلين', 'es': 'Berlín'},
  'Amsterdam': {'it': 'Amsterdam', 'ar': 'أمستردام', 'es': 'Ámsterdam'},
  'Prague': {'it': 'Praga', 'ar': 'براغ', 'es': 'Praga'},
  'Warsaw': {'it': 'Varsavia', 'ar': 'وارسو', 'es': 'Varsovia'},
  'Moscow': {'it': 'Mosca', 'ar': 'موسكو', 'es': 'Moscú'},
  'Dubai': {'it': 'Dubai', 'ar': 'دبي', 'es': 'Dubái'},
  'Abu Dhabi': {'it': 'Abu Dhabi', 'ar': 'أبو ظبي', 'es': 'Abu Dabi'},
  'Doha': {'it': 'Doha', 'ar': 'الدوحة', 'es': 'Doha'},
  'Riyadh': {'it': 'Riad', 'ar': 'الرياض', 'es': 'Riad'},
  'Cairo': {'it': 'Il Cairo', 'ar': 'القاهرة', 'es': 'El Cairo'},
  'Istanbul': {'it': 'Istanbul', 'ar': 'إسطنبول', 'es': 'Estambul'},
  'New York': {'it': 'New York', 'ar': 'نيويورك', 'es': 'Nueva York'},
  'Los Angeles': {'it': 'Los Angeles', 'ar': 'لوس أنجلوس', 'es': 'Los Ángeles'},
  'Tokyo': {'it': 'Tokyo', 'ar': 'طوكيو', 'es': 'Tokio'},
  'Sydney': {'it': 'Sydney', 'ar': 'سيدني', 'es': 'Sídney'},
  'Singapore': {'it': 'Singapore', 'ar': 'سنغافورة', 'es': 'Singapur'},
  'Hong Kong': {'it': 'Hong Kong', 'ar': 'هونغ كونغ', 'es': 'Hong Kong'},
};

/// Return [raw] with the city segment mapped to the active locale's exonym,
/// if one exists. Preserves any suffix after the first comma.
String localizedCity(BuildContext context, String? raw) {
  if (raw == null || raw.trim().isEmpty) return raw ?? '';
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;
  final parts = raw.split(',');
  final head = parts.first.trim();
  final tail = parts.length > 1 ? ', ${parts.sublist(1).join(',').trim()}' : '';
  final mapped = _cityExonyms[head]?[locale];
  if (mapped != null) return '$mapped$tail';
  return raw;
}

/// Return [raw] with any embedded city-name substring rewritten into the
/// active locale's exonym. Unlike [localizedCity], this helper applies a
/// regex word-boundary replacement so composite strings like
/// `"The Ritz London"` become `"The Ritz Londra"` on IT devices.
///
/// If no known city is detected, [raw] is returned unchanged.
String localizedVenueName(BuildContext context, String? raw) {
  if (raw == null || raw.trim().isEmpty) return raw ?? '';
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;
  var out = raw;
  _cityExonyms.forEach((english, translations) {
    final mapped = translations[locale];
    if (mapped == null || mapped == english) return;
    // Word-boundary match that tolerates spaces inside the key
    // (e.g. "New York", "Hong Kong").
    final escaped = RegExp.escape(english);
    final pattern = RegExp(r'(^|[\s,/\-])' + escaped + r'(?=$|[\s,/\-])');
    out = out.replaceAllMapped(pattern, (m) => '${m.group(1)}$mapped');
  });
  return out;
}
