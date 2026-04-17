/// Localization helpers for the hospitality taxonomy (category →
/// subcategory → role) used by Candidate onboarding, Business signup
/// and post-job flows.
///
/// The canonical English labels coming from `HospitalityCatalog` (and
/// backend payloads) are kept intact everywhere — these helpers only
/// translate the *displayed* label. That way filtering, backend
/// matching and routing continue to work with the raw keys while the
/// UI shows the user their own language.
///
/// Unknown strings pass through untouched so that free-form or
/// future backend values still render.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/core/hospitality_catalog.dart';
import 'package:plagit/core/l10n_helpers.dart';

/// Returns the localized display label for a top-level hospitality
/// category. The input is the canonical English name as stored in
/// [HospitalityCatalog] (e.g. `Restaurants`, `Bakeries & Pastry`).
String localizedCategory(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final map = _categoryMap[locale];
  if (map == null) return raw;

  final key = raw.trim().toLowerCase();
  return map[key] ?? raw;
}

/// Returns the localized display label for a hospitality category
/// from its canonical id (e.g. `restaurants`, `back_office`).
/// Falls back to the English name from the catalog when the locale
/// has no translation, or to the raw id when the category is unknown.
String localizedCategoryById(BuildContext context, String id) {
  final cat = HospitalityCatalog.findCategory(id);
  if (cat == null) return id;
  return localizedCategory(context, cat.name);
}

/// Returns the localized display label for a hospitality subcategory.
/// The input is the canonical English name as stored in
/// [HospitalityCatalog] (e.g. `Fine Dining`, `Cocktail Bar`).
String localizedSubcategory(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final map = _subcategoryMap[locale];
  if (map == null) return raw;

  final key = raw.trim().toLowerCase();
  return map[key] ?? raw;
}

/// Returns the localized display label for a subcategory given its
/// parent category id and the subcategory id. Falls back to the raw
/// id when either lookup fails.
String localizedSubcategoryByIds(
    BuildContext context, String categoryId, String subcategoryId) {
  final cat = HospitalityCatalog.findCategory(categoryId);
  if (cat == null) return subcategoryId;
  try {
    final sub = cat.subcategories.firstWhere((s) => s.id == subcategoryId);
    return localizedSubcategory(context, sub.name);
  } catch (_) {
    return subcategoryId;
  }
}

/// Localized equivalent of `HospitalityCatalog.displayPath` — rebuilds
/// the "Category › Subcategory › Role" breadcrumb with each segment
/// translated for the current locale. Raw ids are still used internally
/// so filtering / backend matching stay intact.
String localizedCategoryPath(
  BuildContext context, {
  String? categoryId,
  String? subcategoryId,
  String? roleId,
}) {
  final parts = <String>[];
  final cat = categoryId != null ? HospitalityCatalog.findCategory(categoryId) : null;
  if (cat != null) {
    parts.add(localizedCategory(context, cat.name));
    if (subcategoryId != null) {
      try {
        final sub = cat.subcategories.firstWhere((s) => s.id == subcategoryId);
        parts.add(localizedSubcategory(context, sub.name));
        if (roleId != null && sub.roles.contains(roleId)) {
          parts.add(localizedJobRole(context, roleId));
        }
      } catch (_) {}
    }
  }
  return parts.join(' › ');
}

