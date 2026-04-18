// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Willkommen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createBusinessAccount => 'Unternehmenskonto erstellen';

  @override
  String get alreadyHaveAccount => 'Sie haben bereits ein Konto?';

  @override
  String get email => 'E-Mail-Adresse';

  @override
  String get password => 'Passwort';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get done => 'Fertig';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get search => 'Suchen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get apply => 'Bewerben';

  @override
  String get clear => 'Löschen';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get home => 'Start';

  @override
  String get jobs => 'Jobs';

  @override
  String get messages => 'Nachrichten';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get logout => 'Abmelden';

  @override
  String get categoryAndRole => 'Kategorie & Funktion';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get subcategory => 'Unterkategorie';

  @override
  String get role => 'Funktion';

  @override
  String get recentSearches => 'Letzte Suchen';

  @override
  String noResultsFor(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get mostPopular => 'Beliebteste';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get selectVenueTypeAndRole =>
      'Betriebsart und gewünschte Funktion auswählen';

  @override
  String get selectCategoryAndRole => 'Kategorie und Funktion auswählen';

  @override
  String get businessDetails => 'Unternehmensdaten';

  @override
  String get yourDetails => 'Ihre Daten';

  @override
  String get companyName => 'Firmenname';

  @override
  String get contactPerson => 'Ansprechpartner';

  @override
  String get location => 'Standort';

  @override
  String get website => 'Website';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get yearsExperience => 'Jahre Berufserfahrung';

  @override
  String get languagesSpoken => 'Gesprochene Sprachen';

  @override
  String get jobType => 'Jobart';

  @override
  String get jobTypeFullTime => 'Vollzeit';

  @override
  String get jobTypePartTime => 'Teilzeit';

  @override
  String get jobTypeTemporary => 'Befristet';

  @override
  String get jobTypeFreelance => 'Freiberuflich';

  @override
  String get openToInternational => 'Offen für internationale Kandidaten';

  @override
  String get passwordHint => 'Passwort (mindestens 8 Zeichen)';

  @override
  String get termsOfServiceNote =>
      'Mit der Erstellung eines Kontos akzeptieren Sie unsere Nutzungsbedingungen und Datenschutzerklärung.';

  @override
  String get networkError => 'Netzwerkfehler';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get loading => 'Wird geladen …';

  @override
  String get errorGeneric =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get joinAsCandidate => 'Als Kandidat registrieren';

  @override
  String get joinAsBusiness => 'Als Unternehmen registrieren';

  @override
  String get findYourNextRole =>
      'Finden Sie Ihre nächste Position im Gastgewerbe';

  @override
  String get candidateLoginSubtitle =>
      'Vernetzen Sie sich mit Top-Arbeitgebern in London, Dubai und weltweit.';

  @override
  String get businessLoginSubtitle =>
      'Erreichen Sie erstklassige Fachkräfte und bauen Sie Ihr Team aus.';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get lookingForStaff => 'Suchen Sie Personal? ';

  @override
  String get lookingForJob => 'Suchen Sie einen Job? ';

  @override
  String get switchToBusiness => 'Zu Unternehmen wechseln';

  @override
  String get switchToCandidate => 'Zu Kandidat wechseln';

  @override
  String get createYourProfile =>
      'Erstellen Sie Ihr Profil und werden Sie von Top-Arbeitgebern entdeckt.';

  @override
  String get createBusinessProfile =>
      'Erstellen Sie Ihr Unternehmensprofil und stellen Sie Top-Fachkräfte ein.';

  @override
  String get locationCityCountry => 'Standort (Stadt, Land)';

  @override
  String get termsAgreement =>
      'Mit der Erstellung eines Kontos akzeptieren Sie unsere Nutzungsbedingungen und Datenschutzerklärung.';

  @override
  String get searchHospitalityHint =>
      'Kategorie, Unterkategorie oder Funktion suchen …';

  @override
  String get mostCommonRoles => 'Häufigste Funktionen';

  @override
  String get allRoles => 'Alle Funktionen';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vorschläge',
      one: '1 Vorschlag',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unterkategorien',
      one: '1 Unterkategorie',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Funktionen',
      one: '1 Funktion',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Kategorie';

  @override
  String get kindSubcategory => 'Unterkategorie';

  @override
  String get kindRole => 'Funktion';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordSubtitle =>
      'Geben Sie Ihre E-Mail ein, und wir senden Ihnen einen Link zum Zurücksetzen.';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get resetEmailSent =>
      'Falls ein Konto mit dieser E-Mail existiert, wurde ein Link gesendet.';

  @override
  String get profileSetupTitle => 'Profil vervollständigen';

  @override
  String get profileSetupSubtitle =>
      'Ein vollständiges Profil wird schneller entdeckt.';

  @override
  String get uploadPhoto => 'Foto hochladen';

  @override
  String get uploadCV => 'Lebenslauf hochladen';

  @override
  String get skipForNow => 'Vorerst überspringen';

  @override
  String get finish => 'Fertigstellen';

  @override
  String get noInternet =>
      'Keine Internetverbindung. Bitte prüfen Sie Ihr Netzwerk.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get emptyJobs => 'Noch keine Jobs';

  @override
  String get emptyApplications => 'Noch keine Bewerbungen';

  @override
  String get emptyMessages => 'Noch keine Nachrichten';

  @override
  String get emptyNotifications => 'Alles auf dem neuesten Stand';

  @override
  String get onboardingRoleTitle => 'Welche Funktion suchen Sie?';

  @override
  String get onboardingRoleSubtitle => 'Wählen Sie alle zutreffenden aus';

  @override
  String get onboardingExperienceTitle => 'Wie viel Erfahrung haben Sie?';

  @override
  String get onboardingLocationTitle => 'Wo sind Sie ansässig?';

  @override
  String get onboardingLocationHint => 'Geben Sie Ihre Stadt oder PLZ ein';

  @override
  String get useMyCurrentLocation => 'Meinen aktuellen Standort verwenden';

  @override
  String get onboardingAvailabilityTitle => 'Was suchen Sie?';

  @override
  String get finishSetup => 'Einrichtung abschließen';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get findJobs => 'Jobs finden';

  @override
  String get applications => 'Bewerbungen';

  @override
  String get community => 'Community';

  @override
  String get recommendedForYou => 'Für Sie empfohlen';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get searchJobsHint => 'Jobs, Funktionen, Orte suchen …';

  @override
  String get searchJobs => 'Jobs suchen';

  @override
  String get postedJob => 'Veröffentlicht';

  @override
  String get applyNow => 'Jetzt bewerben';

  @override
  String get applied => 'Beworben';

  @override
  String get saveJob => 'Speichern';

  @override
  String get saved => 'Gespeichert';

  @override
  String get jobDescription => 'Stellenbeschreibung';

  @override
  String get requirements => 'Anforderungen';

  @override
  String get benefits => 'Leistungen';

  @override
  String get salary => 'Gehalt';

  @override
  String get contract => 'Vertrag';

  @override
  String get schedule => 'Arbeitszeit';

  @override
  String get viewCompany => 'Unternehmen ansehen';

  @override
  String get interview => 'Vorstellungsgespräch';

  @override
  String get interviews => 'Vorstellungsgespräche';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get matches => 'Matches';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Entdecken';

  @override
  String get shortlist => 'Favoriten';

  @override
  String get message => 'Nachricht';

  @override
  String get messageCandidate => 'Nachricht';

  @override
  String get nextInterview => 'Nächstes Vorstellungsgespräch';

  @override
  String get loadingDashboard => 'Dashboard wird geladen …';

  @override
  String get tryAgainCta => 'Erneut versuchen';

  @override
  String get careerDashboard => 'KARRIERE-DASHBOARD';

  @override
  String get yourNextInterview => 'Ihr nächstes Gespräch\nsteht bevor';

  @override
  String get yourCareerTakingOff => 'Ihre Karriere\nhebt ab';

  @override
  String get yourCareerOnTheMove => 'Ihre Karriere\nist in Bewegung';

  @override
  String get yourJourneyStartsHere => 'Ihr Weg\nbeginnt hier';

  @override
  String get applyFirstJob =>
      'Bewerben Sie sich auf Ihren ersten Job, um zu starten';

  @override
  String get interviewComingUp => 'Vorstellungsgespräch steht an';

  @override
  String get unlockPlagitPremium => 'Plagit Premium freischalten';

  @override
  String get premiumSubtitle =>
      'Heben Sie sich bei Top-Betrieben ab – schnellere Matches';

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get premiumActiveSubtitle =>
      'Prioritäts-Sichtbarkeit aktiviert · Abo verwalten';

  @override
  String get noJobsFound => 'Keine Jobs zu Ihrer Suche gefunden';

  @override
  String get noApplicationsYet => 'Noch keine Bewerbungen';

  @override
  String get startApplying => 'Entdecken Sie Jobs und bewerben Sie sich';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten';

  @override
  String get allCaughtUp => 'Alles auf dem neuesten Stand';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

  @override
  String get about => 'Über';

  @override
  String get experience => 'Erfahrung';

  @override
  String get skills => 'Fähigkeiten';

  @override
  String get languages => 'Sprachen';

  @override
  String get availability => 'Verfügbarkeit';

  @override
  String get verified => 'Verifiziert';

  @override
  String get totalViews => 'Aufrufe gesamt';

  @override
  String get verifiedVenuePrefix => 'Verifiziert';

  @override
  String get notVerified => 'Nicht verifiziert';

  @override
  String get pendingReview => 'Prüfung ausstehend';

  @override
  String get viewProfile => 'Profil ansehen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get share => 'Teilen';

  @override
  String get report => 'Melden';

  @override
  String get block => 'Blockieren';

  @override
  String get typeMessage => 'Nachricht schreiben …';

  @override
  String get send => 'Senden';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get now => 'jetzt';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Min.',
      one: 'vor 1 Min.',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Std.',
      one: 'vor 1 Std.',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count T.',
      one: 'vor 1 T.',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filter';

  @override
  String get refineSearch => 'Suche verfeinern';

  @override
  String get distance => 'Entfernung';

  @override
  String get applyFilters => 'Filter anwenden';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String noResultsTitle(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get noResultsSubtitle =>
      'Versuchen Sie ein anderes Stichwort oder löschen Sie die Suche.';

  @override
  String get recentSearchesEmptyTitle => 'Keine letzten Suchen';

  @override
  String get recentSearchesEmptyHint => 'Ihre letzten Suchen erscheinen hier';

  @override
  String get allJobs => 'Alle Jobs';

  @override
  String get nearby => 'In der Nähe';

  @override
  String get saved2 => 'Gespeichert';

  @override
  String get remote => 'Remote';

  @override
  String get inPerson => 'Vor Ort';

  @override
  String get aboutTheJob => 'Über den Job';

  @override
  String get aboutCompany => 'Über das Unternehmen';

  @override
  String get applyForJob => 'Auf diesen Job bewerben';

  @override
  String get unsaveJob => 'Entfernen';

  @override
  String get noJobsNearby => 'Keine Jobs in der Nähe';

  @override
  String get noSavedJobs => 'Keine gespeicherten Jobs';

  @override
  String get adjustFilters => 'Passen Sie die Filter an, um mehr Jobs zu sehen';

  @override
  String get fullTime => 'Vollzeit';

  @override
  String get partTime => 'Teilzeit';

  @override
  String get temporary => 'Befristet';

  @override
  String get freelance => 'Freiberuflich';

  @override
  String postedAgo(String time) {
    return 'Veröffentlicht $time';
  }

  @override
  String kmAway(String km) {
    return '$km km entfernt';
  }

  @override
  String get jobDetails => 'Job-Details';

  @override
  String get aboutThisRole => 'Über diese Position';

  @override
  String get aboutTheBusiness => 'Über den Betrieb';

  @override
  String get urgentHiring => 'Dringend gesucht';

  @override
  String get distanceRadius => 'Umkreis';

  @override
  String get contractType => 'Vertragsart';

  @override
  String get shiftType => 'Schichtart';

  @override
  String get all => 'Alle';

  @override
  String get casual => 'Aushilfe';

  @override
  String get seasonal => 'Saisonal';

  @override
  String get morning => 'Morgens';

  @override
  String get afternoon => 'Nachmittags';

  @override
  String get evening => 'Abends';

  @override
  String get night => 'Nachts';

  @override
  String get startDate => 'Startdatum';

  @override
  String get shiftHours => 'Schichtzeiten';

  @override
  String get category => 'Kategorie';

  @override
  String get venueType => 'Betriebsart';

  @override
  String get employment => 'Anstellung';

  @override
  String get pay => 'Vergütung';

  @override
  String get duration => 'Dauer';

  @override
  String get weeklyHours => 'Wochenstunden';

  @override
  String get businessLocation => 'Betriebsstandort';

  @override
  String get jobViews => 'Job-Aufrufe';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stellen',
      one: '1 Stelle',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'Meine Bewerbungen';

  @override
  String get active => 'Aktiv';

  @override
  String get interviewStatus => 'Vorstellungsgespräch';

  @override
  String get rejected => 'Abgelehnt';

  @override
  String get offer => 'Angebot';

  @override
  String appliedOn(String date) {
    return 'Beworben am $date';
  }

  @override
  String get viewJob => 'Job ansehen';

  @override
  String get withdraw => 'Bewerbung zurückziehen';

  @override
  String get applicationStatus => 'Bewerbungsstatus';

  @override
  String get noConversations => 'Noch keine Unterhaltungen';

  @override
  String get startConversation => 'Antworten Sie auf einen Job, um zu chatten';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String lastSeen(String time) {
    return 'Zuletzt gesehen $time';
  }

  @override
  String get newNotification => 'Neu';

  @override
  String get markAllRead => 'Alle als gelesen markieren';

  @override
  String get yourProfile => 'Ihr Profil';

  @override
  String completionPercent(int percent) {
    return '$percent% vollständig';
  }

  @override
  String get personalDetails => 'Persönliche Daten';

  @override
  String get phone => 'Telefon';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get addCV => 'Lebenslauf hinzufügen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get logoutConfirm => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get subscription => 'Abonnement';

  @override
  String get support => 'Support';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get terms => 'Nutzungsbedingungen';

  @override
  String get applicationDetails => 'Bewerbungsdetails';

  @override
  String get timeline => 'Verlauf';

  @override
  String get submitted => 'Eingereicht';

  @override
  String get underReview => 'In Prüfung';

  @override
  String get interviewScheduled => 'Gespräch geplant';

  @override
  String get offerExtended => 'Angebot unterbreitet';

  @override
  String get withdrawApp => 'Bewerbung zurückziehen';

  @override
  String get withdrawConfirm =>
      'Möchten Sie diese Bewerbung wirklich zurückziehen?';

  @override
  String get applicationWithdrawn => 'Bewerbung zurückgezogen';

  @override
  String get statusApplied => 'Beworben';

  @override
  String get statusInReview => 'In Prüfung';

  @override
  String get statusInterview => 'Vorstellungsgespräch';

  @override
  String get statusHired => 'Eingestellt';

  @override
  String get statusClosed => 'Geschlossen';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String get statusOffer => 'Angebot';

  @override
  String get messagesSearch => 'Nachrichten suchen …';

  @override
  String get noMessagesTitle => 'Noch keine Nachrichten';

  @override
  String get noMessagesSubtitle => 'Antworten Sie auf einen Job, um zu chatten';

  @override
  String get youOnline => 'Sie sind online';

  @override
  String get noNotificationsTitle => 'Noch keine Benachrichtigungen';

  @override
  String get noNotificationsSubtitle =>
      'Wir informieren Sie, sobald etwas passiert';

  @override
  String get today2 => 'Heute';

  @override
  String get earlier => 'Früher';

  @override
  String get completeYourProfile => 'Profil vervollständigen';

  @override
  String get profileCompletion => 'Profilvollständigkeit';

  @override
  String get personalInfo => 'Persönliche Infos';

  @override
  String get professional => 'Beruflich';

  @override
  String get preferences => 'Präferenzen';

  @override
  String get documents => 'Dokumente';

  @override
  String get myCV => 'Mein Lebenslauf';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Sprachen hinzufügen';

  @override
  String get addExperience => 'Erfahrung hinzufügen';

  @override
  String get addAvailability => 'Verfügbarkeit hinzufügen';

  @override
  String get matchesTitle => 'Ihre Matches';

  @override
  String get noMatchesTitle => 'Noch keine Matches';

  @override
  String get noMatchesSubtitle =>
      'Bewerben Sie sich weiter – Ihre Matches erscheinen hier';

  @override
  String get interestedBusinesses => 'Interessierte Unternehmen';

  @override
  String get accept => 'Annehmen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get newMatch => 'Neues Match';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'Aktuell keine neuen Unternehmen';

  @override
  String get quickPlugSubtitle =>
      'Schauen Sie später für neue Möglichkeiten vorbei';

  @override
  String get uploadYourCV => 'Laden Sie Ihren Lebenslauf hoch';

  @override
  String get cvSubtitle =>
      'Fügen Sie einen Lebenslauf hinzu, um sich schneller zu bewerben';

  @override
  String get chooseFile => 'Datei auswählen';

  @override
  String get removeCV => 'Lebenslauf entfernen';

  @override
  String get noCVUploaded => 'Noch kein Lebenslauf hochgeladen';

  @override
  String get discoverCompanies => 'Unternehmen entdecken';

  @override
  String get exploreSubtitle => 'Entdecken Sie Top-Betriebe des Gastgewerbes';

  @override
  String get follow => 'Folgen';

  @override
  String get following => 'Folgt';

  @override
  String get view => 'Ansehen';

  @override
  String get selectLanguages => 'Sprachen auswählen';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get allLanguages => 'Alle Sprachen';

  @override
  String get uploadCVBig =>
      'Laden Sie Ihren Lebenslauf hoch, um Ihr Profil automatisch auszufüllen und Zeit zu sparen.';

  @override
  String get supportedFormats => 'Unterstützte Formate: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Manuell ausfüllen';

  @override
  String get fillManuallySubtitle =>
      'Geben Sie Ihre Daten selbst ein und vervollständigen Sie Ihr Profil Schritt für Schritt.';

  @override
  String get photoUploadSoon =>
      'Foto-Upload folgt in Kürze – nutzen Sie bis dahin einen professionellen Avatar.';

  @override
  String get yourCV => 'Ihr Lebenslauf';

  @override
  String get aboutYou => 'Über Sie';

  @override
  String get optional => 'Optional';

  @override
  String get completeProfile => 'Profil vervollständigen';

  @override
  String get openToRelocation => 'Offen für Umzug';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Angenommen';

  @override
  String get deny => 'Ablehnen';

  @override
  String get featured => 'Empfohlen';

  @override
  String get reviewYourProfile => 'Profil prüfen';

  @override
  String get nothingSavedYet => 'Nichts wird gespeichert, bis Sie bestätigen.';

  @override
  String get editAnyField =>
      'Sie können jedes extrahierte Feld vor dem Speichern bearbeiten.';

  @override
  String get saveToProfile => 'In Profil speichern';

  @override
  String get findCompanies => 'Unternehmen finden';

  @override
  String get mapView => 'Kartenansicht';

  @override
  String get mapComingSoon => 'Kartenansicht folgt in Kürze.';

  @override
  String get noCompaniesFound => 'Keine Unternehmen gefunden';

  @override
  String get tryWiderRadius =>
      'Versuchen Sie einen größeren Radius oder eine andere Kategorie.';

  @override
  String get verifiedOnly => 'Nur verifizierte';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String get available => 'Verfügbar';

  @override
  String lookingFor(String role) {
    return 'Sucht: $role';
  }

  @override
  String get boostMyProfile => 'Profil boosten';

  @override
  String get openToRelocationTravel => 'Offen für Umzug / Reisen';

  @override
  String get tellEmployersAboutYourself =>
      'Erzählen Sie Arbeitgebern von sich …';

  @override
  String get profileUpdated => 'Profil aktualisiert';

  @override
  String get contractPreference => 'Vertragspräferenz';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get languagePickerSoon => 'Sprachauswahl folgt in Kürze';

  @override
  String get selectCategoryRoleShort => 'Kategorie & Funktion auswählen';

  @override
  String get cvUploadSoon => 'Lebenslauf-Upload folgt in Kürze';

  @override
  String get restorePurchasesSoon => 'Käufe wiederherstellen folgt in Kürze';

  @override
  String get photoUploadShort => 'Foto-Upload folgt in Kürze';

  @override
  String get hireBestTalent => 'Stellen Sie die besten Gastgewerbe-Talente ein';

  @override
  String get businessLoginSub =>
      'Jobs inserieren und verifizierte Kandidaten finden.';

  @override
  String get lookingForWork => 'Suchen Sie Arbeit? ';

  @override
  String get postJob => 'Job inserieren';

  @override
  String get editJob => 'Job bearbeiten';

  @override
  String get jobTitle => 'Jobtitel';

  @override
  String get jobDescription2 => 'Stellenbeschreibung';

  @override
  String get publish => 'Veröffentlichen';

  @override
  String get saveDraft => 'Entwurf speichern';

  @override
  String get applicantsTitle => 'Bewerber';

  @override
  String get newApplicants => 'Neue Bewerber';

  @override
  String get noApplicantsYet => 'Noch keine Bewerber';

  @override
  String get noApplicantsSubtitle =>
      'Bewerber erscheinen hier, sobald sie sich bewerben.';

  @override
  String get scheduleInterview => 'Gespräch planen';

  @override
  String get sendInvite => 'Einladung senden';

  @override
  String get interviewSent => 'Einladung zum Gespräch gesendet';

  @override
  String get rejectCandidate => 'Ablehnen';

  @override
  String get shortlistCandidate => 'Zu Favoriten';

  @override
  String get hiringDashboard => 'RECRUITING-DASHBOARD';

  @override
  String get yourPipelineActive => 'Ihre Pipeline\nist aktiv';

  @override
  String get postJobToStart =>
      'Inserieren Sie einen Job, um mit dem Recruiting zu starten';

  @override
  String reviewApplicants(int count) {
    return '$count neue Bewerber prüfen';
  }

  @override
  String replyMessages(int count) {
    return '$count ungelesene Nachrichten beantworten';
  }

  @override
  String get interviews2 => 'Vorstellungsgespräche';

  @override
  String get businessProfile => 'Unternehmensprofil';

  @override
  String get venueGallery => 'Betriebsgalerie';

  @override
  String get addPhotos => 'Fotos hinzufügen';

  @override
  String get businessName => 'Firmenname';

  @override
  String get venueTypeLabel => 'Betriebsart';

  @override
  String selectedItems(int count) {
    return '$count ausgewählt';
  }

  @override
  String get hiringProgress => 'Recruiting-Fortschritt';

  @override
  String get unlockBusinessPremium => 'Business Premium freischalten';

  @override
  String get businessPremiumSubtitle =>
      'Erhalten Sie priorisierten Zugriff auf Top-Kandidaten';

  @override
  String get scheduleFromApplicants => 'Aus Bewerbern planen';

  @override
  String get recentApplicants => 'Neueste Bewerber';

  @override
  String get viewAll => 'Alle anzeigen ›';

  @override
  String get recentActivity => 'Neueste Aktivität';

  @override
  String get candidatePipeline => 'Kandidaten-Pipeline';

  @override
  String get allApplicants => 'Alle Bewerber';

  @override
  String get searchCandidates => 'Kandidaten, Jobs, Gespräche suchen …';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get allTime => 'Gesamt';

  @override
  String get post => 'Beitrag';

  @override
  String get candidates => 'Kandidaten';

  @override
  String get applicantDetail => 'Bewerberdetails';

  @override
  String get candidateProfile => 'Kandidatenprofil';

  @override
  String get shortlistTitle => 'Favoriten';

  @override
  String get noShortlistedCandidates => 'Noch keine Favoriten';

  @override
  String get shortlistEmpty =>
      'Kandidaten, die Sie favorisieren, erscheinen hier';

  @override
  String get removeFromShortlist => 'Aus Favoriten entfernen';

  @override
  String get viewMessages => 'Nachrichten ansehen';

  @override
  String get manageJobs => 'Jobs verwalten';

  @override
  String get yourJobs => 'Ihre Jobs';

  @override
  String get noJobsPosted => 'Noch keine Jobs inseriert';

  @override
  String get noJobsPostedSubtitle =>
      'Inserieren Sie Ihren ersten Job, um zu starten';

  @override
  String get draftJobs => 'Entwürfe';

  @override
  String get activeJobs => 'Aktiv';

  @override
  String get expiredJobs => 'Abgelaufen';

  @override
  String get closedJobs => 'Geschlossen';

  @override
  String get createJob => 'Job erstellen';

  @override
  String get jobDetailsTitle => 'Job-Details';

  @override
  String get salaryRange => 'Gehaltsspanne';

  @override
  String get currency => 'Währung';

  @override
  String get monthly => 'Monatlich';

  @override
  String get annual => 'Jährlich';

  @override
  String get hourly => 'Stündlich';

  @override
  String get minSalary => 'Min';

  @override
  String get maxSalary => 'Max';

  @override
  String get perks => 'Vorteile';

  @override
  String get addPerk => 'Vorteil hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get preview => 'Vorschau';

  @override
  String get publishJob => 'Job veröffentlichen';

  @override
  String get jobPublished => 'Job veröffentlicht';

  @override
  String get jobUpdated => 'Job aktualisiert';

  @override
  String get jobSavedDraft => 'Als Entwurf gespeichert';

  @override
  String get fillRequired => 'Bitte füllen Sie die Pflichtfelder aus';

  @override
  String get jobUrgent => 'Als dringend markieren';

  @override
  String get addAtLeastOne => 'Fügen Sie mindestens eine Anforderung hinzu';

  @override
  String get createUpdate => 'Update erstellen';

  @override
  String get shareCompanyNews => 'Unternehmensnews teilen';

  @override
  String get addStory => 'Story hinzufügen';

  @override
  String get showWorkplace => 'Arbeitsplatz zeigen';

  @override
  String get viewShortlist => 'Favoriten ansehen';

  @override
  String get yourSavedCandidates => 'Ihre gespeicherten Kandidaten';

  @override
  String get inviteCandidate => 'Kandidat einladen';

  @override
  String get reachOutDirectly => 'Direkt kontaktieren';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Jobs',
      one: '1 aktiver Job',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Anstellungsart';

  @override
  String get requiredRole => 'Benötigte Funktion';

  @override
  String get selectCategoryRole2 => 'Kategorie & Funktion auswählen';

  @override
  String get hiresNeeded => 'Benötigte Einstellungen';

  @override
  String get compensation => 'Vergütung';

  @override
  String get useSalaryRange => 'Gehaltsspanne verwenden';

  @override
  String get contractDuration => 'Vertragsdauer';

  @override
  String get limitReached => 'Limit erreicht';

  @override
  String get upgradePlan => 'Upgrade durchführen';

  @override
  String usingXofY(int used, int total) {
    return 'Sie nutzen $used von $total Stellenanzeigen.';
  }

  @override
  String get businessInterviewsTitle => 'Vorstellungsgespräche';

  @override
  String get noInterviewsYet => 'Keine Gespräche geplant';

  @override
  String get scheduleFirstInterview =>
      'Planen Sie Ihr erstes Gespräch mit einem Kandidaten';

  @override
  String get sendInterviewInvite => 'Einladung senden';

  @override
  String get interviewSentTitle => 'Einladung gesendet!';

  @override
  String get interviewSentSubtitle => 'Der Kandidat wurde benachrichtigt.';

  @override
  String get scheduleInterviewTitle => 'Gespräch planen';

  @override
  String get interviewType => 'Art des Gesprächs';

  @override
  String get inPersonInterview => 'Vor Ort';

  @override
  String get videoCallInterview => 'Videoanruf';

  @override
  String get phoneCallInterview => 'Telefonanruf';

  @override
  String get interviewDate => 'Datum';

  @override
  String get interviewTime => 'Uhrzeit';

  @override
  String get interviewLocation => 'Ort';

  @override
  String get interviewNotes => 'Notizen';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get sendInviteCta => 'Einladung senden';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten',
      one: '1 Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'Keine neuen Nachrichten';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get currentPlan => 'Aktueller Plan';

  @override
  String get manage => 'Verwalten';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get renewalDate => 'Verlängerungsdatum';

  @override
  String get nearbyTalent => 'Talente in der Nähe';

  @override
  String get searchNearby => 'In der Nähe suchen';

  @override
  String get communityTitle => 'Community';

  @override
  String get createPost => 'Beitrag erstellen';

  @override
  String get insights => 'Insights';

  @override
  String get viewsLabel => 'Aufrufe';

  @override
  String get applicationsLabel => 'Bewerbungen';

  @override
  String get conversionRate => 'Conversion-Rate';

  @override
  String get topPerformingJob => 'Top-Job';

  @override
  String get viewAllSimple => 'Alle anzeigen';

  @override
  String get viewAllApplicantsForJob => 'Alle Bewerber für diesen Job anzeigen';

  @override
  String get noUpcomingInterviews => 'Keine anstehenden Gespräche';

  @override
  String get noActivityYet => 'Noch keine Aktivität';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get renewsAutomatically => 'Verlängert sich automatisch';

  @override
  String get plagitBusinessPlans => 'Plagit Business Pläne';

  @override
  String get scaleYourHiringSubtitle =>
      'Skalieren Sie Ihr Recruiting mit dem passenden Plan.';

  @override
  String get yearly => 'Jährlich';

  @override
  String get saveWithAnnualBilling =>
      'Sparen Sie mehr mit jährlicher Abrechnung';

  @override
  String get chooseYourPlanSubtitle =>
      'Wählen Sie den Plan, der zu Ihrem Bedarf passt.';

  @override
  String continueWithPlan(String plan) {
    return 'Mit $plan fortfahren';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'Abo verlängert sich automatisch. Jederzeit in den Einstellungen kündbar.';

  @override
  String get purchaseFlowComingSoon => 'Kauf-Flow folgt in Kürze';

  @override
  String get applicant => 'Bewerber';

  @override
  String get applicantNotFound => 'Bewerber nicht gefunden';

  @override
  String get cvViewerComingSoon => 'CV-Viewer folgt in Kürze';

  @override
  String get viewCV => 'Lebenslauf ansehen';

  @override
  String get application => 'Bewerbung';

  @override
  String get messagingComingSoon => 'Messaging folgt in Kürze';

  @override
  String get interviewConfirmed => 'Gespräch bestätigt';

  @override
  String get interviewMarkedCompleted => 'Gespräch als abgeschlossen markiert';

  @override
  String get cancelInterviewConfirm =>
      'Möchten Sie dieses Gespräch wirklich absagen?';

  @override
  String get yesCancel => 'Ja, absagen';

  @override
  String get interviewNotFound => 'Gespräch nicht gefunden';

  @override
  String get openingMeetingLink => 'Meeting-Link wird geöffnet …';

  @override
  String get rescheduleComingSoon => 'Verschiebungsfunktion folgt in Kürze';

  @override
  String get notesFeatureComingSoon => 'Notizfunktion folgt in Kürze';

  @override
  String get candidateMarkedHired => 'Kandidat als eingestellt markiert!';

  @override
  String get feedbackComingSoon => 'Feedback-Funktion folgt in Kürze';

  @override
  String get googleMapsComingSoon => 'Google-Maps-Integration folgt in Kürze';

  @override
  String get noCandidatesNearby => 'Keine Kandidaten in der Nähe';

  @override
  String get tryExpandingRadius => 'Erweitern Sie den Suchradius.';

  @override
  String get candidate => 'Kandidat';

  @override
  String get forOpenPosition => 'Für offene Stelle';

  @override
  String get dateAndTimeUpper => 'DATUM & UHRZEIT';

  @override
  String get interviewTypeUpper => 'GESPRÄCHSART';

  @override
  String get timezoneUpper => 'ZEITZONE';

  @override
  String get highlights => 'Highlights';

  @override
  String get cvNotAvailable => 'Lebenslauf nicht verfügbar';

  @override
  String get cvWillAppearHere => 'Erscheint hier nach dem Upload';

  @override
  String get seenEveryone => 'Sie haben alle gesehen';

  @override
  String get checkBackForCandidates =>
      'Schauen Sie später für neue Kandidaten vorbei.';

  @override
  String get dailyLimitReached => 'Tageslimit erreicht';

  @override
  String get upgradeForUnlimitedSwipes => 'Upgrade für unbegrenzte Swipes.';

  @override
  String get distanceUpper => 'ENTFERNUNG';

  @override
  String get inviteToInterview => 'Zum Gespräch einladen';

  @override
  String get details => 'Details';

  @override
  String get shortlistedSuccessfully => 'Erfolgreich zu Favoriten';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabCandidates => 'Kandidaten';

  @override
  String get tabActivity => 'Aktivität';

  @override
  String get statusPosted => 'Veröffentlicht';

  @override
  String get statusApplicants => 'Bewerber';

  @override
  String get statusInterviewsShort => 'Gespräche';

  @override
  String get statusHiredShort => 'Eingestellt';

  @override
  String get jobLiveVisible => 'Ihr Jobinserat ist live und sichtbar';

  @override
  String get postJobShort => 'Job inserieren';

  @override
  String get messagesTitle => 'Nachrichten';

  @override
  String get online2 => 'Jetzt online';

  @override
  String get candidateUpper => 'KANDIDAT';

  @override
  String get searchConversationsHint =>
      'Unterhaltungen, Kandidaten, Funktionen suchen …';

  @override
  String get filterUnread => 'Ungelesen';

  @override
  String get filterAll => 'Alle';

  @override
  String get whenCandidatesMessage =>
      'Wenn Kandidaten Sie anschreiben, erscheinen Unterhaltungen hier.';

  @override
  String get trySwitchingFilter => 'Versuchen Sie einen anderen Filter.';

  @override
  String get reply => 'Antworten';

  @override
  String get selectItems => 'Elemente auswählen';

  @override
  String countSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deleteConversation => 'Unterhaltung löschen?';

  @override
  String get deleteAllConversations => 'Alle Unterhaltungen löschen?';

  @override
  String get deleteSelectedNote =>
      'Ausgewählte Chats werden aus Ihrem Posteingang entfernt. Der Kandidat behält seine Kopie.';

  @override
  String get deleteAll => 'Alle löschen';

  @override
  String get selectConversations => 'Unterhaltungen auswählen';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'Meine Beiträge';

  @override
  String get savedTab => 'Gespeichert';

  @override
  String postingAs(String name) {
    return 'Beitrag als $name';
  }

  @override
  String get noPostsYet => 'Sie haben noch nicht gepostet';

  @override
  String get nothingHereYet => 'Hier ist noch nichts';

  @override
  String get shareVenueUpdate =>
      'Teilen Sie ein Update aus Ihrem Betrieb, um Ihre Community-Präsenz aufzubauen.';

  @override
  String get communityPostsAppearHere =>
      'Beiträge der Community erscheinen hier.';

  @override
  String get createFirstPost => 'Ersten Beitrag erstellen';

  @override
  String get yourPostUpper => 'IHR BEITRAG';

  @override
  String get businessLabel => 'Unternehmen';

  @override
  String get profileNotAvailable => 'Profil nicht verfügbar';

  @override
  String get companyProfile => 'Unternehmensprofil';

  @override
  String get premiumVenue => 'Premium-Betrieb';

  @override
  String get businessDetailsTitle => 'Unternehmensdaten';

  @override
  String get businessNameLabel => 'Firmenname';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get locationLabel => 'Standort';

  @override
  String get verificationLabel => 'Verifizierung';

  @override
  String get pendingLabel => 'Ausstehend';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String get contactLabel => 'Kontakt';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get companyNameField => 'Firmenname';

  @override
  String get phoneField => 'Telefon';

  @override
  String get locationField => 'Standort';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutTitle => 'Abmelden?';

  @override
  String get signOutConfirm => 'Möchten Sie sich wirklich abmelden?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiv',
      one: '1 aktiv',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neu diese Woche',
      one: '1 neu diese Woche',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Aktiv';

  @override
  String get jobStatusPaused => 'Pausiert';

  @override
  String get jobStatusClosed => 'Geschlossen';

  @override
  String get jobStatusDraft => 'Entwurf';

  @override
  String get contractCasual => 'Aushilfe';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Ideal für maximale Sichtbarkeit';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Sparen Sie $currency$amount/Jahr';
  }

  @override
  String get planBasicFeature1 => 'Bis zu 3 Jobs inserieren';

  @override
  String get planBasicFeature2 => 'Bewerberprofile ansehen';

  @override
  String get planBasicFeature3 => 'Einfache Kandidatensuche';

  @override
  String get planBasicFeature4 => 'E-Mail-Support';

  @override
  String get planProFeature1 => 'Bis zu 10 Jobs inserieren';

  @override
  String get planProFeature2 => 'Erweiterte Kandidatensuche';

  @override
  String get planProFeature3 => 'Bewerber-Priorisierung';

  @override
  String get planProFeature4 => 'Quick-Plug-Zugang';

  @override
  String get planProFeature5 => 'Chat-Support';

  @override
  String get planPremiumFeature1 => 'Unbegrenzte Jobinserate';

  @override
  String get planPremiumFeature2 => 'Hervorgehobene Jobanzeigen';

  @override
  String get planPremiumFeature3 => 'Erweiterte Analytik';

  @override
  String get planPremiumFeature4 => 'Quick Plug unbegrenzt';

  @override
  String get planPremiumFeature5 => 'Prioritäts-Matching';

  @override
  String get planPremiumFeature6 => 'Persönlicher Account Manager';

  @override
  String get currentSelectionCheck => 'Aktuelle Auswahl ✓';

  @override
  String selectPlanName(String plan) {
    return '$plan auswählen';
  }

  @override
  String get perYear => '/Jahr';

  @override
  String get perMonth => '/Monat';

  @override
  String get jobTitleHintExample => 'z. B. Senior Chef';

  @override
  String get locationHintExample => 'z. B. Dubai, VAE';

  @override
  String annualSalaryLabel(String currency) {
    return 'Jahresgehalt ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Monatsgehalt ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Stundensatz ($currency)';
  }

  @override
  String minSalaryLabel(String currency) {
    return 'Min ($currency)';
  }

  @override
  String maxSalaryLabel(String currency) {
    return 'Max ($currency)';
  }

  @override
  String get hoursPerWeekLabel => 'Stunden / Woche';

  @override
  String get expectedHoursWeekLabel => 'Erwartete Stunden / Woche (optional)';

  @override
  String get bonusTipsLabel => 'Bonus / Trinkgeld (optional)';

  @override
  String get bonusTipsHint => 'z. B. Trinkgeld & Servicepauschale';

  @override
  String get housingIncludedLabel => 'Unterkunft inklusive';

  @override
  String get travelIncludedLabel => 'Anreise inklusive';

  @override
  String get overtimeAvailableLabel => 'Überstunden möglich';

  @override
  String get flexibleScheduleLabel => 'Flexible Arbeitszeiten';

  @override
  String get weekendShiftsLabel => 'Wochenendschichten';

  @override
  String get describeRoleHint =>
      'Beschreiben Sie die Position, Aufgaben und was diesen Job besonders macht …';

  @override
  String get requirementsHint =>
      'Benötigte Fähigkeiten, Erfahrung, Zertifizierungen …';

  @override
  String previewPrefix(String text) {
    return 'Vorschau: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count Mon.';
  }

  @override
  String get roleAll => 'Alle';

  @override
  String get roleChef => 'Koch';

  @override
  String get roleWaiter => 'Kellner';

  @override
  String get roleBartender => 'Barkeeper';

  @override
  String get roleHost => 'Gastgeber';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Rezeption';

  @override
  String get roleKitchenPorter => 'Küchenhilfe';

  @override
  String get roleRelocate => 'Umzug';

  @override
  String get experience02Years => '0–2 Jahre';

  @override
  String get experience35Years => '3–5 Jahre';

  @override
  String get experience5PlusYears => '5+ Jahre';

  @override
  String get roleUpper => 'FUNKTION';

  @override
  String get experienceUpper => 'ERFAHRUNG';

  @override
  String get cvLabel => 'Lebenslauf';

  @override
  String get addShort => 'Hinzufügen';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kandidaten gefunden',
      one: '1 Kandidat gefunden',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'max. 50 km';

  @override
  String get shortlistAction => 'Favorit';

  @override
  String get messageAction => 'Nachricht';

  @override
  String get interviewAction => 'Gespräch';

  @override
  String get viewAction => 'Ansehen';

  @override
  String get rejectAction => 'Ablehnen';

  @override
  String get basedIn => 'Ansässig in';

  @override
  String get verificationPending => 'Verifizierung ausstehend';

  @override
  String get refreshAction => 'Aktualisieren';

  @override
  String get upgradeAction => 'Upgrade';

  @override
  String get searchJobsByTitleHint =>
      'Jobs nach Titel, Funktion oder Ort suchen …';

  @override
  String xShortlisted(String name) {
    return '$name zu Favoriten';
  }

  @override
  String xRejected(String name) {
    return '$name abgelehnt';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Möchten Sie $name wirklich ablehnen?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Beworben auf $role am $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Beworben $date';
  }

  @override
  String get salaryExpectationTitle => 'Gehaltsvorstellung';

  @override
  String get previousEmployer => 'Vorheriger Arbeitgeber';

  @override
  String get earlierVenue => 'Früherer Betrieb';

  @override
  String get presentLabel => 'Aktuell';

  @override
  String get skillCustomerService => 'Kundenservice';

  @override
  String get skillTeamwork => 'Teamarbeit';

  @override
  String get skillCommunication => 'Kommunikation';

  @override
  String get stepApplied => 'Beworben';

  @override
  String get stepViewed => 'Angesehen';

  @override
  String get stepShortlisted => 'Favorisiert';

  @override
  String get stepInterviewScheduled => 'Gespräch geplant';

  @override
  String get stepRejected => 'Abgelehnt';

  @override
  String get stepUnderReview => 'In Prüfung';

  @override
  String get stepPendingReview => 'Prüfung ausstehend';

  @override
  String get sortNewest => 'Neueste';

  @override
  String get sortMostExperienced => 'Meiste Erfahrung';

  @override
  String get sortBestMatch => 'Beste Übereinstimmung';

  @override
  String get filterApplied => 'Beworben';

  @override
  String get filterUnderReview => 'In Prüfung';

  @override
  String get filterShortlisted => 'Favorisiert';

  @override
  String get filterInterview => 'Vorstellungsgespräch';

  @override
  String get filterHired => 'Eingestellt';

  @override
  String get filterRejected => 'Abgelehnt';

  @override
  String get confirmed => 'Bestätigt';

  @override
  String get pending => 'Ausstehend';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get cancelled => 'Abgesagt';

  @override
  String get videoLabel => 'Video';

  @override
  String get viewDetails => 'Details ansehen';

  @override
  String get interviewDetails => 'Gesprächsdetails';

  @override
  String get interviewConfirmedHeadline => 'Gespräch bestätigt';

  @override
  String get interviewConfirmedSubline =>
      'Alles bereit. Wir erinnern Sie rechtzeitig.';

  @override
  String get dateLabel => 'Datum';

  @override
  String get timeLabel => 'Uhrzeit';

  @override
  String get formatLabel => 'Format';

  @override
  String get joinMeeting => 'Beitreten';

  @override
  String get viewJobAction => 'Job ansehen';

  @override
  String get addToCalendar => 'Zum Kalender';

  @override
  String get needsYourAttention => 'Benötigt Ihre Aufmerksamkeit';

  @override
  String get reviewAction => 'Prüfen';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewerbungen',
      one: '1 Bewerbung',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Neueste zuerst';

  @override
  String get interviewScheduledLabel => 'Gespräch geplant';

  @override
  String get editAction => 'Bearbeiten';

  @override
  String get currentPlanLabel => 'Aktueller Plan';

  @override
  String get freePlan => 'Kostenlos';

  @override
  String get profileStrength => 'Profilstärke';

  @override
  String get detailsLabel => 'Details';

  @override
  String get basedInLabel => 'Ansässig in';

  @override
  String get verificationLabel2 => 'Verifizierung';

  @override
  String get contactLabel2 => 'Kontakt';

  @override
  String get notSetLabel => 'Nicht gesetzt';

  @override
  String get chipAll => 'Alle';

  @override
  String get chipFullTime => 'Vollzeit';

  @override
  String get chipPartTime => 'Teilzeit';

  @override
  String get chipTemporary => 'Befristet';

  @override
  String get chipCasual => 'Aushilfe';

  @override
  String get sortBestMatchLabel => 'Beste Übereinstimmung';

  @override
  String get sortAZ => 'A–Z';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get featuredBadge => 'Empfohlen';

  @override
  String get urgentBadge => 'Dringend';

  @override
  String get salaryOnRequest => 'Gehalt auf Anfrage';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get urgentJobsOnly => 'Nur dringende Jobs';

  @override
  String get showOnlyUrgentListings => 'Nur dringende Anzeigen anzeigen';

  @override
  String get verifiedBusinessesOnly => 'Nur verifizierte Unternehmen';

  @override
  String get showOnlyVerifiedBusinesses =>
      'Nur verifizierte Unternehmen anzeigen';

  @override
  String get split => 'Aufteilung';

  @override
  String get payUpper => 'VERGÜTUNG';

  @override
  String get typeUpper => 'ART';

  @override
  String get whereUpper => 'ORT';

  @override
  String get payLabel => 'Vergütung';

  @override
  String get typeLabel => 'Art';

  @override
  String get whereLabel => 'Ort';

  @override
  String get whereYouWillWork => 'Wo Sie arbeiten werden';

  @override
  String get mapPreviewDirections =>
      'Kartenvorschau · Öffnen für Wegbeschreibung';

  @override
  String get directionsAction => 'Wegbeschreibung';

  @override
  String get communityTabForYou => 'Für Sie';

  @override
  String get communityTabFollowing => 'Folgt';

  @override
  String get communityTabNearby => 'In der Nähe';

  @override
  String get communityTabSaved => 'Gespeichert';

  @override
  String get viewProfileAction => 'Profil ansehen';

  @override
  String get copyLinkAction => 'Link kopieren';

  @override
  String get savePostAction => 'Beitrag speichern';

  @override
  String get unsavePostAction => 'Speichern aufheben';

  @override
  String get hideThisPost => 'Beitrag ausblenden';

  @override
  String get reportPost => 'Beitrag melden';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get newPostTitle => 'Neuer Beitrag';

  @override
  String get youLabel => 'Sie';

  @override
  String get postingToCommunityAsBusiness =>
      'Beitrag in Community als Unternehmen';

  @override
  String get postingToCommunityAsPro =>
      'Beitrag in Community als Hospitality Pro';

  @override
  String get whatsOnYourMind => 'Was denken Sie?';

  @override
  String get publishAction => 'Veröffentlichen';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentVideo => 'Video';

  @override
  String get attachmentLocation => 'Standort';

  @override
  String get boostMyProfileCta => 'Profil boosten';

  @override
  String get unlockYourFullPotential => 'Schöpfen Sie Ihr volles Potenzial aus';

  @override
  String get annualPlan => 'Jährlich';

  @override
  String get monthlyPlan => 'Monatlich';

  @override
  String get bestValueBadge => 'BESTER WERT';

  @override
  String get whatsIncluded => 'Enthalten';

  @override
  String get continueWithAnnual => 'Mit Jahresplan fortfahren';

  @override
  String get continueWithMonthly => 'Mit Monatsplan fortfahren';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get restorePurchasesLabel => 'Käufe wiederherstellen';

  @override
  String get subscriptionAutoRenewsNote =>
      'Abo verlängert sich automatisch. Jederzeit in den Einstellungen kündbar.';

  @override
  String get appStatusPillApplied => 'Beworben';

  @override
  String get appStatusPillUnderReview => 'In Prüfung';

  @override
  String get appStatusPillShortlisted => 'Favorisiert';

  @override
  String get appStatusPillInterviewInvited => 'Gespräch eingeladen';

  @override
  String get appStatusPillInterviewScheduled => 'Gespräch geplant';

  @override
  String get appStatusPillHired => 'Eingestellt';

  @override
  String get appStatusPillRejected => 'Abgelehnt';

  @override
  String get appStatusPillWithdrawn => 'Zurückgezogen';

  @override
  String get jobActionPause => 'Job pausieren';

  @override
  String get jobActionResume => 'Job fortsetzen';

  @override
  String get jobActionClose => 'Job schließen';

  @override
  String get statusConfirmedLower => 'bestätigt';

  @override
  String get postInsightsTitle => 'Beitrags-Insights';

  @override
  String get postInsightsSubtitle => 'Wer Ihre Inhalte sieht';

  @override
  String get recentViewers => 'Neueste Betrachter';

  @override
  String get lockedBadge => 'GESPERRT';

  @override
  String get viewerBreakdown => 'Betrachter-Übersicht';

  @override
  String get viewersByRole => 'Betrachter nach Funktion';

  @override
  String get topLocations => 'Top-Standorte';

  @override
  String get businesses => 'Unternehmen';

  @override
  String get saveToCollectionTitle => 'In Sammlung speichern';

  @override
  String get chooseCategory => 'Kategorie auswählen';

  @override
  String get removeFromCollection => 'Aus Sammlung entfernen';

  @override
  String newApplicationTemplate(String role) {
    return 'Neue Bewerbung — $role';
  }

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryCookingVideos => 'Kochvideos';

  @override
  String get categoryJobsTips => 'Job-Tipps';

  @override
  String get categoryHospitalityNews => 'Gastgewerbe-News';

  @override
  String get categoryRecipes => 'Rezepte';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get premiumHeroTagline =>
      'Mehr Sichtbarkeit, priorisierte Benachrichtigungen und erweiterte Filter für ernsthafte Gastgewerbe-Profis.';

  @override
  String get benefitAdvancedFilters => 'Erweiterte Suchfilter';

  @override
  String get benefitPriorityNotifications =>
      'Priorisierte Job-Benachrichtigungen';

  @override
  String get benefitProfileVisibility => 'Erhöhte Profil-Sichtbarkeit';

  @override
  String get benefitPremiumBadge => 'Premium-Profil-Abzeichen';

  @override
  String get benefitEarlyAccess => 'Früher Zugang zu neuen Jobs';

  @override
  String get unlockCandidatePremium => 'Candidate Premium freischalten';

  @override
  String get getStartedAction => 'Jetzt starten';

  @override
  String get findYourFirstJob => 'Finden Sie Ihren ersten Job';

  @override
  String get browseHospitalityRolesNearby =>
      'Durchstöbern Sie Hunderte Gastgewerbe-Funktionen in Ihrer Nähe';

  @override
  String get seeWhoViewedYourPostTitle =>
      'Sehen Sie, wer Ihren Beitrag gesehen hat';

  @override
  String get upgradeToPremiumCta => 'Auf Premium upgraden';

  @override
  String get upgradeToPremiumSubtitle =>
      'Upgraden Sie auf Premium, um verifizierte Unternehmen, Recruiter und Gastgewerbe-Führungskräfte zu sehen, die Ihre Inhalte gesehen haben.';

  @override
  String get verifiedBusinessViewers => 'Verifizierte Unternehmens-Betrachter';

  @override
  String get recruiterHiringManagerActivity =>
      'Recruiter- & Hiring-Manager-Aktivität';

  @override
  String get cityLevelReachBreakdown => 'Reichweite auf Stadtebene';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count live',
      one: '1 live',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in der Nähe',
      one: '1 in der Nähe',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jobs in Ihrer Nähe',
      one: '1 Job in Ihrer Nähe',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewerbungen in Prüfung',
      one: '1 Bewerbung in Prüfung',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gespräche geplant',
      one: '1 Gespräch geplant',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '1 ungelesene Nachricht',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten von Arbeitgebern',
      one: '1 ungelesene Nachricht von Arbeitgebern',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte verbleiben',
      one: '1 Schritt verbleibt',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Profil vollständig – hervorragend';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre',
      one: '1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/Std.';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Std./Woche',
      one: '1 Std./Woche',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'für $count Monate',
      one: 'für 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gespräche',
      one: '1 Gespräch',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Jobs finden';

  @override
  String get quickActionMyApplications => 'Meine Bewerbungen';

  @override
  String get quickActionUpdateProfile => 'Profil aktualisieren';

  @override
  String get quickActionCreatePost => 'Beitrag erstellen';

  @override
  String get quickActionViewInterviews => 'Gespräche ansehen';

  @override
  String get confirmSubscriptionTitle => 'Abonnement bestätigen';

  @override
  String get confirmAndSubscribeCta => 'Bestätigen & abonnieren';

  @override
  String get timelineLabel => 'Verlauf';

  @override
  String get interviewLabel => 'Vorstellungsgespräch';

  @override
  String get payOnRequest => 'Vergütung auf Anfrage';

  @override
  String get rateOnRequest => 'Satz auf Anfrage';

  @override
  String get quickActionFindJobsSubtitle =>
      'Entdecken Sie Positionen in Ihrer Nähe';

  @override
  String get quickActionMyApplicationsSubtitle => 'Jede Bewerbung im Blick';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Verbessern Sie Sichtbarkeit & Match-Score';

  @override
  String get quickActionCreatePostSubtitle =>
      'Teilen Sie Ihre Arbeit mit der Community';

  @override
  String get quickActionViewInterviewsSubtitle =>
      'Bereiten Sie sich auf das Kommende vor';

  @override
  String get offerLabel => 'Angebot';

  @override
  String hiringForTemplate(String role) {
    return 'Stellt ein: $role';
  }

  @override
  String get tapToOpenInMaps => 'Tippen, um in Karten zu öffnen';

  @override
  String get alreadyAppliedToJob =>
      'Sie haben sich bereits auf diesen Job beworben.';

  @override
  String get changePhoto => 'Foto ändern';

  @override
  String get changeAvatar => 'Avatar ändern';

  @override
  String get addPhotoAction => 'Foto hinzufügen';

  @override
  String get nationalityLabel => 'Nationalität';

  @override
  String get targetRoleLabel => 'Zielfunktion';

  @override
  String get salaryExpectationLabel => 'Gehaltsvorstellung';

  @override
  String get addLanguageCta => '+ Sprache hinzufügen';

  @override
  String get experienceLabel => 'Erfahrung';

  @override
  String get nameLabel => 'Name';

  @override
  String get zeroHours => 'Nullstunden';

  @override
  String get checkInterviewDetailsLine => 'Prüfen Sie die Gesprächsdetails';

  @override
  String get interviewInvitedSubline =>
      'Der Arbeitgeber möchte Sie sprechen – bestätigen Sie einen Termin';

  @override
  String get shortlistedSubline =>
      'Sie sind auf der Favoritenliste – warten auf den nächsten Schritt';

  @override
  String get underReviewSubline => 'Der Arbeitgeber prüft Ihr Profil';

  @override
  String get hiredHeadline => 'Eingestellt';

  @override
  String get hiredSubline => 'Glückwunsch! Sie haben ein Angebot erhalten';

  @override
  String get applicationSubmittedHeadline => 'Bewerbung eingereicht';

  @override
  String get applicationSubmittedSubline =>
      'Der Arbeitgeber prüft Ihre Bewerbung';

  @override
  String get withdrawnHeadline => 'Zurückgezogen';

  @override
  String get withdrawnSubline => 'Sie haben diese Bewerbung zurückgezogen';

  @override
  String get notSelectedHeadline => 'Nicht ausgewählt';

  @override
  String get notSelectedSubline => 'Vielen Dank für Ihr Interesse';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jobs gefunden',
      one: '1 Job gefunden',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gesamt',
      one: '1 gesamt',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in Prüfung',
      one: '1 in Prüfung',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count live',
      one: '1 live',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gespräche ausstehend – Termin bestätigen.',
      one: '1 Gespräch ausstehend – Termin bestätigen.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Gespräch bestätigt — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Gesprächsanfrage — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Bewerbungs-Update — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Angebot erhalten — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Nachricht von — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Gesprächs-Erinnerung — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Profil angesehen — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Neues Job-Match — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Bewerbung angesehen von — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Favorisiert bei — $name';
  }

  @override
  String get notifCompleteProfile =>
      'Vervollständigen Sie Ihr Profil für bessere Matches';

  @override
  String get notifCompleteBusinessProfile =>
      'Vervollständigen Sie Ihr Unternehmensprofil für mehr Sichtbarkeit';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Ihr $role-Job hat $count neue Aufrufe';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name hat sich auf $role beworben';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Neue Bewerbung: $name für $role';
  }

  @override
  String get chatTyping => 'Schreibt …';

  @override
  String get chatStatusSeen => 'Gesehen';

  @override
  String get chatStatusDelivered => 'Zugestellt';

  @override
  String get entryTagline => 'Die Staffing-Plattform für Gastgewerbe-Profis.';

  @override
  String get entryFindWork => 'Arbeit finden';

  @override
  String get entryFindWorkSubtitle =>
      'Jobs durchstöbern und von Top-Betrieben eingestellt werden';

  @override
  String get entryHireStaff => 'Personal einstellen';

  @override
  String get entryHireStaffSubtitle =>
      'Jobs inserieren und die besten Gastgewerbe-Talente finden';

  @override
  String get entryFindCompanies => 'Unternehmen finden';

  @override
  String get entryFindCompaniesSubtitle =>
      'Gastgewerbe-Betriebe und Dienstleister entdecken';

  @override
  String get servicesEntryTitle => 'Unternehmen suchen';

  @override
  String get servicesHospitalityServices => 'Gastgewerbe-Dienstleistungen';

  @override
  String get servicesEntrySubtitle =>
      'Registrieren Sie Ihr Dienstleistungsunternehmen oder finden Sie Anbieter in Ihrer Nähe';

  @override
  String get servicesRegisterCardTitle => 'Als Unternehmen registrieren';

  @override
  String get servicesRegisterCardSubtitle =>
      'Listen Sie Ihren Gastgewerbe-Service und werden Sie von Kunden entdeckt';

  @override
  String get servicesLookingCardTitle => 'Ich suche ein Unternehmen';

  @override
  String get servicesLookingCardSubtitle =>
      'Finden Sie Gastgewerbe-Dienstleister in Ihrer Nähe';

  @override
  String get registerBusinessTitle => 'Unternehmen registrieren';

  @override
  String get enterCompanyName => 'Firmenname eingeben';

  @override
  String get subcategoryOptional => 'Unterkategorie (optional)';

  @override
  String get subcategoryHintFloristDj => 'z. B. Florist, DJ-Service';

  @override
  String get searchCompaniesHint => 'Unternehmen suchen …';

  @override
  String get browseCategories => 'Kategorien durchsuchen';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unternehmen gefunden',
      one: '1 Unternehmen gefunden',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage => 'Food & Beverage Lieferanten';

  @override
  String get serviceCategoryEventServices => 'Event-Services';

  @override
  String get serviceCategoryDecorDesign => 'Dekor & Design';

  @override
  String get serviceCategoryEntertainment => 'Unterhaltung';

  @override
  String get serviceCategoryEquipmentOps => 'Ausstattung & Betrieb';

  @override
  String get serviceCategoryCleaningMaintenance => 'Reinigung & Wartung';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Beitrag';

  @override
  String get likeAction => 'Gefällt mir';

  @override
  String get commentAction => 'Kommentieren';

  @override
  String get saveActionLabel => 'Speichern';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String get addCommentHint => 'Kommentar hinzufügen …';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Likes',
      one: '1 Like',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kommentare',
      one: '1 Kommentar',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Speicherungen',
      one: '1 Speicherung',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '$count Min.';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '$count Std.';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '$count T.';
  }

  @override
  String get timeAgoNow => 'jetzt';

  @override
  String get activityTitle => 'Aktivität';

  @override
  String get activityLikedPost => 'gefällt Ihr Beitrag';

  @override
  String get activityCommented => 'hat Ihren Beitrag kommentiert';

  @override
  String get activityStartedFollowing => 'folgt Ihnen';

  @override
  String get activityMentioned => 'hat Sie erwähnt';

  @override
  String get activitySystemUpdate => 'hat Ihnen ein Update gesendet';

  @override
  String get noActivityYetDesc =>
      'Wenn Leute liken, kommentieren oder Ihnen folgen, erscheint es hier.';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get activeBadge => 'AKTIV';

  @override
  String get nextRenewalLabel => 'Nächste Verlängerung';

  @override
  String get startedLabel => 'Gestartet';

  @override
  String get statusLabel => 'Status';

  @override
  String get billingAndCancellation => 'Abrechnung & Kündigung';

  @override
  String get billingAndCancellationCopy =>
      'Ihr Abonnement wird über Ihr App Store / Google Play Konto abgerechnet. Sie können jederzeit in den Geräteeinstellungen kündigen – der Premium-Zugang bleibt bis zum Verlängerungsdatum aktiv.';

  @override
  String get premiumIsActive => 'Premium ist aktiv';

  @override
  String get premiumThanksCopy =>
      'Danke, dass Sie Plagit unterstützen. Sie haben vollen Zugriff auf alle Premium-Funktionen.';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Verlängert sich am $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Voller Betrachter-Zugang · alle Insights freigeschaltet';

  @override
  String get premiumActiveBadge => 'Premium aktiv';

  @override
  String get fullInsightsUnlocked =>
      'Vollständige Insights und Betrachter-Details freigeschaltet.';

  @override
  String get noViewersInCategory => 'Noch keine Betrachter in dieser Kategorie';

  @override
  String get onlyVerifiedViewersShown =>
      'Nur verifizierte Betrachter mit öffentlichen Profilen werden angezeigt.';

  @override
  String get notEnoughDataYet => 'Noch nicht genug Daten.';

  @override
  String get noViewInsightsYet => 'Noch keine Aufruf-Insights';

  @override
  String get noViewInsightsDesc =>
      'Insights erscheinen, sobald Ihr Beitrag mehr Aufrufe erhält.';

  @override
  String get suspiciousEngagementDetected => 'Verdächtige Interaktion erkannt';

  @override
  String get patternReviewRequired => 'Muster-Prüfung erforderlich';

  @override
  String get adminInsightsFooter =>
      'Admin-Ansicht – dieselben Insights wie der Autor, plus Moderations-Flags. Nur aggregiert, keine individuellen Betrachter-Identitäten.';

  @override
  String get viewerKindBusiness => 'Unternehmen';

  @override
  String get viewerKindCandidate => 'Kandidat';

  @override
  String get viewerKindRecruiter => 'Recruiter';

  @override
  String get viewerKindHiringManager => 'Hiring Manager';

  @override
  String get viewerKindBusinessesPlural => 'Unternehmen';

  @override
  String get viewerKindCandidatesPlural => 'Kandidaten';

  @override
  String get viewerKindRecruitersPlural => 'Recruiter';

  @override
  String get viewerKindHiringManagersPlural => 'Hiring Manager';

  @override
  String get searchPeoplePostsVenuesHint =>
      'Personen, Beiträge, Betriebe suchen …';

  @override
  String get searchCommunityTitle => 'Community durchsuchen';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated => 'Sie sind jetzt Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Käufe wiederhergestellt – Sie sind jetzt Candidate Premium';

  @override
  String get nothingToRestore => 'Nichts wiederherzustellen';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'Kein gültiges Abonnement gefunden – Premium-Zugang entfernt';

  @override
  String restoreFailedWithError(String error) {
    return 'Wiederherstellung fehlgeschlagen. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Jährlich';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Monatlich';

  @override
  String pricePerYearSlash(String price) {
    return '$price / Jahr';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / Monat';
  }

  @override
  String get nearbyJobsTitle => 'Jobs in der Nähe';

  @override
  String get expandRadius => 'Radius erweitern';

  @override
  String get noJobsInRadius => 'Keine Jobs in diesem Radius';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jobs im Umkreis von $radius Meilen',
      one: '1 Job im Umkreis von $radius Meilen',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Gespräch angenommen!';

  @override
  String get declineInterviewTitle => 'Gespräch ablehnen';

  @override
  String get declineInterviewConfirm =>
      'Möchten Sie dieses Gespräch wirklich ablehnen?';

  @override
  String get addedToCalendar => 'Zum Kalender hinzugefügt';

  @override
  String get removeCompanyTitle => 'Entfernen?';

  @override
  String get removeCompanyConfirm =>
      'Möchten Sie dieses Unternehmen wirklich aus Ihren gespeicherten entfernen?';

  @override
  String get signOutAllRolesConfirm =>
      'Möchten Sie sich wirklich von allen Rollen abmelden?';

  @override
  String get tapToViewAllConversations =>
      'Tippen Sie, um alle Unterhaltungen zu sehen';

  @override
  String get savedJobsTitle => 'Gespeicherte Jobs';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeicherte Jobs',
      one: '1 gespeicherter Job',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Aus Gespeicherten entfernen?';

  @override
  String get removeFromSavedConfirm =>
      'Dieser Job wird aus Ihrer gespeicherten Liste entfernt.';

  @override
  String get noSavedJobsSubtitle =>
      'Durchstöbern Sie Jobs und speichern Sie Ihre Favoriten';

  @override
  String get browseJobsAction => 'Jobs durchstöbern';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passende Jobs',
      one: '1 passender Job',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Gespeicherte Beiträge';

  @override
  String get searchSavedPostsHint => 'Gespeicherte Beiträge suchen …';

  @override
  String get skipAction => 'Überspringen';

  @override
  String get submitAction => 'Absenden';

  @override
  String get doneAction => 'Fertig';

  @override
  String get resetYourPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get enterEmailForResetCode =>
      'Geben Sie Ihre E-Mail ein, um einen Code zu erhalten';

  @override
  String get sendResetCode => 'Code senden';

  @override
  String get enterResetCode => 'Code eingeben';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get passwordResetComplete => 'Passwort zurückgesetzt';

  @override
  String get backToSignIn => 'Zurück zur Anmeldung';

  @override
  String get passwordChanged => 'Passwort geändert';

  @override
  String get passwordUpdatedShort =>
      'Ihr Passwort wurde erfolgreich aktualisiert.';

  @override
  String get passwordUpdatedRelogin =>
      'Ihr Passwort wurde aktualisiert. Bitte melden Sie sich erneut mit dem neuen Passwort an.';

  @override
  String get updatePassword => 'Passwort aktualisieren';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get passwordRequirements => 'Passwortanforderungen';

  @override
  String get newPasswordHint => 'Neues Passwort (min 8 Zeichen)';

  @override
  String get confirmPasswordField => 'Passwort bestätigen';

  @override
  String get enterEmailField => 'E-Mail eingeben';

  @override
  String get enterPasswordField => 'Passwort eingeben';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get selectHowToUse =>
      'Wählen Sie, wie Sie Plagit heute nutzen möchten';

  @override
  String get continueAsCandidate => 'Als Kandidat fortfahren';

  @override
  String get continueAsBusiness => 'Als Unternehmen fortfahren';

  @override
  String get signInToPlagit => 'Bei Plagit anmelden';

  @override
  String get enterCredentials => 'Geben Sie Ihre Zugangsdaten ein';

  @override
  String get adminPortal => 'Admin-Portal';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Bei Ihrem Admin-Konto anmelden';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Jobs, Funktionen, Restaurants suchen...';

  @override
  String get exploreNearbyJobs => 'Jobs in der Nähe entdecken';

  @override
  String get findOpportunitiesOnMap => 'Entdecken Sie Chancen auf der Karte';

  @override
  String get featuredJobs => 'Hervorgehobene Jobs';

  @override
  String get jobsNearYou => 'Jobs in Ihrer Nähe';

  @override
  String get jobsMatchingRoleType => 'Jobs passend zu Funktion und Art';

  @override
  String get availableNow => 'Jetzt verfügbar';

  @override
  String get noNearbyJobsYet => 'Noch keine Jobs in der Nähe';

  @override
  String get tryIncreasingRadius =>
      'Vergrößern Sie den Radius oder ändern Sie die Filter';

  @override
  String get checkBackForOpportunities =>
      'Schauen Sie bald für neue Möglichkeiten vorbei';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'Jetzt online';

  @override
  String get businessUpper => 'UNTERNEHMEN';

  @override
  String get waitingForBusinessFirstMessage =>
      'Warten auf die erste Nachricht des Unternehmens';

  @override
  String get whenEmployersMessageYou =>
      'Nachrichten von Arbeitgebern erscheinen hier.';

  @override
  String get replyToCandidate => 'Kandidat antworten …';

  @override
  String get quickFeedback => 'Schnelles Feedback';

  @override
  String get helpImproveMatches => 'Helfen Sie uns, Ihre Matches zu verbessern';

  @override
  String get thanksForFeedback => 'Danke für Ihr Feedback!';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get privacyAndSecurity => 'Datenschutz & Sicherheit';

  @override
  String get helpAndSupport => 'Hilfe & Support';

  @override
  String get activeRoleUpper => 'AKTIVE ROLLE';

  @override
  String get meetingLink => 'Meeting-Link';

  @override
  String get joinMeeting2 => 'Meeting beitreten';

  @override
  String get notes => 'Notizen';

  @override
  String get completeBusinessProfileTitle =>
      'Unternehmensprofil vervollständigen';

  @override
  String get businessDescription => 'Unternehmensbeschreibung';

  @override
  String get finishSetupAction => 'Einrichtung abschließen';

  @override
  String get describeBusinessHintLong =>
      'Beschreiben Sie Ihr Unternehmen, die Kultur und was es zu einem großartigen Arbeitsplatz macht... (min 150 Zeichen empfohlen)';

  @override
  String get describeBusinessHintShort => 'Beschreiben Sie Ihr Unternehmen...';

  @override
  String get writeShortIntroAboutYourself =>
      'Schreiben Sie eine kurze Vorstellung...';

  @override
  String get createBusinessAccountTitle => 'Unternehmenskonto erstellen';

  @override
  String get businessDetailsSection => 'Unternehmensdaten';

  @override
  String get openToInternationalCandidates =>
      'Offen für internationale Kandidaten';

  @override
  String get createAccountShort => 'Konto erstellen';

  @override
  String get yourDetailsSection => 'Ihre Daten';

  @override
  String get jobTypeField => 'Jobart';

  @override
  String get communityFeed => 'Community-Feed';

  @override
  String get postPublished => 'Beitrag veröffentlicht';

  @override
  String get postHidden => 'Beitrag ausgeblendet';

  @override
  String get postReportedReview => 'Beitrag gemeldet — wird vom Admin geprüft';

  @override
  String get postNotFound => 'Beitrag nicht gefunden';

  @override
  String get goBack => 'Zurück';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get removedFromSaved => 'Aus Gespeicherten entfernt';

  @override
  String get noPostsFound => 'Keine Beiträge gefunden';

  @override
  String get tipsStoriesAdvice =>
      'Tipps, Geschichten und Ratschläge von Profis';

  @override
  String get searchTalentPostsRolesHint =>
      'Talente, Beiträge, Funktionen suchen …';

  @override
  String get videoAttachmentsComingSoon => 'Video-Anhänge folgen in Kürze';

  @override
  String get locationTaggingComingSoon => 'Standort-Tagging folgt in Kürze';

  @override
  String get fullImageViewerComingSoon => 'Bildvoransicht folgt in Kürze';

  @override
  String get shareComingSoon => 'Teilen folgt in Kürze';

  @override
  String get findServices => 'Dienstleistungen finden';

  @override
  String get findHospitalityServices => 'Gastgewerbe-Dienstleistungen finden';

  @override
  String get browseServices => 'Dienstleistungen durchstöbern';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Dienste, Unternehmen, Orte suchen...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Unternehmen, Dienste, Orte suchen...';

  @override
  String get nearbyCompanies => 'Unternehmen in der Nähe';

  @override
  String get nearYou => 'In Ihrer Nähe';

  @override
  String get listLabel => 'Liste';

  @override
  String get mapViewLabel => 'Kartenansicht';

  @override
  String get noServicesFound => 'Keine Dienstleistungen gefunden';

  @override
  String get noCompaniesFoundNearby => 'Keine Unternehmen in der Nähe';

  @override
  String get noSavedCompanies => 'Keine gespeicherten Unternehmen';

  @override
  String get savedCompaniesTitle => 'Gespeicherte Unternehmen';

  @override
  String get saveCompaniesForLater =>
      'Speichern Sie Unternehmen, um sie später zu finden';

  @override
  String get latestUpdates => 'Neueste Updates';

  @override
  String get noPromotions => 'Keine Aktionen';

  @override
  String get companyHasNoPromotions =>
      'Dieses Unternehmen hat keine aktiven Aktionen.';

  @override
  String get companyHasNoUpdates =>
      'Dieses Unternehmen hat keine Updates veröffentlicht.';

  @override
  String get promotionsAndOffers => 'Aktionen & Angebote';

  @override
  String get promotionNotFound => 'Aktion nicht gefunden';

  @override
  String get promotionDetails => 'Aktionsdetails';

  @override
  String get termsAndConditions => 'Geschäftsbedingungen';

  @override
  String get relatedPosts => 'Ähnliche Beiträge';

  @override
  String get viewOffer => 'Angebot ansehen';

  @override
  String get offerBadge => 'ANGEBOT';

  @override
  String get requestQuote => 'Angebot anfragen';

  @override
  String get sendRequest => 'Anfrage senden';

  @override
  String get quoteRequestSent => 'Angebotsanfrage gesendet!';

  @override
  String get inquiry => 'Anfrage';

  @override
  String get dateNeeded => 'Gewünschtes Datum';

  @override
  String get serviceType => 'Dienstart';

  @override
  String get serviceArea => 'Einsatzgebiet';

  @override
  String get servicesOffered => 'Angebotene Dienste';

  @override
  String get servicesLabel => 'Dienste';

  @override
  String get servicePlans => 'Service-Pläne';

  @override
  String get growYourServiceBusiness =>
      'Wachsen Sie mit Ihrem Service-Unternehmen';

  @override
  String get getDiscoveredPremium =>
      'Werden Sie mit einem Premium-Eintrag von mehr Kunden entdeckt.';

  @override
  String get unlockPremium => 'Premium freischalten';

  @override
  String get getMoreVisibility => 'Mehr Sichtbarkeit und bessere Matches';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Nur Premium';

  @override
  String get savePercent17 => '17 % sparen';

  @override
  String get registerBusinessCta => 'Unternehmen registrieren';

  @override
  String get registrationSubmitted => 'Registrierung eingereicht';

  @override
  String get serviceDescription => 'Dienstleistungsbeschreibung';

  @override
  String get describeServicesHint =>
      'Beschreiben Sie Dienste, Erfahrung und Alleinstellungsmerkmale...';

  @override
  String get websiteOptional => 'Website (optional)';

  @override
  String get viewCompanyProfileCta => 'Unternehmensprofil ansehen';

  @override
  String get contactCompany => 'Unternehmen kontaktieren';

  @override
  String get aboutUs => 'Über uns';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Stadt';

  @override
  String get yourLocation => 'Ihr Standort';

  @override
  String get enterYourCity => 'Stadt eingeben';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get tryDifferentSearchTerm => 'Anderen Suchbegriff versuchen';

  @override
  String get tryDifferentOrAdjust =>
      'Versuchen Sie eine andere Suche, Kategorie oder Filter.';

  @override
  String get noPostsYetCompany => 'Noch keine Beiträge';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Angebot von $companyName anfordern';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Gültig bis $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'Ein Arbeitgeber prüft gerade Ihr Profil';

  @override
  String profileStrengthPercent(int percent) {
    return 'Ihr Profil ist zu $percent% vollständig';
  }

  @override
  String get profileGetsMoreViews =>
      'Ein vollständiges Profil erhält 3× mehr Aufrufe';

  @override
  String get applicationUpdate => 'Bewerbungsupdate';

  @override
  String get findJobsAndApply => 'Jobs finden und bewerben';

  @override
  String get manageJobsAndHiring => 'Jobs und Einstellungen verwalten';

  @override
  String get managePlatform => 'Plattform verwalten';

  @override
  String get findHospitalityCompanies => 'Hospitality-Unternehmen finden';

  @override
  String get candidateMessages => 'KANDIDATEN-NACHRICHTEN';

  @override
  String get businessMessages => 'UNTERNEHMENS-NACHRICHTEN';

  @override
  String get serviceInquiries => 'SERVICE-ANFRAGEN';

  @override
  String get acceptInterview => 'Vorstellungsgespräch annehmen';

  @override
  String get adminMenuDashboard => 'Dashboard';

  @override
  String get adminMenuUsers => 'Benutzer';

  @override
  String get adminMenuCandidates => 'Kandidaten';

  @override
  String get adminMenuBusinesses => 'Unternehmen';

  @override
  String get adminMenuJobs => 'Jobs';

  @override
  String get adminMenuApplications => 'Bewerbungen';

  @override
  String get adminMenuBookings => 'Buchungen';

  @override
  String get adminMenuPayments => 'Zahlungen';

  @override
  String get adminMenuMessages => 'Nachrichten';

  @override
  String get adminMenuNotifications => 'Benachrichtigungen';

  @override
  String get adminMenuReports => 'Berichte';

  @override
  String get adminMenuAnalytics => 'Analytik';

  @override
  String get adminMenuSettings => 'Einstellungen';

  @override
  String get adminMenuSupport => 'Support';

  @override
  String get adminMenuModeration => 'Moderation';

  @override
  String get adminMenuRoles => 'Rollen';

  @override
  String get adminMenuInvoices => 'Rechnungen';

  @override
  String get adminMenuLogs => 'Protokolle';

  @override
  String get adminMenuIntegrations => 'Integrationen';

  @override
  String get adminMenuLogout => 'Abmelden';

  @override
  String get adminActionApprove => 'Genehmigen';

  @override
  String get adminActionReject => 'Ablehnen';

  @override
  String get adminActionSuspend => 'Sperren';

  @override
  String get adminActionActivate => 'Aktivieren';

  @override
  String get adminActionDelete => 'Löschen';

  @override
  String get adminActionExport => 'Exportieren';

  @override
  String get adminSectionOverview => 'Übersicht';

  @override
  String get adminSectionManagement => 'Verwaltung';

  @override
  String get adminSectionFinance => 'Finanzen';

  @override
  String get adminSectionOperations => 'Betrieb';

  @override
  String get adminSectionSystem => 'System';

  @override
  String get adminStatTotalUsers => 'Benutzer gesamt';

  @override
  String get adminStatActiveJobs => 'Aktive Jobs';

  @override
  String get adminStatPendingApprovals => 'Ausstehende Genehmigungen';

  @override
  String get adminStatRevenue => 'Umsatz';

  @override
  String get adminStatBookingsToday => 'Buchungen heute';

  @override
  String get adminStatNewSignups => 'Neue Anmeldungen';

  @override
  String get adminStatConversionRate => 'Konversionsrate';

  @override
  String get adminMiscWelcome => 'Willkommen zurück';

  @override
  String get adminMiscLoading => 'Lädt…';

  @override
  String get adminMiscNoData => 'Keine Daten verfügbar';

  @override
  String get adminMiscSearchPlaceholder => 'Suchen…';

  @override
  String get adminMenuContent => 'Inhalt';

  @override
  String get adminMenuMore => 'Mehr';

  @override
  String get adminMenuVerifications => 'Verifizierungen';

  @override
  String get adminMenuSubscriptions => 'Abonnements';

  @override
  String get adminMenuCommunity => 'Community';

  @override
  String get adminMenuInterviews => 'Vorstellungsgespräche';

  @override
  String get adminMenuMatches => 'Übereinstimmungen';

  @override
  String get adminMenuFeaturedContent => 'Ausgewählte Inhalte';

  @override
  String get adminMenuAuditLog => 'Audit-Protokoll';

  @override
  String get adminMenuChangePassword => 'Passwort ändern';

  @override
  String get adminSectionPeople => 'Personen';

  @override
  String get adminSectionHiring => 'Einstellungsvorgänge';

  @override
  String get adminSectionContentComm => 'Inhalte und Kommunikation';

  @override
  String get adminSectionRevenue => 'Geschäft und Umsatz';

  @override
  String get adminSectionToolsContent => 'Tools und Inhalte';

  @override
  String get adminSectionQuickActions => 'Schnellaktionen';

  @override
  String get adminSectionNeedsAttention => 'Erfordert Aufmerksamkeit';

  @override
  String get adminStatActiveBusinesses => 'Aktive Unternehmen';

  @override
  String get adminStatApplicationsToday => 'Bewerbungen heute';

  @override
  String get adminStatInterviewsToday => 'Vorstellungsgespräche heute';

  @override
  String get adminStatFlaggedContent => 'Gemeldete Inhalte';

  @override
  String get adminStatActiveSubs => 'Aktive Abos';

  @override
  String get adminActionFlagged => 'Gemeldet';

  @override
  String get adminActionFeatured => 'Hervorgehoben';

  @override
  String get adminActionReviewFlagged => 'Gemeldete Inhalte prüfen';

  @override
  String get adminActionTodayInterviews => 'Heutige Vorstellungsgespräche';

  @override
  String get adminActionOpenReports => 'Offene Meldungen';

  @override
  String get adminActionManageSubscriptions => 'Abos verwalten';

  @override
  String get adminActionAnalyticsDashboard => 'Analyse-Dashboard';

  @override
  String get adminActionSendNotification => 'Benachrichtigung senden';

  @override
  String get adminActionCreateCommunityPost => 'Community-Beitrag erstellen';

  @override
  String get adminActionRetry => 'Wiederholen';

  @override
  String get adminMiscGreetingMorning => 'Guten Morgen';

  @override
  String get adminMiscGreetingAfternoon => 'Guten Tag';

  @override
  String get adminMiscGreetingEvening => 'Guten Abend';

  @override
  String get adminMiscAllClear =>
      'Alles in Ordnung — nichts erfordert Aufmerksamkeit.';

  @override
  String get adminSubtitleAllUsers => 'Alle Plattformnutzer';

  @override
  String get adminSubtitleCandidates => 'Bewerberprofile';

  @override
  String get adminSubtitleBusinesses => 'Arbeitgeberkonten';

  @override
  String get adminSubtitleJobs => 'Aktive Stellenangebote';

  @override
  String get adminSubtitleApplications => 'Eingereichte Bewerbungen';

  @override
  String get adminSubtitleInterviews => 'Geplante Gespräche';

  @override
  String get adminSubtitleMatches => 'Rollen- und Jobtyp-Treffer';

  @override
  String get adminSubtitleVerifications => 'Ausstehende Verifizierungen';

  @override
  String get adminSubtitleReports => 'Meldungen und Moderation';

  @override
  String get adminSubtitleSupport => 'Offene Support-Tickets';

  @override
  String get adminSubtitleMessages => 'Nutzer-Konversationen';

  @override
  String get adminSubtitleNotifications => 'Push- & In-App-Benachrichtigungen';

  @override
  String get adminSubtitleCommunity => 'Beiträge und Diskussionen';

  @override
  String get adminSubtitleFeaturedContent => 'Hervorgehobene Inhalte';

  @override
  String get adminSubtitleSubscriptions => 'Pläne und Abrechnung';

  @override
  String get adminSubtitleAuditLog => 'Admin-Aktivitätsprotokolle';

  @override
  String get adminSubtitleAnalytics => 'Plattform-Metriken';

  @override
  String get adminSubtitleSettings => 'Plattform-Konfiguration';

  @override
  String get adminSubtitleUsersPage => 'Plattformkonten verwalten';

  @override
  String get adminSubtitleContentPage => 'Jobs, Bewerbungen und Gespräche';

  @override
  String get adminSubtitleModerationPage =>
      'Verifizierungen, Meldungen und Support';

  @override
  String get adminSubtitleMorePage => 'Einstellungen, Analysen und Konto';

  @override
  String get adminSubtitleAnalyticsHero => 'KPIs, Trends und Plattformzustand';

  @override
  String get adminBadgeUrgent => 'Dringend';

  @override
  String get adminBadgeReview => 'Prüfen';

  @override
  String get adminBadgeAction => 'Aktion';

  @override
  String get adminMenuAllUsers => 'Alle Nutzer';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count heute';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count offen';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count aktiv';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count ungelesen';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count ausstehend';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count Beiträge';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count hervorgehoben';
  }

  @override
  String get adminStatusActive => 'Aktiv';

  @override
  String get adminStatusPaused => 'Pausiert';

  @override
  String get adminStatusClosed => 'Geschlossen';

  @override
  String get adminStatusDraft => 'Entwurf';

  @override
  String get adminStatusFlagged => 'Gemeldet';

  @override
  String get adminStatusSuspended => 'Gesperrt';

  @override
  String get adminStatusPending => 'Ausstehend';

  @override
  String get adminStatusConfirmed => 'Bestätigt';

  @override
  String get adminStatusCompleted => 'Abgeschlossen';

  @override
  String get adminStatusCancelled => 'Storniert';

  @override
  String get adminStatusAccepted => 'Akzeptiert';

  @override
  String get adminStatusDenied => 'Abgelehnt';

  @override
  String get adminStatusExpired => 'Abgelaufen';

  @override
  String get adminStatusResolved => 'Gelöst';

  @override
  String get adminStatusScheduled => 'Geplant';

  @override
  String get adminStatusBanned => 'Gesperrt';

  @override
  String get adminStatusVerified => 'Verifiziert';

  @override
  String get adminStatusFailed => 'Fehlgeschlagen';

  @override
  String get adminStatusSuccess => 'Erfolg';

  @override
  String get adminStatusDelivered => 'Zugestellt';

  @override
  String get adminFilterAll => 'Alle';

  @override
  String get adminFilterToday => 'Heute';

  @override
  String get adminFilterUnread => 'Ungelesen';

  @override
  String get adminFilterRead => 'Gelesen';

  @override
  String get adminFilterCandidates => 'Kandidaten';

  @override
  String get adminFilterBusinesses => 'Unternehmen';

  @override
  String get adminFilterAdmins => 'Admins';

  @override
  String get adminFilterCandidate => 'Kandidat';

  @override
  String get adminFilterBusiness => 'Unternehmen';

  @override
  String get adminFilterSystem => 'System';

  @override
  String get adminFilterPinned => 'Angepinnt';

  @override
  String get adminFilterEmployers => 'Arbeitgeber';

  @override
  String get adminFilterBanners => 'Banner';

  @override
  String get adminFilterBilling => 'Abrechnung';

  @override
  String get adminFilterFeaturedEmployer => 'Hervorgehobener Arbeitgeber';

  @override
  String get adminFilterFeaturedJob => 'Hervorgehobener Job';

  @override
  String get adminFilterHomeBanner => 'Home-Banner';

  @override
  String get adminEmptyAdjustFilters => 'Filter anpassen.';

  @override
  String get adminEmptyJobsTitle => 'Keine Jobs';

  @override
  String get adminEmptyJobsSub => 'Keine passenden Jobs.';

  @override
  String get adminEmptyUsersTitle => 'Keine Nutzer';

  @override
  String get adminEmptyMessagesTitle => 'Keine Nachrichten';

  @override
  String get adminEmptyMessagesSub => 'Keine Unterhaltungen.';

  @override
  String get adminEmptyReportsTitle => 'Keine Meldungen';

  @override
  String get adminEmptyReportsSub => 'Keine Meldungen zu prüfen.';

  @override
  String get adminEmptyBusinessesTitle => 'Keine Unternehmen';

  @override
  String get adminEmptyBusinessesSub => 'Keine passenden Unternehmen.';

  @override
  String get adminEmptyNotifsTitle => 'Keine Benachrichtigungen';

  @override
  String get adminEmptySubsTitle => 'Keine Abos';

  @override
  String get adminEmptySubsSub => 'Keine passenden Abos.';

  @override
  String get adminEmptyLogsTitle => 'Keine Logs';

  @override
  String get adminEmptyContentTitle => 'Kein Inhalt';

  @override
  String get adminEmptyInterviewsTitle => 'Keine Interviews';

  @override
  String get adminEmptyInterviewsSub => 'Keine passenden Interviews.';

  @override
  String get adminEmptyFeedback => 'Feedback erscheint hier';

  @override
  String get adminEmptyMatchNotifs =>
      'Match-Benachrichtigungen erscheinen hier';

  @override
  String get adminTitleMatchManagement => 'Match-Verwaltung';

  @override
  String get adminTitleAdminLogs => 'Admin-Logs';

  @override
  String get adminTitleContentFeatured => 'Inhalt / Hervorgehoben';

  @override
  String get adminTabFeedback => 'Feedback';

  @override
  String get adminTabStats => 'Statistiken';

  @override
  String get adminSortNewest => 'Neueste';

  @override
  String get adminSortPriority => 'Priorität';

  @override
  String get adminStatTotalMatches => 'Matches insgesamt';

  @override
  String get adminStatAccepted => 'Akzeptiert';

  @override
  String get adminStatDenied => 'Abgelehnt';

  @override
  String get adminStatFeedbackCount => 'Feedback';

  @override
  String get adminStatMatchQuality => 'Match-Qualitätswert';

  @override
  String get adminStatTotal => 'Gesamt';

  @override
  String get adminStatPendingCount => 'Ausstehend';

  @override
  String get adminStatNotificationsCount => 'Benachrichtigungen';

  @override
  String get adminStatActiveCount => 'Aktiv';

  @override
  String get adminSectionPlatformSettings => 'Plattform-Einstellungen';

  @override
  String get adminSectionNotificationSettings =>
      'Benachrichtigungseinstellungen';

  @override
  String get adminSettingMaintenanceTitle => 'Wartungsmodus';

  @override
  String get adminSettingMaintenanceSub => 'Zugriff für alle deaktivieren';

  @override
  String get adminSettingNewRegsTitle => 'Neue Registrierungen';

  @override
  String get adminSettingNewRegsSub => 'Neue Anmeldungen erlauben';

  @override
  String get adminSettingFeaturedJobsTitle => 'Hervorgehobene Jobs';

  @override
  String get adminSettingFeaturedJobsSub =>
      'Hervorgehobene Jobs auf Startseite zeigen';

  @override
  String get adminSettingEmailNotifsTitle => 'E-Mail-Benachrichtigungen';

  @override
  String get adminSettingEmailNotifsSub => 'E-Mail-Warnungen senden';

  @override
  String get adminSettingPushNotifsTitle => 'Push-Benachrichtigungen';

  @override
  String get adminSettingPushNotifsSub => 'Push-Benachrichtigungen senden';

  @override
  String get adminActionSaveChanges => 'Änderungen speichern';

  @override
  String get adminToastSettingsSaved => 'Einstellungen gespeichert';

  @override
  String get adminActionResolve => 'Lösen';

  @override
  String get adminActionDismiss => 'Verwerfen';

  @override
  String get adminActionBanUser => 'Nutzer sperren';

  @override
  String get adminSearchUsersHint => 'Name, E-Mail, Rolle, Ort suchen...';

  @override
  String get adminMiscPositive => 'positiv';

  @override
  String adminCountUsers(int count) {
    return '$count Nutzer';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count Benachrichtigungen';
  }

  @override
  String adminCountLogs(int count) {
    return '$count Log-Einträge';
  }

  @override
  String adminCountItems(int count) {
    return '$count Einträge';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Wiederholt x$count';
  }

  @override
  String get adminStatusApplied => 'Beworben';

  @override
  String get adminStatusUnderReview => 'In Prüfung';

  @override
  String get adminStatusShortlisted => 'Engere Auswahl';

  @override
  String get adminStatusInterview => 'Gespräch';

  @override
  String get adminStatusHired => 'Eingestellt';

  @override
  String get adminStatusRejected => 'Abgelehnt';

  @override
  String get adminStatusOpen => 'Offen';

  @override
  String get adminStatusInReview => 'In Bearbeitung';

  @override
  String get adminStatusWaiting => 'Wartend';

  @override
  String get adminPriorityHigh => 'Hoch';

  @override
  String get adminPriorityMedium => 'Mittel';

  @override
  String get adminPriorityLow => 'Niedrig';

  @override
  String get adminActionViewProfile => 'Profil ansehen';

  @override
  String get adminActionVerify => 'Verifizieren';

  @override
  String get adminActionReview => 'Prüfen';

  @override
  String get adminActionOverride => 'Überschreiben';

  @override
  String get adminEmptyCandidatesTitle => 'Keine Kandidaten';

  @override
  String get adminEmptyApplicationsTitle => 'Keine Bewerbungen';

  @override
  String get adminEmptyVerificationsTitle =>
      'Keine ausstehenden Verifizierungen';

  @override
  String get adminEmptyIssuesTitle => 'Keine Vorgänge';

  @override
  String get adminEmptyAuditTitle => 'Keine Audit-Einträge';

  @override
  String get adminSearchCandidatesTitle => 'Kandidaten suchen';

  @override
  String get adminSearchCandidatesHint =>
      'Nach Name, E-Mail oder Rolle suchen…';

  @override
  String get adminSearchAuditHint => 'Audit-Log durchsuchen…';

  @override
  String get adminMiscUnknown => 'Unbekannt';

  @override
  String adminCountTotal(int count) {
    return '$count insgesamt';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count markiert';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count Tage Wartezeit';
  }

  @override
  String get adminPeriodWeek => 'Woche';

  @override
  String get adminPeriodMonth => 'Monat';

  @override
  String get adminPeriodYear => 'Jahr';

  @override
  String get adminKpiNewCandidates => 'Neue Kandidaten';

  @override
  String get adminKpiNewBusinesses => 'Neue Unternehmen';

  @override
  String get adminKpiJobsPosted => 'Veröffentlichte Jobs';

  @override
  String get adminSectionApplicationFunnel => 'Bewerbungs-Funnel';

  @override
  String get adminSectionPlatformGrowth => 'Plattform-Wachstum';

  @override
  String get adminSectionPremiumConversion => 'Premium-Konversion';

  @override
  String get adminSectionTopLocations => 'Top-Standorte';

  @override
  String get adminStatusViewed => 'Angesehen';

  @override
  String get adminWeekdayMon => 'Mo';

  @override
  String get adminWeekdayTue => 'Di';

  @override
  String get adminWeekdayWed => 'Mi';

  @override
  String get adminWeekdayThu => 'Do';

  @override
  String get adminWeekdayFri => 'Fr';

  @override
  String get adminWeekdaySat => 'Sa';

  @override
  String get adminWeekdaySun => 'So';

  @override
  String get adminFilterReported => 'Gemeldet';

  @override
  String get adminFilterHidden => 'Ausgeblendet';

  @override
  String get adminEmptyPostsTitle => 'Keine Beiträge';

  @override
  String get adminEmptyContentFilter => 'Kein Inhalt entspricht diesem Filter.';

  @override
  String get adminBannerReportedReview => 'GEMELDET — PRÜFUNG ERFORDERLICH';

  @override
  String get adminBannerHiddenFromFeed => 'AUS FEED AUSGEBLENDET';

  @override
  String get adminActionInsights => 'Analysen';

  @override
  String get adminActionHide => 'Ausblenden';

  @override
  String get adminActionRemove => 'Entfernen';

  @override
  String get adminActionCancel => 'Abbrechen';

  @override
  String get adminDialogRemovePostTitle => 'Beitrag entfernen?';

  @override
  String get adminDialogRemovePostBody =>
      'Dies löscht den Beitrag und seine Kommentare dauerhaft. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get adminSnackbarReportCleared => 'Meldung aufgehoben';

  @override
  String get adminSnackbarPostHidden => 'Beitrag aus Feed ausgeblendet';

  @override
  String get adminSnackbarPostRemoved => 'Beitrag entfernt';

  @override
  String adminCountReported(int count) {
    return '$count gemeldet';
  }

  @override
  String adminCountHidden(int count) {
    return '$count ausgeblendet';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium Premium von $total insgesamt';
  }

  @override
  String get adminActionUnverify => 'Verifizierung aufheben';

  @override
  String get adminActionReactivate => 'Reaktivieren';

  @override
  String get adminActionFeature => 'Hervorheben';

  @override
  String get adminActionUnfeature => 'Nicht mehr hervorheben';

  @override
  String get adminActionFlagAccount => 'Konto melden';

  @override
  String get adminActionUnflagAccount => 'Meldung aufheben';

  @override
  String get adminActionConfirm => 'Bestätigen';

  @override
  String get adminDialogVerifyBusinessTitle => 'Unternehmen verifizieren';

  @override
  String get adminDialogUnverifyBusinessTitle =>
      'Verifizierung des Unternehmens aufheben';

  @override
  String get adminDialogSuspendBusinessTitle => 'Unternehmen sperren';

  @override
  String get adminDialogReactivateBusinessTitle => 'Unternehmen reaktivieren';

  @override
  String get adminDialogVerifyCandidateTitle => 'Kandidat verifizieren';

  @override
  String get adminDialogSuspendCandidateTitle => 'Kandidaten sperren';

  @override
  String get adminDialogReactivateCandidateTitle => 'Kandidaten reaktivieren';

  @override
  String get adminSnackbarBusinessVerified => 'Unternehmen verifiziert';

  @override
  String get adminSnackbarVerificationRemoved => 'Verifizierung entfernt';

  @override
  String get adminSnackbarBusinessSuspended => 'Unternehmen gesperrt';

  @override
  String get adminSnackbarBusinessReactivated => 'Unternehmen reaktiviert';

  @override
  String get adminSnackbarBusinessFeatured => 'Unternehmen hervorgehoben';

  @override
  String get adminSnackbarBusinessUnfeatured =>
      'Hervorhebung des Unternehmens aufgehoben';

  @override
  String get adminSnackbarUserVerified => 'Benutzer verifiziert';

  @override
  String get adminSnackbarUserSuspended => 'Benutzer gesperrt';

  @override
  String get adminSnackbarUserReactivated => 'Benutzer reaktiviert';

  @override
  String get adminTabProfile => 'Profil';

  @override
  String get adminTabActivity => 'Aktivität';

  @override
  String get adminTabNotes => 'Notizen';

  @override
  String adminDialogVerifyBody(String name) {
    return '$name als verifiziert markieren?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return 'Verifizierung von $name entfernen?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return '$name reaktivieren?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return '$name sperren? Alle Jobs werden pausiert.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return '$name sperren? Der Zugriff wird entzogen.';
  }

  @override
  String get adminFieldName => 'Name';

  @override
  String get adminFieldEmail => 'E-Mail';

  @override
  String get adminFieldPhone => 'Telefon';

  @override
  String get adminFieldLocation => 'Standort';

  @override
  String get adminFieldPlan => 'Plan';

  @override
  String get adminFieldVerified => 'Verifiziert';

  @override
  String get adminFieldStatus => 'Status';

  @override
  String get adminFieldJoined => 'Beigetreten';

  @override
  String get adminFieldCategory => 'Kategorie';

  @override
  String get adminFieldSize => 'Größe';

  @override
  String get adminFieldRole => 'Rolle';

  @override
  String get adminFieldProfileCompletion => 'Profilvollständigkeit';

  @override
  String get adminStatApplicants => 'Bewerber';

  @override
  String get adminStatSaved => 'Gespeichert';

  @override
  String get adminPlaceholderAddNote => 'Notiz hinzufügen...';

  @override
  String get adminEmptyNoJobsPosted => 'Keine Jobs veröffentlicht';

  @override
  String get adminSectionSubscriptionDetail => 'Abonnementdetails';

  @override
  String get adminEmptySubscriptionNotFound => 'Abonnement nicht gefunden';

  @override
  String get adminSectionPlanDetails => 'Tarifdetails';

  @override
  String get adminFieldPrice => 'Preis';

  @override
  String get adminFieldStartDate => 'Startdatum';

  @override
  String get adminFieldRenewalDate => 'Verlängerungsdatum';

  @override
  String get adminSectionAdminOverride => 'Admin-Override';

  @override
  String get adminPlanCandidatePremium => 'Kandidat Premium';

  @override
  String get adminPlanBusinessPro => 'Business Pro';

  @override
  String get adminPlanBusinessPremium => 'Business Premium';

  @override
  String get adminPlanFree => 'Kostenlos';

  @override
  String get adminFieldNewRenewalDate => 'Neues Verlängerungsdatum';

  @override
  String get adminPlaceholderDateExample => 'z. B. 15. Jun 2026';

  @override
  String get adminFieldReason => 'Grund';

  @override
  String get adminPlaceholderReasonOverride => 'Grund für das Override...';

  @override
  String get adminActionApplyOverride => 'Override anwenden';

  @override
  String get adminSectionHistory => 'Verlauf';

  @override
  String get adminTimelineSubscriptionCreated => 'Abonnement erstellt';

  @override
  String get adminTimelinePaymentProcessed => 'Zahlung verarbeitet';

  @override
  String get adminEmptyNoAdminNotes => 'Keine Admin-Notizen.';

  @override
  String get adminSectionAuditDetail => 'Audit-Details';

  @override
  String get adminEmptyEntryNotFound => 'Eintrag nicht gefunden';

  @override
  String get adminFieldAdmin => 'Admin';

  @override
  String get adminFieldAction => 'Aktion';

  @override
  String get adminFieldTimestamp => 'Zeitstempel';

  @override
  String get adminFieldTarget => 'Ziel';

  @override
  String get adminFieldType => 'Typ';

  @override
  String get adminSectionChanges => 'Änderungen';

  @override
  String get adminFieldIpAddress => 'IP-Adresse';

  @override
  String get adminAuditUnverified => 'Nicht verifiziert';

  @override
  String get adminAuditStandard => 'Standard';

  @override
  String get adminAuditFeatured => 'Hervorgehoben';

  @override
  String get adminAuditPreviousStatus => 'Vorheriger Status';

  @override
  String get adminAuditOverridden => 'Überschrieben';

  @override
  String get adminAuditPrevious => 'Vorher';

  @override
  String get adminAuditUpdated => 'Aktualisiert';

  @override
  String get adminStatusWithdrawn => 'Zurückgezogen';

  @override
  String get adminStatusNoShow => 'Nicht erschienen';

  @override
  String get adminStatusInProgress => 'Läuft';

  @override
  String get adminStatusReviewed => 'Überprüft';

  @override
  String get adminStatusDecision => 'Entscheidung';

  @override
  String get adminSectionApplicationDetail => 'Bewerbungsdetails';

  @override
  String get adminSectionInterviewDetail => 'Interviewdetails';

  @override
  String get adminSectionTimeline => 'Zeitachse';

  @override
  String get adminSectionAdminNotes => 'Admin-Notizen';

  @override
  String get adminSectionActions => 'Aktionen';

  @override
  String get adminFieldCandidate => 'Kandidat';

  @override
  String get adminFieldJob => 'Stelle';

  @override
  String get adminFieldBusiness => 'Unternehmen';

  @override
  String get adminFieldDate => 'Datum';

  @override
  String get adminFieldTime => 'Uhrzeit';

  @override
  String get adminFieldFormat => 'Format';

  @override
  String get adminBadgeFlaggedForReview => 'Zur Moderation gemeldet';

  @override
  String get adminPlaceholderSelectStatus => 'Status auswählen';

  @override
  String get adminDialogConfirmOverrideTitle => 'Überschreibung bestätigen';

  @override
  String adminDialogConfirmOverrideQuestion(String status) {
    return 'Status auf „$status\" ändern?';
  }

  @override
  String get adminDialogReasonPrefix => 'Grund:';

  @override
  String get adminMiscNoneProvided => 'Keine Angabe';

  @override
  String get adminSnackbarStatusOverrideApplied =>
      'Statusüberschreibung angewendet';

  @override
  String get adminSnackbarNoteSaved => 'Notiz gespeichert';

  @override
  String get adminSnackbarNoteAdded => 'Notiz hinzugefügt';

  @override
  String get adminSnackbarMarkedNoShow => 'Als nicht erschienen markiert';

  @override
  String get adminSnackbarInterviewCancelled => 'Interview abgesagt';

  @override
  String get adminSnackbarInterviewCompleted => 'Interview abgeschlossen';

  @override
  String get adminActionSaveNote => 'Notiz speichern';

  @override
  String get adminActionAddNote => 'Notiz hinzufügen';

  @override
  String get adminActionComplete => 'Abschließen';

  @override
  String get adminActionMarkNoShow => 'Als nicht erschienen markieren';

  @override
  String get adminEmptyNoNotes => 'Noch keine Notizen.';

  @override
  String get adminSectionVerificationReview => 'Verifizierungsprüfung';

  @override
  String get adminSectionProfileSummary => 'Profilübersicht';

  @override
  String get adminSectionDocuments => 'Dokumente';

  @override
  String get adminSectionReportDetail => 'Berichtsdetails';

  @override
  String get adminSectionReportInformation => 'Berichtsinformationen';

  @override
  String get adminSectionEvidence => 'Beweise';

  @override
  String get adminSectionAdminDecision => 'Admin-Entscheidung';

  @override
  String get adminSectionAuditTrail => 'Prüfprotokoll';

  @override
  String get adminSectionSupportIssue => 'Support-Anfrage';

  @override
  String get adminSectionDescription => 'Beschreibung';

  @override
  String get adminSectionUpdateStatus => 'Status aktualisieren';

  @override
  String get adminSectionResolution => 'Lösung';

  @override
  String get adminFieldSubmitted => 'Eingereicht';

  @override
  String get adminFieldReporter => 'Melder';

  @override
  String get adminFieldEntity => 'Entität';

  @override
  String get adminFieldUser => 'Benutzer';

  @override
  String get adminFieldNote => 'Notiz';

  @override
  String get adminFieldCreated => 'Erstellt';

  @override
  String get adminFieldUpdated => 'Aktualisiert';

  @override
  String get adminFieldPriority => 'Priorität';

  @override
  String get adminDocTitleIdDocument => 'Ausweisdokument';

  @override
  String get adminDocSubtitleIdDocument => 'Reisepass / Personalausweis';

  @override
  String get adminDocTitleCv => 'Lebenslauf';

  @override
  String get adminDocSubtitleCv => 'Lebenslauf';

  @override
  String get adminDocTitleRegistration => 'Registrierung';

  @override
  String get adminDocSubtitleRegistration =>
      'Unternehmensregistrierungsdokument';

  @override
  String get adminActionViewDocument => 'Dokument ansehen';

  @override
  String get adminActionSaveDecision => 'Entscheidung speichern';

  @override
  String get adminActionUpdate => 'Aktualisieren';

  @override
  String get adminActionMarkResolved => 'Als gelöst markieren';

  @override
  String get adminActionOptionNone => 'Keine';

  @override
  String get adminActionOptionWarning => 'Warnung';

  @override
  String get adminActionOptionContentRemoved => 'Inhalt entfernt';

  @override
  String get adminActionOptionAccountSuspended => 'Konto gesperrt';

  @override
  String get adminPlaceholderRejectionReason => 'Grund für Ablehnung...';

  @override
  String get adminPlaceholderDecisionNotes =>
      'Entscheidungsnotizen hinzufügen...';

  @override
  String get adminPlaceholderResolutionSummary => 'Lösungszusammenfassung...';

  @override
  String get adminSnackbarVerificationApproved => 'Verifizierung genehmigt';

  @override
  String get adminSnackbarVerificationRejected => 'Verifizierung abgelehnt';

  @override
  String get adminSnackbarIssueResolved => 'Problem gelöst';

  @override
  String adminSnackbarViewingDocument(String title) {
    return '$title wird angezeigt (Platzhalter)';
  }

  @override
  String adminSnackbarStatusUpdatedTo(String status) {
    return 'Status aktualisiert auf $status';
  }

  @override
  String adminSnackbarDecisionSaved(String status, String action) {
    return 'Entscheidung gespeichert: $status / $action';
  }

  @override
  String get adminDialogApproveVerificationTitle => 'Verifizierung genehmigen';

  @override
  String adminDialogApproveVerificationBody(String name) {
    return 'Verifizierung für $name genehmigen?';
  }

  @override
  String get adminDialogRejectVerificationTitle => 'Verifizierung ablehnen';

  @override
  String adminDialogRejectVerificationBody(String name) {
    return 'Verifizierung für $name ablehnen?';
  }

  @override
  String get adminEmptyIssueNotFound => 'Anfrage nicht gefunden';

  @override
  String get adminValuePlatform => 'Plattform';

  @override
  String get adminValueSupport => 'Support';

  @override
  String get adminMiscReportCreatedByPlatform =>
      'Bericht durch automatische Erkennung der Plattform erstellt';

  @override
  String get adminActionPause => 'Pausieren';

  @override
  String get adminActionClose => 'Schließen';

  @override
  String get adminActionViewApplicants => 'Bewerber anzeigen';

  @override
  String get adminBadgeFeatured => 'Hervorgehoben';

  @override
  String get adminFieldPosted => 'Veröffentlicht';

  @override
  String get adminFieldViews => 'Aufrufe';

  @override
  String get adminFieldPay => 'Bezahlung';

  @override
  String get adminFieldEmployment => 'Beschäftigung';

  @override
  String get adminFieldSummary => 'Zusammenfassung';

  @override
  String get adminFieldAnnual => 'Jährlich';

  @override
  String get adminFieldMonthly => 'Monatlich';

  @override
  String get adminFieldDuration => 'Dauer';

  @override
  String get adminFieldHourly => 'Stündlich';

  @override
  String get adminFieldWeeklyHours => 'Wochenstunden';

  @override
  String get adminFieldBonus => 'Bonus';

  @override
  String get adminFieldShift => 'Schicht';

  @override
  String get adminFieldSalaryRange => 'Gehaltsspanne';

  @override
  String get adminMiscNotSpecified => 'Nicht angegeben';

  @override
  String get adminSectionModeration => 'Moderation';

  @override
  String get adminSectionCompensationReview => 'Vergütungsprüfung';

  @override
  String get adminSectionApplicantsSummary => 'Bewerberübersicht';

  @override
  String get adminSectionExtras => 'Extras';

  @override
  String get adminPlaceholderFlagReason => 'Grund der Meldung...';

  @override
  String get adminSnackbarJobFeatured => 'Job hervorgehoben';

  @override
  String get adminSnackbarJobUnfeatured => 'Job nicht mehr hervorgehoben';

  @override
  String get adminSnackbarJobRemoved => 'Job entfernt';

  @override
  String get adminDialogPauseJobTitle => 'Job pausieren';

  @override
  String get adminDialogPauseJobBody => 'Diese Anzeige pausieren?';

  @override
  String get adminDialogCloseJobTitle => 'Job schließen';

  @override
  String get adminDialogCloseJobBody => 'Diese Anzeige dauerhaft schließen?';

  @override
  String get adminDialogRemoveJobTitle => 'Job entfernen';

  @override
  String get adminDialogRemoveJobBody =>
      'Diesen Job vollständig entfernen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get adminModerationFlagThis => 'Diesen Job melden';

  @override
  String get adminModerationIsFlagged => 'Dieser Job ist gemeldet';

  @override
  String get adminPerkHousing => 'Unterkunft inklusive';

  @override
  String get adminPerkTravel => 'Reise inklusive';

  @override
  String get adminPerkOvertime => 'Überstunden möglich';

  @override
  String get adminPerkFlexible => 'Flexibler Zeitplan';

  @override
  String get adminPerkWeekend => 'Wochenendschichten';

  @override
  String get adminStatNew => 'Neu';

  @override
  String get adminStatReviewed => 'Geprüft';

  @override
  String get adminStatShortlisted => 'Engere Auswahl';

  @override
  String get adminStatRejected => 'Abgelehnt';

  @override
  String get businessFieldMeetingLink => 'Meeting-Link';

  @override
  String get businessFieldLocation => 'Ort';
}
