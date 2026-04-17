/// Localization helpers that map backend/enum values to translated labels.
///
/// Keeps raw backend data intact while giving the UI a localized display
/// string. Always call these from widgets instead of using raw enum labels.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/community_provider.dart';

/// Localized display name for a [BusinessJobStatus].
String localizedJobStatus(BuildContext context, BusinessJobStatus status) {
  final l = AppLocalizations.of(context);
  return switch (status) {
    BusinessJobStatus.active => l.jobStatusActive,
    BusinessJobStatus.paused => l.jobStatusPaused,
    BusinessJobStatus.closed => l.jobStatusClosed,
    BusinessJobStatus.draft => l.jobStatusDraft,
  };
}

/// Localized label for an [EmploymentType].
String localizedEmploymentType(BuildContext context, EmploymentType type) {
  final l = AppLocalizations.of(context);
  return switch (type) {
    EmploymentType.fullTime => l.fullTime,
    EmploymentType.partTime => l.partTime,
    EmploymentType.fixedTerm => l.temporary,
    EmploymentType.hourly => l.contractCasual,
  };
}

/// Localized display label for an application-status string coming either
/// from the backend or from the typed [ApplicationStatus] enum's
/// `displayName`. Accepts snake_case, camelCase or already-display form.
///
/// Keep internal keys untouched — only the display label is localized so
/// tab-filter comparisons against e.g. `'applied'` keep working.
String localizedApplicationStatus(BuildContext context, String status) {
  final l = AppLocalizations.of(context);
  final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  return switch (key) {
    'applied' => l.appStatusPillApplied,
    'underreview' || 'review' => l.appStatusPillUnderReview,
    'shortlisted' => l.appStatusPillShortlisted,
    'interviewinvited' || 'invited' => l.appStatusPillInterviewInvited,
    'interviewscheduled' || 'interview' => l.appStatusPillInterviewScheduled,
    'hired' || 'offer' || 'accepted' => l.appStatusPillHired,
    'rejected' => l.appStatusPillRejected,
    'withdrawn' => l.appStatusPillWithdrawn,
    _ => status,
  };
}

/// Localized label for an interview-status display string
/// (e.g. `Confirmed`, `Pending`, `Completed`, `Cancelled`, `Invited`).
String localizedInterviewStatus(BuildContext context, String status) {
  final l = AppLocalizations.of(context);
  final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  return switch (key) {
    'confirmed' => l.confirmed,
    'pending' || 'invited' => l.pending,
    'completed' => l.completed,
    'cancelled' || 'canceled' || 'noshow' => l.cancelled,
    _ => status,
  };
}

/// Lowercase localized interview-status label — matches backend strings
/// that arrive lowercase (`confirmed`, `pending`, etc.) and preserves the
/// lowercase presentation expected by some pills.
String localizedInterviewStatusLower(BuildContext context, String status) {
  final l = AppLocalizations.of(context);
  final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  return switch (key) {
    'confirmed' => l.statusConfirmedLower,
    'pending' || 'invited' => l.pending.toLowerCase(),
    'completed' => l.completed.toLowerCase(),
    'cancelled' || 'canceled' || 'noshow' => l.cancelled.toLowerCase(),
    _ => status,
  };
}

/// Localized display label for a [SavedPostCategory]. Keeps enum values
/// unchanged — only the label shown to the user is translated.
String localizedPostCategory(BuildContext context, SavedPostCategory cat) {
  final l = AppLocalizations.of(context);
  return switch (cat) {
    SavedPostCategory.restaurants => l.categoryRestaurants,
    SavedPostCategory.cookingVideos => l.categoryCookingVideos,
    SavedPostCategory.jobsTips => l.categoryJobsTips,
    SavedPostCategory.hospitalityNews => l.categoryHospitalityNews,
    SavedPostCategory.recipes => l.categoryRecipes,
    SavedPostCategory.other => l.categoryOther,
  };
}