// ── Top-level categories (21) ──
//
// Keys are the canonical English names lowercased for case-insensitive
// lookup. Values are the Italian / Arabic translations. Other locales
// fall back to English.
const Map<String, Map<String, String>> _categoryMap = {
  'it': {
    'back office': 'Operazioni interne',
    'bakeries & pastry': 'Panetterie e pasticcerie',
    'bars': 'Bar',
    'cafés': 'Caffetterie',
    'cafes': 'Caffetterie',
    'catering': 'Catering',
    'clubs & nightlife': 'Club e vita notturna',
    'corporate hospitality': 'Ospitalità aziendale',
    'cruises & yachts': 'Crociere e yacht',
    'delivery': 'Consegne',
    'entertainment': 'Intrattenimento',
    'events & banqueting': 'Eventi e banchetti',
    'fitness & wellness': 'Fitness e benessere',
    'healthcare hospitality': 'Ospitalità sanitaria',
    'hotels': 'Hotel',
    'luxury hospitality': 'Ospitalità di lusso',
    'private dining': 'Ristorazione privata',
    'resorts': 'Resort',
    'restaurants': 'Ristoranti',
    'schools & training': 'Scuole e formazione',
    'spa & wellness': 'Spa e benessere',
    'specialty kitchens': 'Cucine specializzate',
    'support services': 'Servizi di supporto',
    'travel hospitality': 'Ospitalità turistica',
  },
  'ar': {
    'back office': 'المكتب الإداري',
    'bakeries & pastry': 'مخابز وحلويات',
    'bars': 'حانات',
    'cafés': 'مقاهي',
    'cafes': 'مقاهي',
    'catering': 'تموين',
    'clubs & nightlife': 'نوادي وحياة ليلية',
    'corporate hospitality': 'الضيافة المؤسسية',
    'cruises & yachts': 'رحلات بحرية ويخوت',
    'delivery': 'توصيل',
    'entertainment': 'الترفيه',
    'events & banqueting': 'الفعاليات والمآدب',
    'fitness & wellness': 'اللياقة والعافية',
    'healthcare hospitality': 'ضيافة الرعاية الصحية',
    'hotels': 'فنادق',
    'luxury hospitality': 'الضيافة الفاخرة',
    'private dining': 'الطعام الخاص',
    'resorts': 'منتجعات',
    'restaurants': 'مطاعم',
    'schools & training': 'مدارس وتدريب',
    'spa & wellness': 'سبا وعافية',
    'specialty kitchens': 'مطابخ متخصصة',
    'support services': 'خدمات الدعم',
    'travel hospitality': 'ضيافة السفر',
  },
  'es': {
    'back office': 'Oficina administrativa',
    'bakeries & pastry': 'Panaderías y pastelerías',
    'bars': 'Bares',
    'cafés': 'Cafeterías',
    'cafes': 'Cafeterías',
    'catering': 'Catering',
    'clubs & nightlife': 'Clubs y vida nocturna',
    'corporate hospitality': 'Hospitalidad corporativa',
    'cruises & yachts': 'Cruceros y yates',
    'delivery': 'Entrega',
    'entertainment': 'Entretenimiento',
    'events & banqueting': 'Eventos y banquetes',
    'fitness & wellness': 'Fitness y bienestar',
    'healthcare hospitality': 'Hospitalidad sanitaria',
    'hotels': 'Hoteles',
    'luxury hospitality': 'Hospitalidad de lujo',
    'private dining': 'Comedor privado',
    'resorts': 'Resorts',
    'restaurants': 'Restaurantes',
    'schools & training': 'Escuelas y formación',
    'spa & wellness': 'Spa y bienestar',
    'specialty kitchens': 'Cocinas especializadas',
    'support services': 'Servicios de soporte',
    'travel hospitality': 'Hospitalidad turística',
  },
};