/// Localizes notification titles that follow known hiring-event prefixes.
///
/// Supports patterns with either em-dash (`Interview Confirmed — {venue}`)
/// or colon (`Interview confirmed: {venue}`). Also handles a handful of
/// free-form mock titles we ship as demo data. Backend-generated strings
/// that don't match any known prefix are returned as-is so they still render.
///
/// The prefix part is translated; the trailing business/venue/person name
/// is kept intact as it comes from user/backend data.
String localizedNotificationTitle(BuildContext context, String raw) {
  final l = AppLocalizations.of(context);
  final trimmed = raw.trim();

  // ── Prefix — {name} / Prefix: {name} patterns ──
  // Matches "<Prefix> — <name>" OR "<Prefix>: <name>" case-insensitively.
  // Order matters: more specific prefixes first (e.g. "Interview Reminder"
  // before "Interview", "New Application" before "Application").
  final prefixMatchers = <_PrefixMatcher>[
    _PrefixMatcher(
      RegExp(r'^New Application\s*[—\-:]\s*(.+)$', caseSensitive: false),
      (name) => l.newApplicationTemplate(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Interview Confirmed\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifInterviewConfirmedTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Interview Request\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifInterviewRequestTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Interview Reminder\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifInterviewReminderTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Interview invite(?:\s*from)?\s*[—\-:]?\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifInterviewRequestTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Application Update\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifApplicationUpdateTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Offer Received\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifOfferReceivedTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^(?:New message|Message) from\s*[—\-:]?\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifMessageFromTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Profile Viewed\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifProfileViewedTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^New job match\s*[—\-:]\s*(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifNewJobMatchTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r'^Your application was viewed by\s+(.+)$',
        caseSensitive: false,
      ),
      (name) => l.notifApplicationViewedTitle(name),
    ),
    _PrefixMatcher(
      RegExp(
        r"^You(?:'ve| have) been shortlisted at\s+(.+)$",
        caseSensitive: false,
      ),
      (name) => l.notifShortlistedTitle(name),
    ),
  ];

  for (final m in prefixMatchers) {
    final match = m.pattern.firstMatch(trimmed);
    if (match != null) {
      final name = match.group(1)!.trim();
      return m.build(name);
    }
  }

  // ── Compound patterns ──
  // "New application: <name> for <role>"
  final newAppNameRole = RegExp(
    r'^New application[:\-—]\s*(.+?)\s+for\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (newAppNameRole != null) {
    return l.notifNewApplicationNameRole(
      newAppNameRole.group(1)!.trim(),
      newAppNameRole.group(2)!.trim(),
    );
  }

  // "<name> applied for <role>"
  final appliedFor = RegExp(
    r'^(.+?)\s+applied for\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (appliedFor != null) {
    return l.notifAppliedForRole(
      appliedFor.group(1)!.trim(),
      appliedFor.group(2)!.trim(),
    );
  }

  // "Your <role> job has N new views"
  final newViews = RegExp(
    r'^Your\s+(.+?)\s+job has\s+(\d+)\s+new views?$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (newViews != null) {
    return l.notifNewJobViews(
      newViews.group(1)!.trim(),
      newViews.group(2)!.trim(),
    );
  }

  // ── Static mock titles ──
  final lower = trimmed.toLowerCase();
  if (lower == 'complete your profile for better matches') {
    return l.notifCompleteProfile;
  }
  if (lower == 'complete your business profile for better visibility') {
    return l.notifCompleteBusinessProfile;
  }

  return raw;
}

/// Internal pair used by [localizedNotificationTitle] to keep the prefix
/// regex tables compact and readable.
class _PrefixMatcher {
  final RegExp pattern;
  final String Function(String name) build;
  const _PrefixMatcher(this.pattern, this.build);
}

/// Localized display label for a common hospitality job role.
///
/// Maps well-known English role labels (coming from mock data or free-text
/// backend fields like `authorRole`) to Italian / Arabic equivalents.
/// Unknown roles fall through untouched so user-typed titles still render.
String localizedJobRole(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final trimmed = raw.trim();
  if (trimmed.isEmpty) return raw;

  final map = _jobRoleMap[locale];
  if (map == null) return raw;

  // Exact match first (case-insensitive). This covers the curated labels
  // below (e.g. "Head Chef", "Bartender").
  final key = trimmed.toLowerCase();
  final direct = map[key];
  if (direct != null) return direct;

  return raw;
}

// ── Common hospitality role labels ──
//
// Keys are lowercased so lookup is case-insensitive. Keep in sync with
// `authorRole` values seeded in `lib/core/mock/mock_data.dart`.
const Map<String, Map<String, String>> _jobRoleMap = {
  'it': {
    'all': 'Tutti',
    // ── Kitchen / Chef roles ──
    'head chef': 'Capo chef',
    'sous chef': 'Sous chef',
    'senior chef': 'Chef senior',
    'chef': 'Chef',
    'executive chef': 'Executive chef',
    'pastry chef': 'Pasticcere',
    'line cook': 'Cuoco di linea',
    'commis chef': 'Commis di cucina',
    'chef de partie': 'Chef de partie',
    'kitchen porter': 'Aiuto cucina',
    'kitchen manager': 'Responsabile cucina',
    'cook': 'Cuoco',
    'prep cook': 'Addetto preparazioni',
    'brunch cook': 'Cuoco brunch',
    'breakfast cook': 'Cuoco per colazioni',
    'pizzaiolo': 'Pizzaiolo',
    'pizza helper': 'Aiuto pizzaiolo',
    'food runner': 'Runner di sala',
    'food stylist': 'Food stylist',
    'r&d chef': 'R&D chef',
    'recipe developer': 'Sviluppatore ricette',
    'production chef': 'Chef di produzione',
    'cloud kitchen chef': 'Chef cloud kitchen',
    'resort chef': 'Chef resort',
    'club chef': 'Chef di club',
    'villa chef': 'Chef di villa',
    'yacht chef': 'Chef di yacht',
    'cruise chef': 'Chef di crociera',
    'private chef': 'Chef privato',
    'catering chef': 'Chef di catering',
    'event chef': 'Chef per eventi',
    'canteen chef': 'Chef di mensa',
    'banquet chef': 'Chef banchetti',
    'airline chef': 'Chef per compagnie aeree',
    // ── Bakery ──
    'baker': 'Panettiere',
    'artisan baker': 'Panettiere artigianale',
    'bread baker': 'Panettiere',
    'sourdough specialist': 'Specialista lievito madre',
    'chocolatier': 'Cioccolatiere',
    'confectioner': 'Confettiere',
    'cake decorator': 'Decoratore di torte',
    'viennoiserie baker': 'Panettiere viennoiserie',
    'production baker': 'Panettiere di produzione',
    'production line lead': 'Responsabile di linea',
    'quality controller': 'Addetto al controllo qualità',
    // ── Service / Waitstaff ──
    'waiter': 'Cameriere',
    'waitress': 'Cameriera',
    'head waiter': 'Capo cameriere',
    'senior waiter': 'Cameriere senior',
    'server': 'Cameriere',
    'event waiter': 'Cameriere per eventi',
    'wedding server': 'Cameriere per matrimoni',
    'banquet server': 'Cameriere banchetti',
    'catering server': 'Cameriere di catering',
    'private server': 'Cameriere privato',
    "maitre d'": 'Maître',
    'butler': 'Maggiordomo',
    'villa butler': 'Maggiordomo di villa',
    // ── Bar ──
    'bartender': 'Barista',
    'bar manager': 'Bar manager',
    'barback': 'Aiuto barista',
    'barista': 'Barista da caffè',
    'head barista': 'Capo barista',
    'head bartender': 'Capo bartender',
    'mixologist': 'Mixologist',
    'coffee roaster': 'Torrefattore',
    'sommelier': 'Sommelier',
    'head sommelier': 'Capo sommelier',
    'wine steward': 'Addetto al vino',
    'cellar manager': 'Responsabile cantina',
    'pub manager': 'Pub manager',
    'lounge manager': 'Responsabile lounge',
    'lounge attendant': 'Addetto lounge',
    'beach bartender': 'Bartender da spiaggia',
    'event bartender': 'Bartender per eventi',
    'tea specialist': 'Specialista del tè',
    // ── Management ──
    'manager': 'Manager',
    'restaurant manager': 'Manager di ristorante',
    'general manager': 'Direttore',
    'assistant manager': 'Vice manager',
    'floor manager': 'Responsabile di sala',
    'shift manager': 'Capo turno',
    'shift lead': 'Capo turno',
    'shift supervisor': 'Supervisore di turno',
    'store manager': 'Responsabile punto vendita',
    'cafe manager': 'Responsabile caffetteria',
    'club manager': 'Responsabile club',
    'beach club manager': 'Responsabile beach club',
    'catering manager': 'Responsabile catering',
    'catering coordinator': 'Coordinatore catering',
    'canteen manager': 'Responsabile mensa',
    'banquet manager': 'Responsabile banchetti',
    'banquet captain': 'Capo banchetti',
    'operations manager': 'Responsabile operativo',
    'office manager': 'Office manager',
    'estate manager': 'Estate manager',
    'villa manager': 'Responsabile villa',
    'fitness manager': 'Responsabile fitness',
    'spa manager': 'Responsabile spa',
    'f&b manager': 'F&B manager',
    'front office manager': 'Responsabile front office',
    'housekeeping manager': 'Responsabile housekeeping',
    'maintenance manager': 'Responsabile manutenzione',
    'security manager': 'Responsabile sicurezza',
    'purchasing manager': 'Responsabile acquisti',
    'health & safety manager': 'Responsabile salute e sicurezza',
    'food safety manager': 'Responsabile sicurezza alimentare',
    'entertainment manager': 'Responsabile intrattenimento',
    'event manager': 'Event manager',
    'event coordinator': 'Coordinatore eventi',
    'wedding coordinator': 'Wedding coordinator',
    'conference coordinator': 'Coordinatore conferenze',
    'activities coordinator': 'Coordinatore attività',
    'entertainment coordinator': 'Coordinatore intrattenimento',
    'dispatch coordinator': 'Coordinatore spedizioni',
    'logistics coordinator': 'Coordinatore logistica',
    'safety coordinator': 'Coordinatore sicurezza',
    'program coordinator': 'Coordinatore programmi',
    'academic coordinator': 'Coordinatore accademico',
    'training coordinator': 'Coordinatore formazione',
    'marketing manager': 'Marketing manager',
    'sales manager': 'Sales manager',
    'revenue manager': 'Revenue manager',
    'hr manager': 'HR manager',
    'hr coordinator': 'HR coordinator',
    'it manager': 'IT manager',
    // ── Front of house / reception ──
    'host': 'Host',
    'hostess': 'Hostess',
    'vip host': 'VIP host',
    'vip hostess': 'VIP hostess',
    'door host': 'Addetto all\'ingresso',
    'lounge host': 'Host di lounge',
    'villa host': 'Host di villa',
    'beach host': 'Host da spiaggia',
    'chalet host': 'Host di chalet',
    'event host': 'Host per eventi',
    'activity host': 'Host attività',
    'activities host': 'Host attività',
    'entertainment host': 'Host di intrattenimento',
    'reception': 'Reception',
    'receptionist': 'Receptionist',
    'spa receptionist': 'Receptionist spa',
    'concierge': 'Concierge',
    'chef concierge': 'Chef concierge',
    'client delivery concierge': 'Concierge consegne',
    'front desk agent': 'Addetto front desk',
    'night auditor': 'Night auditor',
    'bellboy': 'Fattorino',
    'valet': 'Valet',
    // ── Housekeeping ──
    'housekeeper': 'Governante',
    'housekeeping': 'Pulizie',
    'room attendant': 'Cameriere ai piani',
    'turndown attendant': 'Addetto rifacimento camere',
    'laundry attendant': 'Addetto lavanderia',
    'room service attendant': 'Addetto room service',
    'cabin steward': 'Steward di cabina',
    'steward': 'Steward',
    'stewardess': 'Hostess di bordo',
    'deckhand': 'Marinaio',
    // ── Spa / wellness / fitness ──
    'spa therapist': 'Terapista spa',
    'spa attendant': 'Addetto spa',
    'massage therapist': 'Massaggiatore',
    'beauty therapist': 'Estetista',
    'fitness instructor': 'Istruttore fitness',
    'gym instructor': 'Istruttore di palestra',
    'personal trainer': 'Personal trainer',
    'yoga instructor': 'Istruttore di yoga',
    'wellness coach': 'Wellness coach',
    'nutritionist': 'Nutrizionista',
    'dietitian': 'Dietista',
    'membership advisor': 'Consulente abbonamenti',
    // ── Entertainment ──
    'dj': 'DJ',
    'dancer': 'Ballerino',
    'musician': 'Musicista',
    'pianist': 'Pianista',
    'live singer': 'Cantante dal vivo',
    'mc / host': 'MC / Host',
    'performer': 'Performer',
    'stage performer': 'Performer da palco',
    'fire performer': 'Performer del fuoco',
    'character performer': 'Personaggio animatore',
    'kids entertainer': 'Animatore per bambini',
    'entertainer': 'Animatore',
    'wedding entertainer': 'Animatore per matrimoni',
    'showgirl': 'Showgirl',
    'promoter': 'Promoter',
    // ── Delivery / logistics ──
    'delivery driver': 'Autista di consegne',
    'delivery rider': 'Rider',
    'delivery supervisor': 'Supervisore consegne',
    'event delivery assistant': 'Assistente consegne eventi',
    'chauffeur delivery': 'Autista di consegne premium',
    'luxury delivery assistant': 'Assistente consegne di lusso',
    'kitchen dispatcher': 'Addetto alle spedizioni cucina',
    'order packer': 'Addetto imballaggio ordini',
    'setup crew': 'Addetti allestimento',
    'warehouse operative': 'Operatore di magazzino',
    'catering loader': 'Addetto carico catering',
    'menu planner': 'Pianificatore menu',
    'food truck operator': 'Operatore food truck',
    'mobile cook': 'Cuoco mobile',
    'packer': 'Addetto imballaggio',
    // ── Healthcare / support / safety ──
    'cleaner': 'Addetto alle pulizie',
    'janitor': 'Inserviente',
    'cleaning supervisor': 'Supervisore pulizie',
    'porter': 'Portantino',
    'hospitality assistant': 'Assistente ospitalità',
    'catering assistant': 'Assistente catering',
    'guest services': 'Servizi agli ospiti',
    'patient services coordinator': 'Coordinatore servizi pazienti',
    'fire marshal': 'Responsabile antincendio',
    'fire safety officer': 'Addetto sicurezza antincendio',
    'food safety officer': 'Addetto sicurezza alimentare',
    'haccp officer': 'Responsabile HACCP',
    'quality control officer': 'Responsabile controllo qualità',
    'compliance officer': 'Compliance officer',
    'hse officer': 'Addetto HSE',
    'cctv operator': 'Operatore CCTV',
    'security guard': 'Addetto alla sicurezza',
    'security': 'Sicurezza',
    'maintenance engineer': 'Tecnico manutenzione',
    'pool technician': 'Tecnico piscine',
    // ── Events / decoration ──
    'florist': 'Fiorista',
    'floral designer': 'Floral designer',
    'event decorator': 'Decoratore di eventi',
    'venue stylist': 'Venue stylist',
    'wedding decorator': 'Decoratore di matrimoni',
    'av technician': 'Tecnico audio/video',
    'registration staff': 'Staff accoglienza',
    // ── Education / training ──
    'chef instructor': 'Insegnante di cucina',
    'culinary instructor': 'Istruttore culinario',
    'hospitality trainer': 'Formatore di ospitalità',
    'barista trainer': 'Trainer di baristi',
    'school administrator': 'Amministratore scolastico',
    'admissions advisor': 'Consulente ammissioni',
    'ski instructor': 'Maestro di sci',
    'golf pro': 'Istruttore di golf',
    // ── Sales / retail ──
    'cashier': 'Cassiere',
    'crew member': 'Membro del crew',
    // ── Back office ──
    'accountant': 'Contabile',
    'bookkeeper': 'Contabile',
    'financial controller': 'Controller finanziario',
    'payroll specialist': 'Specialista buste paga',
    'administrative assistant': 'Assistente amministrativo',
    'data entry clerk': 'Addetto inserimento dati',
    'recruiter': 'Recruiter',
    'it support specialist': 'Specialista supporto IT',
    'systems administrator': 'Amministratore di sistemi',
    'digital marketing specialist': 'Specialista marketing digitale',
    // ── Generic descriptors (legacy, kept for context labels) ──
    'relocate': 'Trasferimento',
    'restaurant': 'Ristorante',
    'luxury hotel': 'Hotel di lusso',
    'hotel': 'Hotel',
    'cocktail bar': 'Cocktail bar',
    'cafe': 'Caffetteria',
    'catering': 'Catering',
    'hospitality pro': 'Professionista dell\'ospitalità',
    'unknown': 'Sconosciuto',
  },
  'ar': {
    'all': 'الكل',
    // ── Kitchen / Chef roles ──
    'head chef': 'رئيس الطهاة',
    'sous chef': 'سو شيف',
    'senior chef': 'طاهٍ كبير',
    'chef': 'طاهٍ',
    'executive chef': 'الشيف التنفيذي',
    'pastry chef': 'شيف حلويات',
    'line cook': 'طاهي خط',
    'commis chef': 'مساعد طاهٍ',
    'chef de partie': 'شيف دي بارتي',
    'kitchen porter': 'مساعد مطبخ',
    'kitchen manager': 'مدير المطبخ',
    'cook': 'طباخ',
    'prep cook': 'طباخ تحضير',
    'brunch cook': 'طاهي برانش',
    'breakfast cook': 'طاهي فطور',
    'pizzaiolo': 'صانع بيتزا',
    'pizza helper': 'مساعد صانع بيتزا',
    'food runner': 'ناقل طعام',
    'food stylist': 'مصمم طعام',
    'r&d chef': 'شيف البحث والتطوير',
    'recipe developer': 'مطوّر وصفات',
    'production chef': 'شيف إنتاج',
    'cloud kitchen chef': 'شيف مطبخ سحابي',
    'resort chef': 'شيف المنتجع',
    'club chef': 'شيف النادي',
    'villa chef': 'شيف الفيلا',
    'yacht chef': 'شيف اليخت',
    'cruise chef': 'شيف السفينة السياحية',
    'private chef': 'شيف خاص',
    'catering chef': 'شيف تموين',
    'event chef': 'شيف فعاليات',
    'canteen chef': 'شيف مقصف',
    'banquet chef': 'شيف مآدب',
    'airline chef': 'شيف طيران',
    // ── Bakery ──
    'baker': 'خبّاز',
    'artisan baker': 'خبّاز حرفي',
    'bread baker': 'خبّاز',
    'sourdough specialist': 'أخصائي عجين مخمّر',
    'chocolatier': 'صانع شوكولاتة',
    'confectioner': 'صانع حلويات',
    'cake decorator': 'مزخرف كعك',
    'viennoiserie baker': 'خبّاز معجنات فيينية',
    'production baker': 'خبّاز إنتاج',
    'production line lead': 'مسؤول خط إنتاج',
    'quality controller': 'مراقب جودة',
    // ── Service / Waitstaff ──
    'waiter': 'نادل',
    'waitress': 'نادلة',
    'head waiter': 'رئيس النُدُل',
    'senior waiter': 'نادل كبير',
    'server': 'نادل',
    'event waiter': 'نادل فعاليات',
    'wedding server': 'نادل أعراس',
    'banquet server': 'نادل مآدب',
    'catering server': 'نادل تموين',
    'private server': 'نادل خاص',
    "maitre d'": 'ميتر',
    'butler': 'خادم شخصي',
    'villa butler': 'خادم فيلا',
    // ── Bar ──
    'bartender': 'ساقي',
    'bar manager': 'مدير بار',
    'barback': 'مساعد ساقي',
    'barista': 'باريستا',
    'head barista': 'رئيس باريستا',
    'head bartender': 'رئيس سقاة',
    'mixologist': 'خبير كوكتيل',
    'coffee roaster': 'محمّص قهوة',
    'sommelier': 'سقّاء نبيذ',
    'head sommelier': 'كبير سقّائي النبيذ',
    'wine steward': 'مسؤول النبيذ',
    'cellar manager': 'مدير القبو',
    'pub manager': 'مدير حانة',
    'lounge manager': 'مدير صالة',
    'lounge attendant': 'موظف صالة',
    'beach bartender': 'ساقي شاطئي',
    'event bartender': 'ساقي فعاليات',
    'tea specialist': 'أخصائي شاي',
    // ── Management ──
    'manager': 'مدير',
    'restaurant manager': 'مدير مطعم',
    'general manager': 'المدير العام',
    'assistant manager': 'مساعد مدير',
    'floor manager': 'مسؤول الصالة',
    'shift manager': 'مسؤول المناوبة',
    'shift lead': 'قائد المناوبة',
    'shift supervisor': 'مشرف المناوبة',
    'store manager': 'مدير متجر',
    'cafe manager': 'مدير مقهى',
    'club manager': 'مدير نادٍ',
    'beach club manager': 'مدير نادٍ شاطئي',
    'catering manager': 'مدير تموين',
    'catering coordinator': 'منسّق تموين',
    'canteen manager': 'مدير مقصف',
    'banquet manager': 'مدير مآدب',
    'banquet captain': 'كابتن مآدب',
    'operations manager': 'مدير العمليات',
    'office manager': 'مدير مكتب',
    'estate manager': 'مدير ضيعة',
    'villa manager': 'مدير فيلا',
    'fitness manager': 'مدير لياقة',
    'spa manager': 'مدير سبا',
    'f&b manager': 'مدير الأغذية والمشروبات',
    'front office manager': 'مدير مكتب الاستقبال',
    'housekeeping manager': 'مدير التدبير المنزلي',
    'maintenance manager': 'مدير الصيانة',
    'security manager': 'مدير الأمن',
    'purchasing manager': 'مدير المشتريات',
    'health & safety manager': 'مدير الصحة والسلامة',
    'food safety manager': 'مدير سلامة الأغذية',
    'entertainment manager': 'مدير الترفيه',
    'event manager': 'مدير فعاليات',
    'event coordinator': 'منسّق فعاليات',
    'wedding coordinator': 'منسّق أعراس',
    'conference coordinator': 'منسّق مؤتمرات',
    'activities coordinator': 'منسّق أنشطة',
    'entertainment coordinator': 'منسّق ترفيه',
    'dispatch coordinator': 'منسّق إرسال',
    'logistics coordinator': 'منسّق لوجستيات',
    'safety coordinator': 'منسّق سلامة',
    'program coordinator': 'منسّق برامج',
    'academic coordinator': 'منسّق أكاديمي',
    'training coordinator': 'منسّق تدريب',
    'marketing manager': 'مدير تسويق',
    'sales manager': 'مدير مبيعات',
    'revenue manager': 'مدير الإيرادات',
    'hr manager': 'مدير الموارد البشرية',
    'hr coordinator': 'منسّق موارد بشرية',
    'it manager': 'مدير تقنية المعلومات',
    // ── Front of house / reception ──
    'host': 'مضيف',
    'hostess': 'مضيفة',
    'vip host': 'مضيف كبار الشخصيات',
    'vip hostess': 'مضيفة كبار الشخصيات',
    'door host': 'مستقبِل',
    'lounge host': 'مضيف صالة',
    'villa host': 'مضيف فيلا',
    'beach host': 'مضيف شاطئي',
    'chalet host': 'مضيف شاليه',
    'event host': 'مضيف فعاليات',
    'activity host': 'مضيف أنشطة',
    'activities host': 'مضيف أنشطة',
    'entertainment host': 'مضيف ترفيه',
    'reception': 'استقبال',
    'receptionist': 'موظف استقبال',
    'spa receptionist': 'موظف استقبال سبا',
    'concierge': 'كونسيرج',
    'chef concierge': 'رئيس الكونسيرج',
    'client delivery concierge': 'كونسيرج التوصيل',
    'front desk agent': 'موظف مكتب الاستقبال',
    'night auditor': 'مدقق ليلي',
    'bellboy': 'فتى الأمتعة',
    'valet': 'فاليه',
    // ── Housekeeping ──
    'housekeeper': 'عامل تدبير منزلي',
    'housekeeping': 'التدبير المنزلي',
    'room attendant': 'عامل غرف',
    'turndown attendant': 'عامل تجهيز الغرف',
    'laundry attendant': 'عامل مغسلة',
    'room service attendant': 'عامل خدمة الغرف',
    'cabin steward': 'ستيوارد كابينة',
    'steward': 'ستيوارد',
    'stewardess': 'مضيفة بحرية',
    'deckhand': 'بحّار',
    // ── Spa / wellness / fitness ──
    'spa therapist': 'معالج سبا',
    'spa attendant': 'عامل سبا',
    'massage therapist': 'مدلّك',
    'beauty therapist': 'اختصاصي تجميل',
    'fitness instructor': 'مدرّب لياقة',
    'gym instructor': 'مدرّب صالة رياضية',
    'personal trainer': 'مدرّب شخصي',
    'yoga instructor': 'مدرّب يوغا',
    'wellness coach': 'مدرّب عافية',
    'nutritionist': 'أخصائي تغذية',
    'dietitian': 'اختصاصي حمية',
    'membership advisor': 'مستشار عضويات',
    // ── Entertainment ──
    'dj': 'دي جي',
    'dancer': 'راقص',
    'musician': 'موسيقي',
    'pianist': 'عازف بيانو',
    'live singer': 'مغنٍ مباشر',
    'mc / host': 'مقدّم / مضيف',
    'performer': 'فنان أداء',
    'stage performer': 'فنان مسرح',
    'fire performer': 'فنان نار',
    'character performer': 'فنان تأدية شخصيات',
    'kids entertainer': 'مرفه أطفال',
    'entertainer': 'مرفه',
    'wedding entertainer': 'مرفه أعراس',
    'showgirl': 'فنانة استعراض',
    'promoter': 'مروّج',
    // ── Delivery / logistics ──
    'delivery driver': 'سائق توصيل',
    'delivery rider': 'سائق دراجة توصيل',
    'delivery supervisor': 'مشرف توصيل',
    'event delivery assistant': 'مساعد توصيل فعاليات',
    'chauffeur delivery': 'سائق توصيل مميز',
    'luxury delivery assistant': 'مساعد توصيل فاخر',
    'kitchen dispatcher': 'مرسل المطبخ',
    'order packer': 'معبّئ طلبات',
    'setup crew': 'طاقم تجهيز',
    'warehouse operative': 'عامل مستودع',
    'catering loader': 'محمّل تموين',
    'menu planner': 'مخطط قوائم',
    'food truck operator': 'مشغل شاحنة طعام',
    'mobile cook': 'طاهٍ متنقل',
    'packer': 'معبّئ',
    // ── Healthcare / support / safety ──
    'cleaner': 'عامل نظافة',
    'janitor': 'بوّاب',
    'cleaning supervisor': 'مشرف نظافة',
    'porter': 'حمّال',
    'hospitality assistant': 'مساعد ضيافة',
    'catering assistant': 'مساعد تموين',
    'guest services': 'خدمات الضيوف',
    'patient services coordinator': 'منسّق خدمات المرضى',
    'fire marshal': 'مسؤول الحرائق',
    'fire safety officer': 'ضابط السلامة من الحرائق',
    'food safety officer': 'ضابط سلامة الأغذية',
    'haccp officer': 'مسؤول HACCP',
    'quality control officer': 'مسؤول مراقبة الجودة',
    'compliance officer': 'مسؤول امتثال',
    'hse officer': 'ضابط HSE',
    'cctv operator': 'مشغل كاميرات مراقبة',
    'security guard': 'حارس أمن',
    'security': 'الأمن',
    'maintenance engineer': 'مهندس صيانة',
    'pool technician': 'فني حمامات سباحة',
    // ── Events / decoration ──
    'florist': 'بائع زهور',
    'floral designer': 'مصمم زهور',
    'event decorator': 'مصمم ديكور فعاليات',
    'venue stylist': 'مصمم أماكن',
    'wedding decorator': 'مصمم ديكور أعراس',
    'av technician': 'فني صوتيات ومرئيات',
    'registration staff': 'موظفو تسجيل',
    // ── Education / training ──
    'chef instructor': 'مدرّب طهاة',
    'culinary instructor': 'مدرّب طهي',
    'hospitality trainer': 'مدرّب ضيافة',
    'barista trainer': 'مدرّب باريستا',
    'school administrator': 'إداري مدرسة',
    'admissions advisor': 'مستشار قبول',
    'ski instructor': 'مدرّب تزلج',
    'golf pro': 'مدرّب جولف',
    // ── Sales / retail ──
    'cashier': 'أمين صندوق',
    'crew member': 'عضو طاقم',
    // ── Back office ──
    'accountant': 'محاسب',
    'bookkeeper': 'ماسك دفاتر',
    'financial controller': 'مراقب مالي',
    'payroll specialist': 'أخصائي رواتب',
    'administrative assistant': 'مساعد إداري',
    'data entry clerk': 'مدخل بيانات',
    'recruiter': 'مسؤول توظيف',
    'it support specialist': 'أخصائي دعم تقني',
    'systems administrator': 'مدير أنظمة',
    'digital marketing specialist': 'أخصائي تسويق رقمي',
    // ── Generic descriptors (legacy) ──
    'relocate': 'انتقال',
    'restaurant': 'مطعم',
    'luxury hotel': 'فندق فاخر',
    'hotel': 'فندق',
    'cocktail bar': 'بار كوكتيل',
    'cafe': 'مقهى',
    'catering': 'تموين',
    'hospitality pro': 'محترف ضيافة',
    'unknown': 'غير معروف',
  },
  'es': {
    'all': 'Todos',
    // ── Kitchen / Chef roles ──
    'head chef': 'Jefe de cocina',
    'sous chef': 'Sous chef',
    'senior chef': 'Chef senior',
    'chef': 'Chef',
    'executive chef': 'Chef ejecutivo',
    'pastry chef': 'Pastelero',
    'line cook': 'Cocinero de línea',
    'commis chef': 'Commis de cocina',
    'chef de partie': 'Chef de partie',
    'kitchen porter': 'Ayudante de cocina',
    'kitchen manager': 'Responsable de cocina',
    'cook': 'Cocinero',
    'prep cook': 'Cocinero de preparación',
    'brunch cook': 'Cocinero de brunch',
    'breakfast cook': 'Cocinero de desayunos',
    'pizzaiolo': 'Pizzero',
    'pizza helper': 'Ayudante de pizzero',
    'food runner': 'Runner de sala',
    'food stylist': 'Estilista gastronómico',
    'r&d chef': 'Chef de I+D',
    'recipe developer': 'Desarrollador de recetas',
    'production chef': 'Chef de producción',
    'cloud kitchen chef': 'Chef de cloud kitchen',
    'resort chef': 'Chef de resort',
    'club chef': 'Chef de club',
    'villa chef': 'Chef de villa',
    'yacht chef': 'Chef de yate',
    'cruise chef': 'Chef de crucero',
    'private chef': 'Chef privado',
    'catering chef': 'Chef de catering',
    'event chef': 'Chef de eventos',
    'canteen chef': 'Chef de comedor',
    'banquet chef': 'Chef de banquetes',
    'airline chef': 'Chef aéreo',
    // ── Bakery ──
    'baker': 'Panadero',
    'artisan baker': 'Panadero artesanal',
    'bread baker': 'Panadero',
    'sourdough specialist': 'Especialista en masa madre',
    'chocolatier': 'Chocolatero',
    'confectioner': 'Confitero',
    'cake decorator': 'Decorador de tartas',
    'viennoiserie baker': 'Panadero de bollería vienesa',
    'production baker': 'Panadero de producción',
    'production line lead': 'Jefe de línea de producción',
    'quality controller': 'Controlador de calidad',
    // ── Service / Waitstaff ──
    'waiter': 'Camarero',
    'waitress': 'Camarera',
    'head waiter': 'Jefe de camareros',
    'senior waiter': 'Camarero senior',
    'server': 'Camarero',
    'event waiter': 'Camarero de eventos',
    'wedding server': 'Camarero de bodas',
    'banquet server': 'Camarero de banquetes',
    'catering server': 'Camarero de catering',
    'private server': 'Camarero privado',
    "maitre d'": 'Maître',
    'butler': 'Mayordomo',
    'villa butler': 'Mayordomo de villa',
    // ── Bar ──
    'bartender': 'Bartender',
    'bar manager': 'Responsable de bar',
    'barback': 'Ayudante de bartender',
    'barista': 'Barista',
    'head barista': 'Jefe de baristas',
    'head bartender': 'Jefe de bartenders',
    'mixologist': 'Mixólogo',
    'coffee roaster': 'Tostador de café',
    'sommelier': 'Sumiller',
    'head sommelier': 'Jefe de sumilleres',
    'wine steward': 'Encargado de vinos',
    'cellar manager': 'Responsable de bodega',
    'pub manager': 'Responsable de pub',
    'lounge manager': 'Responsable de lounge',
    'lounge attendant': 'Auxiliar de lounge',
    'beach bartender': 'Bartender de playa',
    'event bartender': 'Bartender de eventos',
    'tea specialist': 'Especialista en té',
    // ── Management ──
    'manager': 'Manager',
    'restaurant manager': 'Responsable de restaurante',
    'general manager': 'Director general',
    'assistant manager': 'Subdirector',
    'floor manager': 'Responsable de sala',
    'shift manager': 'Jefe de turno',
    'shift lead': 'Jefe de turno',
    'shift supervisor': 'Supervisor de turno',
    'store manager': 'Responsable de tienda',
    'cafe manager': 'Responsable de cafetería',
    'club manager': 'Responsable de club',
    'beach club manager': 'Responsable de beach club',
    'catering manager': 'Responsable de catering',
    'catering coordinator': 'Coordinador de catering',
    'canteen manager': 'Responsable de comedor',
    'banquet manager': 'Responsable de banquetes',
    'banquet captain': 'Capitán de banquetes',
    'operations manager': 'Responsable de operaciones',
    'office manager': 'Office manager',
    'estate manager': 'Estate manager',
    'villa manager': 'Responsable de villa',
    'fitness manager': 'Responsable de fitness',
    'spa manager': 'Responsable de spa',
    'f&b manager': 'Responsable de F&B',
    'front office manager': 'Responsable de recepción',
    'housekeeping manager': 'Responsable de housekeeping',
    'maintenance manager': 'Responsable de mantenimiento',
    'security manager': 'Responsable de seguridad',
    'purchasing manager': 'Responsable de compras',
    'health & safety manager': 'Responsable de salud y seguridad',
    'food safety manager': 'Responsable de seguridad alimentaria',
    'entertainment manager': 'Responsable de entretenimiento',
    'event manager': 'Responsable de eventos',
    'event coordinator': 'Coordinador de eventos',
    'wedding coordinator': 'Wedding coordinator',
    'conference coordinator': 'Coordinador de conferencias',
    'activities coordinator': 'Coordinador de actividades',
    'entertainment coordinator': 'Coordinador de entretenimiento',
    'dispatch coordinator': 'Coordinador de envíos',
    'logistics coordinator': 'Coordinador de logística',
    'safety coordinator': 'Coordinador de seguridad',
    'program coordinator': 'Coordinador de programas',
    'academic coordinator': 'Coordinador académico',
    'training coordinator': 'Coordinador de formación',
    'marketing manager': 'Responsable de marketing',
    'sales manager': 'Responsable de ventas',
    'revenue manager': 'Responsable de ingresos',
    'hr manager': 'Responsable de RRHH',
    'hr coordinator': 'Coordinador de RRHH',
    'it manager': 'Responsable de TI',
    // ── Front of house / reception ──
    'host': 'Host',
    'hostess': 'Hostess',
    'vip host': 'Host VIP',
    'vip hostess': 'Hostess VIP',
    'door host': 'Recepcionista de puerta',
    'lounge host': 'Host de lounge',
    'villa host': 'Host de villa',
    'beach host': 'Host de playa',
    'chalet host': 'Host de chalet',
    'event host': 'Host de eventos',
    'activity host': 'Host de actividades',
    'activities host': 'Host de actividades',
    'entertainment host': 'Host de entretenimiento',
    'reception': 'Recepción',
    'receptionist': 'Recepcionista',
    'spa receptionist': 'Recepcionista de spa',
    'concierge': 'Conserje',
    'chef concierge': 'Jefe de conserjería',
    'client delivery concierge': 'Conserje de entregas',
    'front desk agent': 'Agente de recepción',
    'night auditor': 'Auditor nocturno',
    'bellboy': 'Botones',
    'valet': 'Aparcacoches',
    // ── Housekeeping ──
    'housekeeper': 'Gobernanta',
    'housekeeping': 'Limpieza',
    'room attendant': 'Camarera de pisos',
    'turndown attendant': 'Auxiliar de arreglo de habitaciones',
    'laundry attendant': 'Auxiliar de lavandería',
    'room service attendant': 'Auxiliar de servicio de habitaciones',
    'cabin steward': 'Steward de camarote',
    'steward': 'Steward',
    'stewardess': 'Azafata de a bordo',
    'deckhand': 'Marinero de cubierta',
    // ── Spa / wellness / fitness ──
    'spa therapist': 'Terapeuta de spa',
    'spa attendant': 'Auxiliar de spa',
    'massage therapist': 'Masajista',
    'beauty therapist': 'Esteticista',
    'fitness instructor': 'Instructor de fitness',
    'gym instructor': 'Instructor de gimnasio',
    'personal trainer': 'Entrenador personal',
    'yoga instructor': 'Instructor de yoga',
    'wellness coach': 'Coach de bienestar',
    'nutritionist': 'Nutricionista',
    'dietitian': 'Dietista',
    'membership advisor': 'Asesor de membresías',
    // ── Entertainment ──
    'dj': 'DJ',
    'dancer': 'Bailarín',
    'musician': 'Músico',
    'pianist': 'Pianista',
    'live singer': 'Cantante en vivo',
    'mc / host': 'MC / Presentador',
    'performer': 'Artista',
    'stage performer': 'Artista de escenario',
    'fire performer': 'Artista del fuego',
    'character performer': 'Actor de personajes',
    'kids entertainer': 'Animador infantil',
    'entertainer': 'Animador',
    'wedding entertainer': 'Animador de bodas',
    'showgirl': 'Showgirl',
    'promoter': 'Promotor',
    // ── Delivery / logistics ──
    'delivery driver': 'Conductor de reparto',
    'delivery rider': 'Rider',
    'delivery supervisor': 'Supervisor de reparto',
    'event delivery assistant': 'Asistente de reparto de eventos',
    'chauffeur delivery': 'Chófer de reparto premium',
    'luxury delivery assistant': 'Asistente de reparto de lujo',
    'kitchen dispatcher': 'Encargado de envíos de cocina',
    'order packer': 'Empaquetador de pedidos',
    'setup crew': 'Equipo de montaje',
    'warehouse operative': 'Operario de almacén',
    'catering loader': 'Cargador de catering',
    'menu planner': 'Planificador de menús',
    'food truck operator': 'Operador de food truck',
    'mobile cook': 'Cocinero móvil',
    'packer': 'Empaquetador',
    // ── Healthcare / support / safety ──
    'cleaner': 'Limpiador',
    'janitor': 'Conserje de limpieza',
    'cleaning supervisor': 'Supervisor de limpieza',
    'porter': 'Mozo',
    'hospitality assistant': 'Asistente de hostelería',
    'catering assistant': 'Asistente de catering',
    'guest services': 'Servicios al cliente',
    'patient services coordinator': 'Coordinador de servicios al paciente',
    'fire marshal': 'Jefe de incendios',
    'fire safety officer': 'Responsable de seguridad contra incendios',
    'food safety officer': 'Responsable de seguridad alimentaria',
    'haccp officer': 'Responsable HACCP',
    'quality control officer': 'Responsable de control de calidad',
    'compliance officer': 'Oficial de cumplimiento',
    'hse officer': 'Oficial HSE',
    'cctv operator': 'Operador de CCTV',
    'security guard': 'Vigilante de seguridad',
    'security': 'Seguridad',
    'maintenance engineer': 'Técnico de mantenimiento',
    'pool technician': 'Técnico de piscinas',
    // ── Events / decoration ──
    'florist': 'Florista',
    'floral designer': 'Diseñador floral',
    'event decorator': 'Decorador de eventos',
    'venue stylist': 'Estilista de espacios',
    'wedding decorator': 'Decorador de bodas',
    'av technician': 'Técnico audiovisual',
    'registration staff': 'Personal de acreditaciones',
    // ── Education / training ──
    'chef instructor': 'Profesor de cocina',
    'culinary instructor': 'Instructor culinario',
    'hospitality trainer': 'Formador de hostelería',
    'barista trainer': 'Formador de baristas',
    'school administrator': 'Administrador escolar',
    'admissions advisor': 'Asesor de admisiones',
    'ski instructor': 'Monitor de esquí',
    'golf pro': 'Profesional de golf',
    // ── Sales / retail ──
    'cashier': 'Cajero',
    'crew member': 'Miembro del equipo',
    // ── Back office ──
    'accountant': 'Contable',
    'bookkeeper': 'Contable',
    'financial controller': 'Controller financiero',
    'payroll specialist': 'Especialista en nóminas',
    'administrative assistant': 'Asistente administrativo',
    'data entry clerk': 'Administrativo de datos',
    'recruiter': 'Reclutador',
    'it support specialist': 'Especialista en soporte TI',
    'systems administrator': 'Administrador de sistemas',
    'digital marketing specialist': 'Especialista en marketing digital',
    // ── Generic descriptors (legacy) ──
    'relocate': 'Reubicación',
    'restaurant': 'Restaurante',
    'luxury hotel': 'Hotel de lujo',
    'hotel': 'Hotel',
    'cocktail bar': 'Bar de cócteles',
    'cafe': 'Cafetería',
    'catering': 'Catering',
    'hospitality pro': 'Profesional de hostelería',
    'unknown': 'Desconocido',
  },
};

/// Localized label for an interview-format display string
/// (`Video`, `In person`, `Phone call`, etc).
String localizedInterviewFormat(BuildContext context, String format) {
  final l = AppLocalizations.of(context);
  final key = format.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  return switch (key) {
    'video' || 'videocall' => l.videoLabel,
    'inperson' => l.inPersonInterview,
    'phone' || 'phonecall' => l.phoneCallInterview,
    _ => format,
  };
}

/// Localized label for a viewer-kind string used by Post Insights.
///
/// Accepts the four canonical English labels (`Business`, `Candidate`,
/// `Recruiter`, `Hiring Manager`) or their plural equivalents. Any
/// unknown / free-form input is returned unchanged so the UI still
/// renders the raw value.
String localizedViewerKind(BuildContext context, String raw) {
  final l = AppLocalizations.of(context);
  final key = raw.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  return switch (key) {
    'business' => l.viewerKindBusiness,
    'candidate' => l.viewerKindCandidate,
    'recruiter' => l.viewerKindRecruiter,
    'hiringmanager' => l.viewerKindHiringManager,
    'businesses' => l.viewerKindBusinessesPlural,
    'candidates' => l.viewerKindCandidatesPlural,
    'recruiters' => l.viewerKindRecruitersPlural,
    'hiringmanagers' => l.viewerKindHiringManagersPlural,
    _ => raw,
  };
}