// ── Subcategories ──
//
// Keys are the canonical English names lowercased. International
// borrowings (Pizzeria, Trattoria, Osteria, Bistro, Gelateria…) are
// intentionally kept in their native form across all locales.
const Map<String, Map<String, String>> _subcategoryMap = {
  'it': {
    // Back Office
    'accounting & finance': 'Contabilità e finanza',
    'administration': 'Amministrazione',
    'human resources': 'Risorse umane',
    'it & systems': 'IT e sistemi',
    'marketing & sales': 'Marketing e vendite',
    // Bakeries
    'artisan bakery': 'Panetteria artigianale',
    'chocolaterie': 'Cioccolateria',
    'pastry shop': 'Pasticceria',
    'production bakery': 'Panificio industriale',
    // Bars
    'cocktail bar': 'Cocktail bar',
    'hotel bar': 'Bar di hotel',
    'lounge bar': 'Lounge bar',
    'pub & gastropub': 'Pub e gastropub',
    'rooftop bar': 'Rooftop bar',
    'wine bar': 'Wine bar',
    // Cafés
    'bakery café': 'Caffetteria con panetteria',
    'bakery cafe': 'Caffetteria con panetteria',
    'brunch & breakfast': 'Brunch e colazione',
    'coffee shop': 'Coffee shop',
    'tea room': 'Sala da tè',
    // Catering
    'corporate catering': 'Catering aziendale',
    'event catering': 'Catering per eventi',
    'luxury catering': 'Catering di lusso',
    'mobile catering': 'Catering mobile',
    'private catering': 'Catering privato',
    'wedding catering': 'Catering per matrimoni',
    // Clubs
    'beach club': 'Beach club',
    'lounge': 'Lounge',
    'members club': 'Club privato',
    'nightclub': 'Discoteca',
    // Corporate
    'corporate canteen': 'Mensa aziendale',
    'executive dining': 'Ristorazione executive',
    'vip lounge': 'VIP lounge',
    // Cruises
    'cruise ship': 'Nave da crociera',
    'river cruise': 'Crociera fluviale',
    'yacht': 'Yacht',
    // Delivery
    'catering delivery': 'Consegna catering',
    'dark kitchen delivery': 'Consegna dark kitchen',
    'premium / vip delivery': 'Consegna premium / VIP',
    'restaurant delivery': 'Consegna ristorante',
    // Entertainment
    'club shows': 'Spettacoli in club',
    'family entertainment': 'Intrattenimento famiglie',
    'hotel entertainment': 'Intrattenimento hotel',
    'live music venue': 'Locale di musica dal vivo',
    'night entertainment': 'Intrattenimento notturno',
    'resort entertainment': 'Intrattenimento resort',
    'wedding entertainment': 'Intrattenimento per matrimoni',
    // Events
    'banqueting': 'Banchetti',
    'conference & exhibition': 'Conferenze e fiere',
    'exhibitions': 'Fiere',
    'floral & decoration': 'Fiori e decorazioni',
    'gala dinners': 'Cene di gala',
    'weddings': 'Matrimoni',
    // Fitness
    'gym': 'Palestra',
    'nutrition studio': 'Studio nutrizionale',
    'spa': 'Spa',
    'wellness center': 'Centro benessere',
    // Healthcare
    'clinic': 'Clinica',
    'hospital': 'Ospedale',
    'medical wellness center': 'Centro benessere medico',
    // Hotels
    'boutique hotel': 'Boutique hotel',
    'business hotel': 'Hotel business',
    'food & beverage': 'Food & beverage',
    'front office': 'Front office',
    'housekeeping': 'Pulizie e piani',
    'luxury hotel': 'Hotel di lusso',
    'maintenance': 'Manutenzione',
    'serviced apartments': 'Appartamenti con servizi',
    // Luxury
    'private estate': 'Tenuta privata',
    'palace hotel': 'Palace hotel',
    'luxury villa': 'Villa di lusso',
    // Private dining
    'home dining experience': 'Esperienza di ristorazione a domicilio',
    "members' club": 'Club privato',
    'supper club': 'Supper club',
    // Resorts
    'all-inclusive resort': 'Resort all-inclusive',
    'beach resort': 'Beach resort',
    'boutique resort': 'Boutique resort',
    'golf resort': 'Golf resort',
    'ski resort': 'Resort sciistico',
    'spa resort': 'Spa resort',
    // Restaurants
    'casual dining': 'Ristorazione casual',
    'fast casual': 'Fast casual',
    'fine dining': 'Alta cucina',
    'pizzeria': 'Pizzeria',
    'quick service': 'Quick service',
    'specialty restaurant': 'Ristorante specializzato',
    // Schools
    'barista academy': 'Accademia baristi',
    'bartending academy': 'Accademia bartender',
    'culinary school': 'Scuola di cucina',
    'hospitality school': 'Scuola di ospitalità',
    'hotel management school': 'Scuola di hotel management',
    // Spa
    'day spa': 'Day spa',
    'fitness & gym': 'Fitness e palestra',
    'hotel spa': 'Spa di hotel',
    'standalone spa': 'Spa indipendente',
    // Specialty kitchens
    'cloud kitchen': 'Cloud kitchen',
    'commissary kitchen': 'Cucina centralizzata',
    'test kitchen / r&d': 'Test kitchen / R&D',
    // Support
    'cleaning & janitorial': 'Pulizie e manutenzione locali',
    'fire safety': 'Sicurezza antincendio',
    'food safety': 'Sicurezza alimentare',
    'health & safety': 'Salute e sicurezza',
    'logistics & supply': 'Logistica e forniture',
    'security': 'Sicurezza',
    // Travel
    'airline catering': 'Catering aereo',
    'airport lounge': 'Lounge aeroportuale',
    'train dining': 'Ristorazione ferroviaria',
  },
  'ar': {
    // Back Office
    'accounting & finance': 'المحاسبة والمالية',
    'administration': 'الإدارة',
    'human resources': 'الموارد البشرية',
    'it & systems': 'تقنية المعلومات والأنظمة',
    'marketing & sales': 'التسويق والمبيعات',
    // Bakeries
    'artisan bakery': 'مخبز حرفي',
    'chocolaterie': 'محل شوكولاتة',
    'pastry shop': 'محل حلويات',
    'production bakery': 'مخبز إنتاج',
    // Bars
    'cocktail bar': 'بار كوكتيل',
    'hotel bar': 'بار الفندق',
    'lounge bar': 'بار صالة',
    'pub & gastropub': 'حانة ومطعم حانة',
    'rooftop bar': 'بار السطح',
    'wine bar': 'بار نبيذ',
    // Cafés
    'bakery café': 'مقهى مخبز',
    'bakery cafe': 'مقهى مخبز',
    'brunch & breakfast': 'برانش وإفطار',
    'coffee shop': 'مقهى قهوة',
    'tea room': 'قاعة شاي',
    // Catering
    'corporate catering': 'تموين الشركات',
    'event catering': 'تموين الفعاليات',
    'luxury catering': 'تموين فاخر',
    'mobile catering': 'تموين متنقل',
    'private catering': 'تموين خاص',
    'wedding catering': 'تموين الأعراس',
    // Clubs
    'beach club': 'نادي شاطئي',
    'lounge': 'صالة',
    'members club': 'نادي أعضاء',
    'nightclub': 'نادٍ ليلي',
    // Corporate
    'corporate canteen': 'مقصف الشركة',
    'executive dining': 'مطعم التنفيذيين',
    'vip lounge': 'صالة كبار الشخصيات',
    // Cruises
    'cruise ship': 'سفينة سياحية',
    'river cruise': 'رحلة نهرية',
    'yacht': 'يخت',
    // Delivery
    'catering delivery': 'توصيل التموين',
    'dark kitchen delivery': 'توصيل المطبخ المظلم',
    'premium / vip delivery': 'توصيل مميز / كبار الشخصيات',
    'restaurant delivery': 'توصيل المطاعم',
    // Entertainment
    'club shows': 'عروض النوادي',
    'family entertainment': 'ترفيه عائلي',
    'hotel entertainment': 'ترفيه الفنادق',
    'live music venue': 'مكان موسيقى حية',
    'night entertainment': 'ترفيه ليلي',
    'resort entertainment': 'ترفيه المنتجعات',
    'wedding entertainment': 'ترفيه الأعراس',
    // Events
    'banqueting': 'مآدب',
    'conference & exhibition': 'مؤتمرات ومعارض',
    'exhibitions': 'معارض',
    'floral & decoration': 'زهور وديكور',
    'gala dinners': 'عشاءات فاخرة',
    'weddings': 'أعراس',
    // Fitness
    'gym': 'صالة رياضية',
    'nutrition studio': 'استوديو تغذية',
    'spa': 'سبا',
    'wellness center': 'مركز عافية',
    // Healthcare
    'clinic': 'عيادة',
    'hospital': 'مستشفى',
    'medical wellness center': 'مركز عافية طبي',
    // Hotels
    'boutique hotel': 'فندق بوتيك',
    'business hotel': 'فندق أعمال',
    'food & beverage': 'الطعام والمشروبات',
    'front office': 'مكتب الاستقبال',
    'housekeeping': 'التدبير المنزلي',
    'luxury hotel': 'فندق فاخر',
    'maintenance': 'الصيانة',
    'serviced apartments': 'شقق فندقية',
    // Luxury
    'private estate': 'ضيعة خاصة',
    'palace hotel': 'فندق قصر',
    'luxury villa': 'فيلا فاخرة',
    // Private dining
    'home dining experience': 'تجربة طعام منزلية',
    "members' club": 'نادي الأعضاء',
    'supper club': 'نادي عشاء',
    // Resorts
    'all-inclusive resort': 'منتجع شامل',
    'beach resort': 'منتجع شاطئي',
    'boutique resort': 'منتجع بوتيك',
    'golf resort': 'منتجع جولف',
    'ski resort': 'منتجع تزلج',
    'spa resort': 'منتجع سبا',
    // Restaurants
    'casual dining': 'مطعم غير رسمي',
    'fast casual': 'مطعم سريع غير رسمي',
    'fine dining': 'مطعم راقٍ',
    'pizzeria': 'بيتزيريا',
    'quick service': 'خدمة سريعة',
    'specialty restaurant': 'مطعم متخصص',
    // Schools
    'barista academy': 'أكاديمية باريستا',
    'bartending academy': 'أكاديمية ساقي',
    'culinary school': 'مدرسة طهي',
    'hospitality school': 'مدرسة ضيافة',
    'hotel management school': 'مدرسة إدارة فنادق',
    // Spa
    'day spa': 'سبا نهاري',
    'fitness & gym': 'لياقة وصالة رياضية',
    'hotel spa': 'سبا فندق',
    'standalone spa': 'سبا مستقل',
    // Specialty kitchens
    'cloud kitchen': 'مطبخ سحابي',
    'commissary kitchen': 'مطبخ مركزي',
    'test kitchen / r&d': 'مطبخ اختبار / البحث والتطوير',
    // Support
    'cleaning & janitorial': 'تنظيف وصيانة',
    'fire safety': 'السلامة من الحرائق',
    'food safety': 'سلامة الأغذية',
    'health & safety': 'الصحة والسلامة',
    'logistics & supply': 'الخدمات اللوجستية والتوريد',
    'security': 'الأمن',
    // Travel
    'airline catering': 'تموين الطيران',
    'airport lounge': 'صالة المطار',
    'train dining': 'مطاعم القطارات',
  },
  'es': {
    // Back Office
    'accounting & finance': 'Contabilidad y finanzas',
    'administration': 'Administración',
    'human resources': 'Recursos humanos',
    'it & systems': 'TI y sistemas',
    'marketing & sales': 'Marketing y ventas',
    // Bakeries
    'artisan bakery': 'Panadería artesanal',
    'chocolaterie': 'Chocolatería',
    'pastry shop': 'Pastelería',
    'production bakery': 'Panadería industrial',
    // Bars
    'cocktail bar': 'Bar de cócteles',
    'hotel bar': 'Bar de hotel',
    'lounge bar': 'Lounge bar',
    'pub & gastropub': 'Pub y gastropub',
    'rooftop bar': 'Bar en la azotea',
    'wine bar': 'Vinoteca',
    // Cafés
    'bakery café': 'Cafetería con panadería',
    'bakery cafe': 'Cafetería con panadería',
    'brunch & breakfast': 'Brunch y desayuno',
    'coffee shop': 'Cafetería',
    'tea room': 'Salón de té',
    // Catering
    'corporate catering': 'Catering corporativo',
    'event catering': 'Catering para eventos',
    'luxury catering': 'Catering de lujo',
    'mobile catering': 'Catering móvil',
    'private catering': 'Catering privado',
    'wedding catering': 'Catering para bodas',
    // Clubs
    'beach club': 'Beach club',
    'lounge': 'Lounge',
    'members club': 'Club de socios',
    'nightclub': 'Discoteca',
    // Corporate
    'corporate canteen': 'Comedor corporativo',
    'executive dining': 'Comedor ejecutivo',
    'vip lounge': 'Sala VIP',
    // Cruises
    'cruise ship': 'Crucero',
    'river cruise': 'Crucero fluvial',
    'yacht': 'Yate',
    // Delivery
    'catering delivery': 'Entrega de catering',
    'dark kitchen delivery': 'Entrega dark kitchen',
    'premium / vip delivery': 'Entrega premium / VIP',
    'restaurant delivery': 'Entrega de restaurante',
    // Entertainment
    'club shows': 'Espectáculos en club',
    'family entertainment': 'Entretenimiento familiar',
    'hotel entertainment': 'Entretenimiento hotelero',
    'live music venue': 'Local de música en vivo',
    'night entertainment': 'Entretenimiento nocturno',
    'resort entertainment': 'Entretenimiento en resort',
    'wedding entertainment': 'Entretenimiento para bodas',
    // Events
    'banqueting': 'Banquetes',
    'conference & exhibition': 'Conferencias y ferias',
    'exhibitions': 'Ferias',
    'floral & decoration': 'Floral y decoración',
    'gala dinners': 'Cenas de gala',
    'weddings': 'Bodas',
    // Fitness
    'gym': 'Gimnasio',
    'nutrition studio': 'Estudio de nutrición',
    'spa': 'Spa',
    'wellness center': 'Centro de bienestar',
    // Healthcare
    'clinic': 'Clínica',
    'hospital': 'Hospital',
    'medical wellness center': 'Centro de bienestar médico',
    // Hotels
    'boutique hotel': 'Hotel boutique',
    'business hotel': 'Hotel de negocios',
    'food & beverage': 'Alimentos y bebidas',
    'front office': 'Recepción',
    'housekeeping': 'Limpieza de habitaciones',
    'luxury hotel': 'Hotel de lujo',
    'maintenance': 'Mantenimiento',
    'serviced apartments': 'Apartamentos con servicios',
    // Luxury
    'private estate': 'Finca privada',
    'palace hotel': 'Hotel palacio',
    'luxury villa': 'Villa de lujo',
    // Private dining
    'home dining experience': 'Experiencia gastronómica a domicilio',
    "members' club": 'Club de socios',
    'supper club': 'Supper club',
    // Resorts
    'all-inclusive resort': 'Resort todo incluido',
    'beach resort': 'Resort de playa',
    'boutique resort': 'Resort boutique',
    'golf resort': 'Resort de golf',
    'ski resort': 'Resort de esquí',
    'spa resort': 'Resort spa',
    // Restaurants
    'casual dining': 'Restaurante casual',
    'fast casual': 'Fast casual',
    'fine dining': 'Alta cocina',
    'pizzeria': 'Pizzería',
    'quick service': 'Servicio rápido',
    'specialty restaurant': 'Restaurante especializado',
    // Schools
    'barista academy': 'Academia de baristas',
    'bartending academy': 'Academia de bartenders',
    'culinary school': 'Escuela de cocina',
    'hospitality school': 'Escuela de hostelería',
    'hotel management school': 'Escuela de gestión hotelera',
    // Spa
    'day spa': 'Day spa',
    'fitness & gym': 'Fitness y gimnasio',
    'hotel spa': 'Spa de hotel',
    'standalone spa': 'Spa independiente',
    // Specialty kitchens
    'cloud kitchen': 'Cloud kitchen',
    'commissary kitchen': 'Cocina centralizada',
    'test kitchen / r&d': 'Cocina de pruebas / I+D',
    // Support
    'cleaning & janitorial': 'Limpieza y mantenimiento de locales',
    'fire safety': 'Seguridad contra incendios',
    'food safety': 'Seguridad alimentaria',
    'health & safety': 'Salud y seguridad',
    'logistics & supply': 'Logística y suministros',
    'security': 'Seguridad',
    // Travel
    'airline catering': 'Catering aéreo',
    'airport lounge': 'Sala de aeropuerto',
    'train dining': 'Restauración ferroviaria',
  },
};
